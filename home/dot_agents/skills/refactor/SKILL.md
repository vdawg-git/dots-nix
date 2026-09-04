---
name: refactor
description: Use when the user requests refactoring analysis, technical debt review, code smell hunting, architecture cleanup, or code quality improvement. Dispatch focused subagents directly; do not invoke Python scripts.
---

# Refactor

Use this skill to find refactoring opportunities that are supported by evidence. It does **not** change code. It produces a prioritized report of work items.

The workflow is scriptless: you, the main agent, orchestrate exploration through `subagent` calls, then triage, cluster, prioritize, and synthesize the findings.

## Core Rule

Do not wander the codebase alone before dispatching. First determine scope and analysis mode, then send focused explorers with detailed instructions.

If the user gives a narrow target, honor it. If they give no scope, analyze the current repository.

## Inputs to Infer

Infer these from the user request:

| Input | Meaning | Default |
| --- | --- | --- |
| `scope` | Directory, module, file, or whole repo to inspect | current repository |
| `mode` | `design`, `code`, `both`, or `custom` | `both` |

Choose `n` by scope:

- Small: single file, narrow concern, quick look → `n = 5`
- Medium: module, directory, ordinary refactor review → `n = 10`
- Large: whole repo, thorough/comprehensive review → `n = 20-25`

## Category Sources

Use the code quality convention documents under:

```text
~/.agents/conventions/code-quality/
```

Categories are numbered headings in those files. Treat their grep hints and violation lists as **illustrative, not exhaustive**. Translate them into project-specific patterns before searching.

Prefer categories that fit the user’s focus. If there is no focus, choose a varied mix across naming, structure, duplication, tests, modules, dependencies, cross-file consistency, and architecture.

## Workflow

### 1. Select Categories

Pick categories from the convention docs according to `mode`:

- `design`: architecture, seams, module boundaries, abstractions, domain clarity, dependency direction
- `code`: local code quality, naming, function shape, duplication, tests, idioms, error handling
- `both`: a balanced mix
- `custom`: choose only categories tightly related to the user's stated concern

Avoid overfitting to category names. The question is not “which headings sound relevant?” but “which lenses are most likely to reveal evidence-backed friction in this codebase?”

### 2. Dispatch Explorers in Parallel

Dispatch one `subagent` per selected category. Use the `explore` agent when available; otherwise use `developer` for read-only exploration. The task must forbid edits.

Each explorer must receive enough context to work without the script. Use this task shape:

```text
You are exploring one refactoring/code-quality category for evidence-backed findings.

Repository: <repo path>
Scope: <scope or "whole repository">
Mode: <design|code|both|custom>
Category: <category title and source file if known>
User focus: <focus or "none">

Do not edit files.
Do not propose speculative refactors.
Do not report a smell from a single weak example unless the category threshold explicitly allows it.
Prefer patterns seen 3+ times, or a single severe boundary/architecture violation with clear blast radius.

Work in five phases:

1. Domain context
   - Identify the project language/framework/runtime.
   - Identify the relevant module boundaries, naming conventions, and common patterns in the given scope.
   - Note what “normal” looks like here before calling anything a smell.

2. Principle and violation model
   - Restate the category’s core principle in project-specific terms.
   - Define what would count as a real violation in this repository.
   - Define exceptions: cases that may look suspicious but should not be flagged.

3. Search plan
   - Translate generic grep hints into project-specific searches.
   - Include exact commands or ripgrep patterns you used or would use.
   - Search beyond literal names; look for analogous structures.

4. Evidence gathering
   - Inspect files and collect concrete evidence.
   - Include file paths, line references where possible, short code quotes, and occurrence counts.
   - Distinguish verified counts from rough estimates.

5. Smell report
   Return a concise report with:
   - Category
   - Summary judgment: found / weak signal / no finding
   - Evidence-backed findings
   - Occurrence count and verification method
   - Representative locations
   - Why this matters
   - Suggested refactoring direction, not implementation
   - False positives or exceptions considered
```

Use one assistant turn to dispatch the explorers in parallel where possible.

### 3. Triage Findings

After explorers return, convert their reports into structured smells.

For each smell, capture:

- `id`: stable short identifier, e.g. `S1`, `S2`
- category
- summary
- evidence: code quote, file path, line reference if available
- occurrences: count, locations, verification method
- impact
- confidence: high / medium / low
- original explorer category

Reject findings that lack evidence, merely predict future problems, or rest on taste alone.

### 4. Cluster by Root Cause

Group smells that share an underlying cause. Do not produce one work item per smell if several are symptoms of the same broken seam.

For each cluster, identify:

- root cause
- included smell IDs
- representative evidence
- likely affected area
- why fixing this cluster would remove multiple symptoms
- rejected or superseded smells

### 5. Contextualize Against User Intent

Read the user’s original request again. Prioritize clusters by what they asked for, not by what seems theoretically elegant.

Prefer work that is:

1. Evidenced by repeated friction
2. Local enough to complete safely
3. Likely to simplify future changes
4. Not speculative
5. Compatible with the project’s existing style

Call out constraint conflicts. For example: “The user asked for quick cleanup, but the highest-impact issue is architectural and broad.”

### 6. Synthesize Final Report

Return a decision-ready Markdown report:

```markdown
# Refactor Report

## Summary
- Scope analyzed:
- Mode:
- Categories explored:
- Highest-value finding:

## Recommended Work Items

### 1. <action-oriented title>
**Root cause:** ...
**Evidence:** ...
**Affected areas:** ...
**Why now:** ...
**Refactoring direction:** ...
**Risk:** Low/Medium/High
**Smells addressed:** S1, S3, ...

## Superseded or Rejected Findings
- <finding>: rejected because <reason>

## Execution Notes
- Suggested order of work
- Tests or verification likely needed
- Open questions
```

Keep the report practical. The user should be able to choose the first work item and begin.

## Evidence Standards

A finding is strong when it has:

- Concrete file paths
- Code quotes or line references
- Multiple occurrences, or one severe boundary violation
- A clear explanation of present friction
- A refactoring direction that removes complexity rather than moving it

Kill findings that are:

- Based on imagined future requirements
- Merely stylistic preferences
- Single-instance abstractions without proven repetition
- Vague: “clean up utils,” “improve naming,” “make modular”
- Unsupported by code evidence

## Refactoring Philosophy

Use these tests before recommending work:

| Principle | Test |
| --- | --- |
| Composability | Will this make pieces combine more cleanly? |
| Precision | Does the proposed name or seam create real semantic clarity? |
| No speculation | Is there observed friction, preferably 3+ examples? |
| Simplicity | Is this the smallest change that removes the friction? |

Recommendations should deepen modules, sharpen boundaries, reduce duplication, or make intent easier to see. Do not chase ornamental purity.

## What This Skill Does Not Do

- It does not replace tests, linters, or static analysis.
- It does not recommend abstractions unsupported by evidence.
