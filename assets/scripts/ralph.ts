#!/usr/bin/env bun
import { $ } from "bun"
import {
	intro,
	outro,
	select,
	multiselect,
	spinner as createSpinner,
	log,
	cancel,
	isCancel,
	type SpinnerResult,
} from "@clack/prompts"
import { mkdir, appendFile, readFile } from "node:fs/promises"
import { existsSync } from "node:fs"
import { join } from "node:path"
import { it } from "node:test"

const MAX_RETRIES = 25
const REPO_ROOT = await $`git rev-parse --show-toplevel`
	.text()
	.then((s) => s.trim())
const MEMORY_DIR = join(REPO_ROOT, ".ralph_memory")

// --- Types ---

type IssueStatus = "open" | "closed" | "in_progress"
type IssueType = "task" | "epic"

/** Shape returned by `br show`, `br blocked`, etc. */
type BrIssue = {
	id: string
	title: string
	issue_type: IssueType
	status: IssueStatus
	priority: number
}

type Issue = {
	id: string
	title: string
	issue_type: IssueType
	status: IssueStatus
	blockedBy: string[]
}

type TreeNode = {
	id: string
	title: string
	depth: number
	parent_id: string | null
	priority: number
	status: IssueStatus
	truncated: boolean
}

type BlockedIssue = BrIssue & {
	blocked_by: string[]
	blocked_by_count: number
}

type Epic = {
	epic: {
		id: string
		title: string
		description: string
		status: IssueStatus
		priority: number
		issue_type: "epic"
		created_at: string
		created_by: string
		updated_at: string
		source_repo: string
		compaction_level: number
		original_size: number
	}
	total_children: number
	closed_children: number
	eligible_for_close: boolean
}

type BvRecommendation = {
	id: string
	title: string
	score: number
	reasons: string[]
	unblocks_ids?: string[]
	blocked_by?: string[]
	action?: string
}

type BvTriage = {
	triage: {
		quick_ref: {
			open_count: number
			actionable_count: number
			blocked_count: number
		}
		recommendations: BvRecommendation[]
		quick_wins: Array<{ id: string; title: string; score: number }>
		blockers_to_clear: Array<{
			id: string
			title: string
			unblocks_count: number
			actionable: boolean
			blocked_by?: string[]
		}>
	}
}

// --- Main ---

intro("ralph — autonomous issue loop")
await mkdir(MEMORY_DIR, { recursive: true })

const spinner = createSpinner()

const epics = await fetchWith(spinner, "Fetching epics", getEpics)
if (!epics) process.exit(1)

const epicChoice = await select({
	message: "Select an epic",
	options: epics.map(({ epic }) => ({
		value: epic.id,
		label: epic.title,
		hint: epic.id,
	})),
})
if (isCancel(epicChoice)) {
	cancel("Cancelled.")
	process.exit(0)
}

const selectedEpic = epics.find(({ epic }) => epic.id === epicChoice)?.epic
if (!selectedEpic) {
	cancel("Epic not found.")
	process.exit(1)
}
log.info(`Epic: ${selectedEpic.title}`)

const initialResult = await fetchWith(spinner, "Fetching open issues", () =>
	getWorkableIssues(selectedEpic.id),
)
if (!initialResult) process.exit(1)

const { issues: initialIssues, epicIssueIds } = initialResult

if (initialIssues.length === 0) {
	outro("No open issues in this epic.")
	process.exit(0)
}

const pulledIn = initialIssues.filter((i) => !epicIssueIds.has(i.id))
if (pulledIn.length > 0) {
	log.info(`Pulled in ${pulledIn.length} cross-epic blocker(s)`)
}
log.info(`${initialIssues.length} workable issues found`)

const selectedIds = await multiselect({
	message: "Deselect issues to skip",
	options: initialIssues.map((i) => ({
		value: i.id,
		label: i.title,
		hint: epicIssueIds.has(i.id) ? i.id : `${i.id} (blocker)`,
	})),
	initialValues: initialIssues.map((i) => i.id),
	required: true,
})
if (isCancel(selectedIds)) {
	cancel("Cancelled.")
	process.exit(0)
}

const selectedSet = new Set(selectedIds as string[])
log.info(`Working on ${selectedSet.size} issue(s)`)

let iterations = 0
while (true) {
	if (iterations >= MAX_RETRIES) {
		log.error("Reached maximum retries. Exiting.")
		break
	}

	let openIssues: Issue[]
	try {
		const result = await getWorkableIssues(selectedEpic.id)
		openIssues = result.issues.filter((i) => selectedSet.has(i.id))
	} catch (error) {
		log.error(`Failed to fetch issues: ${errorMessage(error)}`)
		break
	}

	if (openIssues.length === 0) break

	log.info(`Iteration ${iterations} starts...`)

	await workOnEpic(selectedEpic, openIssues)

	iterations++
	log.info(`Iteration ${iterations} complete.`)
}

outro("All tasks complete!")

// --- Smart selection ---

async function workOnEpic(epic: Epic["epic"], issues: Issue[]) {
	spinner.start("Running Ralph...")
	const prompt = await buildPrompt(epic, issues)
	await runClaude(prompt)
}

async function buildPrompt(
	epic: Epic["epic"],
	issues: Issue[],
): Promise<string> {
	const memory = await getMemory(epic)

	const issuesDisplay = issues
		.map((i) => {
			const blockers = i.blockedBy.length
				? `(Blocked by ${i.blockedBy.join(", ")})`
				: ""

			return `- ${i.id} : ${i.title} ${blockers}`
		})
		.join("\n")

	return `Work on this epic:
${epic.id}: ${epic.title}
  
Available issues:
${issuesDisplay}

Previous work / step breakdown:
${memory || "(first attempt)"}

Rules:
- Always announce the current issue you're working on with its ID and title, and the reasoning behind it. Do that as early as possible.
- Use \`br show <id>\` to read full issue details
- ALWAYS work on only one issue, unless you have very good reasons to do otherwise. Remember, keep your context focused
- Use TDD and planing. Fully implement the issue with working code.
- If the issue is large, break it into steps. Save your plan and progress to memory — you may continue in the next iteration
- Close each completed issue with \`br close <id>\`
- Do NOT init git, change remotes, or push
- Add important findings for the next iteration of the loop to ./ralph-memory/${epic.id}.md in the root of the repo.
- If an issue mentions a dependency, check if the dependency is closed. If it is, *fully* ignore the dependency, otherwise work on it first.
`
}

// --- Data fetching ---

async function fetchWith<T>(
	spin: SpinnerResult,
	message: string,
	fn: () => Promise<T>,
): Promise<T | null> {
	spin.start(message)
	try {
		const result = await fn()
		spin.stop(message)
		return result
	} catch (error) {
		spin.stop(`Failed: ${message.toLowerCase()}`)
		console.error(error)
		cancel(errorMessage(error))
		return null
	}
}

async function getEpics(): Promise<Epic[]> {
	return $`br epic status --json`
		.json()
		.then((result) => result as Epic[])
		.then((epics) =>
			epics.filter(
				(e) =>
					e.epic.status === "open" &&
					!e.eligible_for_close &&
					e.total_children > 0,
			),
		)
}

async function getWorkableIssues(
	epicId: string,
): Promise<{ issues: Issue[]; epicIssueIds: Set<string> }> {
	const [nodes, allBlocked]: [TreeNode[], BlockedIssue[]] = await Promise.all([
		$`br dep tree ${epicId} --direction up --json`.json(),
		$`br blocked --json`.json(),
	])

	const blockedMap = new Map(allBlocked.map((b) => [b.id, b]))
	const issues = new Map<string, Issue>()
	const epicIssueIds = new Set<string>()

	// Add epic's open issues with accurate blocker info
	for (const node of nodes) {
		if (node.status !== "open" || node.id === epicId) continue
		epicIssueIds.add(node.id)
		const blocked = blockedMap.get(node.id)
		issues.set(node.id, {
			id: node.id,
			title: node.title,
			issue_type: "task",
			status: "open",
			blockedBy: blocked?.blocked_by ?? [],
		})
	}

	// Recursively pull in cross-epic blockers
	const resolved = new Set<string>()
	async function resolveBlockers(issueMap: Map<string, Issue>) {
		const toResolve: string[] = []
		for (const issue of issueMap.values()) {
			for (const blockerId of issue.blockedBy) {
				if (!issues.has(blockerId) && !resolved.has(blockerId)) {
					toResolve.push(blockerId)
				}
			}
		}

		if (toResolve.length === 0) return

		const newIssues = new Map<string, Issue>()
		for (const blockerId of toResolve) {
			resolved.add(blockerId)
			const blocked = blockedMap.get(blockerId)
			if (blocked) {
				if (blocked.issue_type === "epic") continue
				newIssues.set(blockerId, {
					id: blocked.id,
					title: blocked.title,
					issue_type: blocked.issue_type,
					status: "open",
					blockedBy: blocked.blocked_by,
				})
			} else {
				// Not blocked — fetch details (br show returns an array)
				const [detail]: [BrIssue] = await $`br show ${blockerId} --json`.json()
				if (
					!detail ||
					detail.status === "closed" ||
					detail.issue_type === "epic"
				)
					continue
				newIssues.set(blockerId, {
					id: detail.id,
					title: detail.title,
					issue_type: detail.issue_type,
					status: "open",
					blockedBy: [],
				})
			}
		}

		for (const [id, issue] of newIssues) {
			issues.set(id, issue)
		}

		// Recurse for blockers of blockers
		await resolveBlockers(newIssues)
	}

	await resolveBlockers(issues)

	// Remove blockers that are closed or otherwise not in the working set
	for (const issue of issues.values()) {
		issue.blockedBy = issue.blockedBy.filter((id) => issues.has(id))
	}

	return { issues: [...issues.values()], epicIssueIds }
}

// --- Memory ---

async function getMemory(epic: Epic["epic"]): Promise<string> {
	const path = join(MEMORY_DIR, `${epic.id}.md`)
	if (!existsSync(path)) return ""
	return readFile(path, "utf8")
}

// --- Utilities ---

function errorMessage(error: unknown): string {
	return error instanceof Error ? error.message : String(error)
}

async function runClaude(prompt: string) {
	const proc = Bun.spawn(
		[
			"claude",
			"-p",
			"-",
			"--output-format",
			"stream-json",
			"--verbose",
			"--permission-mode",
			"acceptEdits",
			"--allowedTools",
			"Edit",
			"Write",
			"Read",
			"Grep",
			"Glob",
			"Bash(br *)",
			"Bash(git status *)",
			"Bash(git diff *)",
			"Bash(git log *)",
			"Bash(git add *)",
			"Bash(bun *)",
			"Bash(cargo *)",
			"Bash(nix *)",
			"Bash(ls *)",
			"Bash(mkdir *)",
		],
		{ stdin: Buffer.from(prompt), stdout: "pipe", stderr: "inherit" },
	)

	const agentMessages: string[] = []
	let buf = ""
	const decoder = new TextDecoder()

	for await (const chunk of proc.stdout) {
		buf += decoder.decode(chunk, { stream: true })
		const lines = buf.split("\n")
		buf = lines.pop()!

		for (const line of lines) {
			if (!line) continue
			try {
				const event = JSON.parse(line)

				if (event.type === "assistant") {
					const content = event.message?.content
					if (!Array.isArray(content)) continue

					for (const block of content) {
						const prefix = agentMessages.length > 5 ? "...\n" : ""
						const messageDisplay =
							prefix + agentMessages.slice(-5).join("\n-----\n")

						if (block.type === "tool_use") {
							spinner.message(
								`${messageDisplay}\nTool: ${JSON.stringify(block)}`,
							)
						} else if (block.type === "text") {
							spinner.message(messageDisplay)
							agentMessages.push(block.text)
							agentMessages.splice(0, agentMessages.length - 10)
						}
					}
				}
			} catch (e) {
				console.error("parse error:", e, line)
			}
		}
	}

	await proc.exited
}
