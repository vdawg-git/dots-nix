import type { AgentMessage } from "@earendil-works/pi-agent-core";
import { completeSimple, type Api, type AssistantMessage, type Context, type Message, type Model, type TextContent, type UserMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext, SessionEntry } from "@earendil-works/pi-coding-agent";

export { createAutoSessionNameExtension as default };

const CUSTOM_TYPE = "auto-session-name";
const EXTENSION_VERSION = 1;
const TURN_INTERVAL = 12;
const TITLE_MAX_LENGTH = 32;
const TITLE_MAX_WORDS = 6;
const GENERATION_TIMEOUT_MS = 8000;
const GENERATION_MAX_TOKENS = 256;
const FIRST_SNIPPET_LENGTH = 1200;
const USER_SNIPPET_LENGTH = 360;
const ASSISTANT_SNIPPET_LENGTH = 420;
const RECENT_USER_LIMIT = 20;
const RECENT_ASSISTANT_LIMIT = 5;
const CHEAP_MODEL_PREFERENCES = [
	"gpt-4.1-mini",
	"gpt-4o-mini",
	"gemini-2.5-flash",
	"gemini-2.0-flash",
	"claude-3-5-haiku",
	"claude-3-haiku",
	"gpt-5.4-mini",
	"gpt-5.1-codex-mini",
	"mini",
	"flash",
	"haiku",
] as const;
const GENERIC_TITLES = new Set(["conversation summary", "user request", "coding help", "new session"]);

type MutableAutoNameState = {
	running: boolean;
};

type AutoNameProvenance = Readonly<{
	assistantMessageCount: number;
	extensionVersion: number;
	generatedAt: string;
	name: string;
	userTurnCount: number;
}>;

type MessageCounts = Readonly<{
	assistantMessageCount: number;
	userTurnCount: number;
}>;

type RenameDecision = Readonly<{
	reason: "first" | "refresh";
}> | Readonly<{
	reason: "skip";
}>;

type TextSample = Readonly<{
	assistantTexts: readonly string[];
	firstAssistantText: string | undefined;
	firstUserText: string | undefined;
	userTexts: readonly string[];
}>;

type CandidateModel = Readonly<{
	model: Model<Api>;
	preferenceRank: number;
	reasoningRank: number;
	score: number;
}>;

/** Install a background session-name generator with conservative ownership rules. */
function createAutoSessionNameExtension(pi: ExtensionAPI): void {
	const state: MutableAutoNameState = { running: false };

	pi.on("message_end", (event, context) => {
		if (event.message.role !== "assistant") {
			return;
		}

		if (state.running) {
			return;
		}

		state.running = true;
		void runAutoName({ context, currentAssistantMessage: event.message, pi, state }).catch((error: unknown) => {
			notifyFailure(context, error);
			state.running = false;
		});
	});
}

/** Decide, generate, validate, set, and record one automatic session name. */
async function runAutoName(options: Readonly<{
	context: ExtensionContext;
	currentAssistantMessage: AgentMessage;
	pi: ExtensionAPI;
	state: MutableAutoNameState;
}>): Promise<void> {
	try {
		const branchEntries = options.context.sessionManager.getBranch();
		const messages = [...getBranchMessages(branchEntries), options.currentAssistantMessage];
		const counts = getMessageCounts(messages);
		const provenance = getLatestProvenance(branchEntries);
		const decision = getRenameDecision({ counts, provenance });

		if (decision.reason === "skip") {
			return;
		}

		const model = getNamingModel({ currentModel: options.context.model, models: options.context.modelRegistry.getAvailable() });
		const title = await generateTitle({ context: options.context, decision, messages, model, provenance });
		options.pi.setSessionName(title);
		options.pi.appendEntry<AutoNameProvenance>(CUSTOM_TYPE, {
			assistantMessageCount: counts.assistantMessageCount,
			extensionVersion: EXTENSION_VERSION,
			generatedAt: new Date().toISOString(),
			name: title,
			userTurnCount: counts.userTurnCount,
		});
	} finally {
		options.state.running = false;
	}
}

/** Determine whether cadence allows an automatic rename. */
function getRenameDecision(options: Readonly<{
	counts: MessageCounts;
	provenance: AutoNameProvenance | undefined;
}>): RenameDecision {
	const shouldCreateFirstName = options.provenance === undefined && options.counts.assistantMessageCount === 1;
	const shouldCreateLateFirstName = options.provenance === undefined && options.counts.userTurnCount >= TURN_INTERVAL;
	const shouldRefreshName = options.provenance !== undefined
		&& options.counts.userTurnCount - options.provenance.userTurnCount >= TURN_INTERVAL;

	if (shouldCreateFirstName) {
		return { reason: "first" } satisfies RenameDecision;
	}

	if (shouldCreateLateFirstName || shouldRefreshName) {
		return { reason: "refresh" } satisfies RenameDecision;
	}

	return { reason: "skip" } satisfies RenameDecision;
}

/** Generate a strict title using the selected cheap model without touching the active model. */
async function generateTitle(options: Readonly<{
	context: ExtensionContext;
	decision: Exclude<RenameDecision, Readonly<{ reason: "skip" }>>;
	messages: readonly AgentMessage[];
	model: Model<Api>;
	provenance: AutoNameProvenance | undefined;
}>): Promise<string> {
	const auth = await options.context.modelRegistry.getApiKeyAndHeaders(options.model);

	if (!auth.ok) {
		throw new Error(auth.error);
	}

	const response = await completeWithTimeout({
		apiKey: auth.apiKey,
		context: createNamingContext({ decision: options.decision, messages: options.messages, provenance: options.provenance }),
		headers: auth.headers,
		model: options.model,
	});
	const title = validateTitle(sanitizeTitle(getGeneratedTitleText({ model: options.model, response })));

	return title;
}

/** Call Pi AI completion with an aborting timeout around the cosmetic naming request. */
async function completeWithTimeout(options: Readonly<{
	apiKey: string | undefined;
	context: Context;
	headers: Record<string, string> | undefined;
	model: Model<Api>;
}>): Promise<AssistantMessage> {
	const controller = new AbortController();
	const timeout = setTimeout(() => controller.abort(), GENERATION_TIMEOUT_MS);

	try {
		const response = await completeSimple(options.model, options.context, {
			apiKey: options.apiKey,
			headers: options.headers,
			maxRetries: 0,
			maxTokens: GENERATION_MAX_TOKENS,
			signal: controller.signal,
			timeoutMs: GENERATION_TIMEOUT_MS,
		});

		return response;
	} finally {
		clearTimeout(timeout);
	}
}

/** Build the tiny title-generation prompt from selected transcript snippets. */
function createNamingContext(options: Readonly<{
	decision: Exclude<RenameDecision, Readonly<{ reason: "skip" }>>;
	messages: readonly AgentMessage[];
	provenance: AutoNameProvenance | undefined;
}>): Context {
	const samples = getTextSamples(options.messages);
	const prompt = options.decision.reason === "first"
		? createFirstPrompt(samples)
		: createRefreshPrompt({ provenance: options.provenance, samples });
	const context: Context = {
		messages: [createUserMessage(prompt)],
		systemPrompt: [
			"You generate short session titles.",
			"Return only one title, no quotes, no prefix, no punctuation.",
			"Use 2 to 4 words and at most 32 characters.",
			"Prefer descriptive noun phrases. Use task-oriented wording only when the user explicitly asked to do something.",
			"Preserve specific feature, file, domain, or tool names when useful.",
		].join("\n"),
	};

	return context;
}

function createFirstPrompt(samples: TextSample): string {
	const prompt = [
		"Name this coding-agent session from the first exchange.",
		`User: ${samples.firstUserText ?? ""}`,
		`Assistant: ${samples.firstAssistantText ?? ""}`,
	].join("\n\n");

	return prompt;
}

function createRefreshPrompt(options: Readonly<{ provenance: AutoNameProvenance | undefined; samples: TextSample }>): string {
	const userSection = options.samples.userTexts.map((text, index) => `${index + 1}. ${text}`).join("\n");
	const assistantSection = options.samples.assistantTexts.map((text, index) => `${index + 1}. ${text}`).join("\n");
	const prompt = [
		"Rename this ongoing coding-agent session if the topic has drifted.",
		`Current auto-title: ${options.provenance?.name ?? ""}`,
		`Recent user messages:\n${userSection}`,
		`Recent assistant snippets:\n${assistantSection}`,
	].join("\n\n");

	return prompt;
}

function createUserMessage(content: string): UserMessage {
	const message: UserMessage = {
		content,
		role: "user",
		timestamp: Date.now(),
	};

	return message;
}

/** Select the cheapest available text model, using preference names only as tie-breakers. */
function getNamingModel(options: Readonly<{ currentModel: Model<Api> | undefined; models: readonly Model<Api>[] }>): Model<Api> {
	const candidates = options.models.filter((model) => model.input.includes("text")).map(createCandidateModel);
	const candidate = [...candidates].sort(compareCandidateModels).at(0);
	const model = candidate?.model ?? options.currentModel;

	if (model === undefined) {
		throw new Error("No available model for automatic session naming");
	}

	return model;
}

function createCandidateModel(model: Model<Api>): CandidateModel {
	const candidate: CandidateModel = {
		model,
		preferenceRank: getModelPreferenceRank(model),
		reasoningRank: model.reasoning ? 1 : 0,
		score: model.cost.input * 4 + model.cost.output,
	};

	return candidate;
}

function compareCandidateModels(left: CandidateModel, right: CandidateModel): number {
	const comparisons = [
		left.reasoningRank - right.reasoningRank,
		left.preferenceRank - right.preferenceRank,
		left.score - right.score,
		getModelKey(left.model).localeCompare(getModelKey(right.model)),
	];
	const order = comparisons.find((comparison) => comparison !== 0) ?? 0;

	return order;
}

function getModelPreferenceRank(model: Model<Api>): number {
	const key = getModelKey(model).toLowerCase();
	const matchedIndex = CHEAP_MODEL_PREFERENCES.findIndex((preference) => key.includes(preference));
	const rank = matchedIndex === -1 ? CHEAP_MODEL_PREFERENCES.length : matchedIndex;

	return rank;
}

function getModelKey(model: Model<Api>): string {
	const key = `${model.provider}:${model.id}`;

	return key;
}

/** Count text-bearing user and assistant messages in the current branch transcript. */
function getMessageCounts(messages: readonly AgentMessage[]): MessageCounts {
	const counts = messages.reduce<MessageCounts>((total, message) => ({
		assistantMessageCount: total.assistantMessageCount + (message.role === "assistant" ? 1 : 0),
		userTurnCount: total.userTurnCount + (message.role === "user" ? 1 : 0),
	}), { assistantMessageCount: 0, userTurnCount: 0 });

	return counts;
}

/** Extract bounded transcript text while ignoring tool results and tool output. */
function getTextSamples(messages: readonly AgentMessage[]): TextSample {
	const userTexts = messages.filter(isUserMessage).map((message) => truncateText(getUserText(message), USER_SNIPPET_LENGTH)).filter((text) => text !== "");
	const assistantTexts = messages.filter(isAssistantMessage).map((message) => truncateText(getAssistantText(message), ASSISTANT_SNIPPET_LENGTH)).filter((text) => text !== "");
	const samples: TextSample = {
		assistantTexts: assistantTexts.slice(-RECENT_ASSISTANT_LIMIT),
		firstAssistantText: assistantTexts.at(0) === undefined ? undefined : truncateText(assistantTexts.at(0) ?? "", FIRST_SNIPPET_LENGTH),
		firstUserText: userTexts.at(0) === undefined ? undefined : truncateText(userTexts.at(0) ?? "", FIRST_SNIPPET_LENGTH),
		userTexts: userTexts.slice(-RECENT_USER_LIMIT),
	};

	return samples;
}

function getUserText(message: Extract<Message, { role: "user" }>): string {
	const text = typeof message.content === "string"
		? message.content
		: message.content.filter(isTextContent).map((content) => content.text).join("\n");

	return sanitizeSnippet(text);
}

function getAssistantText(message: AssistantMessage): string {
	const text = message.content.filter(isTextContent).map((content) => content.text).join("\n");

	return sanitizeSnippet(text);
}

/** Extract generated title text and explain empty model outputs with useful context. */
function getGeneratedTitleText(options: Readonly<{ model: Model<Api>; response: AssistantMessage }>): string {
	if (options.response.stopReason === "error") {
		throw new Error(`Naming model failed: ${getModelKey(options.model)} ${options.response.errorMessage ?? "unknown provider error"}`);
	}

	const text = getAssistantText(options.response);

	if (text !== "") {
		return text;
	}

	throw new Error(`Naming model returned no text: ${getModelKey(options.model)} stop=${options.response.stopReason}`);
}

function truncateText(text: string, maxLength: number): string {
	const truncated = text.length <= maxLength ? text : `${text.slice(0, maxLength - 1)}…`;

	return truncated;
}

function sanitizeSnippet(text: string): string {
	const snippet = text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();

	return snippet;
}

/** Find the latest valid provenance entry recorded by this extension. */
function getLatestProvenance(entries: readonly SessionEntry[]): AutoNameProvenance | undefined {
	const provenance = [...entries].reverse().find(isAutoNameEntry)?.data;

	return provenance;
}

function isAutoNameEntry(entry: SessionEntry): entry is Extract<SessionEntry, { type: "custom" }> & Readonly<{ data: AutoNameProvenance }> {
	const isAutoName = entry.type === "custom" && entry.customType === CUSTOM_TYPE && isAutoNameProvenance(entry.data);

	return isAutoName;
}

function isAutoNameProvenance(data: unknown): data is AutoNameProvenance {
	if (!isRecord(data)) {
		return false;
	}

	const isProvenance = typeof data.name === "string"
		&& typeof data.userTurnCount === "number"
		&& typeof data.assistantMessageCount === "number"
		&& typeof data.generatedAt === "string"
		&& data.extensionVersion === EXTENSION_VERSION;

	return isProvenance;
}

function getBranchMessages(entries: readonly SessionEntry[]): readonly AgentMessage[] {
	const messages = entries.filter(isSessionMessageEntry).map((entry) => entry.message);

	return messages;
}

function isSessionMessageEntry(entry: SessionEntry): entry is Extract<SessionEntry, { type: "message" }> {
	const isMessage = entry.type === "message";

	return isMessage;
}

function isRecord(data: unknown): data is Record<string, unknown> {
	const isObject = typeof data === "object" && data !== null;

	return isObject;
}

function isUserMessage(message: AgentMessage): message is Extract<Message, { role: "user" }> {
	const isUser = message.role === "user";

	return isUser;
}

function isAssistantMessage(message: AgentMessage): message is AssistantMessage {
	const isAssistant = message.role === "assistant";

	return isAssistant;
}

function isTextContent(content: unknown): content is TextContent {
	if (!isRecord(content)) {
		return false;
	}

	const isText = content.type === "text" && typeof content.text === "string";

	return isText;
}

/** Normalize model output before hard validation. */
function sanitizeTitle(title: string): string {
	const withoutPrefix = title.trim().replace(/^title\s*:\s*/i, "");
	const withoutWrappingQuotes = withoutPrefix.replace(/^["'`“”‘’]+|["'`“”‘’]+$/g, "");
	const sanitized = withoutWrappingQuotes.replace(/\s+/g, " ").trim();

	return sanitized;
}

/** Reject generic or malformed titles rather than writing bad session metadata. */
function validateTitle(title: string): string {
	const wordCount = title.split(/\s+/).filter((word) => word !== "").length;
	const isInvalid = title === ""
		|| title.length > TITLE_MAX_LENGTH
		|| title.includes("\n")
		|| /[.!?:]$/.test(title)
		|| wordCount > TITLE_MAX_WORDS
		|| GENERIC_TITLES.has(title.toLowerCase());

	if (isInvalid) {
		throw new Error(`Invalid generated session name: ${JSON.stringify(title)}`);
	}

	return title;
}

function notifyFailure(context: ExtensionContext, error: unknown): void {
	if (!context.hasUI) {
		return;
	}

	context.ui.notify(`Auto session name failed: ${getErrorMessage(error)}`, "error");
}

function getErrorMessage(error: unknown): string {
	const message = error instanceof Error ? error.message : String(error);

	return message;
}
