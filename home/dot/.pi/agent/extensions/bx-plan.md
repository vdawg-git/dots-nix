# Plan: Pi Web Search / Web Answer Extension

## Goal

Give Pi two semantic web tools:

- `web_search` — source discovery / web context with URLs.
- `web_answer` — synthesized web-grounded answer for broad current-facts questions.

The agent-facing surface must not mention the backend CLI, provider, API flags, or key names.

Backend implementation uses `brave-search-cli` / `bx` directly.

## Final decisions

### Tool names

Use generic semantic names:

```text
web_search
web_answer
```

Do not use provider-branded names like `brave_search` / `brave_answers`.

### Agent-facing guidance

Use only semantic guidance:

```text
Use web_search when URLs, evidence, docs, APIs, errors, versions, or source discovery matter.
Use web_answer for broad synthesized current-facts answers. It may not include source URLs.
web_answer may fall back to web_search; check status/mode in the JSON result.
```

Do **not** mention:

- `bx`
- Brave
- CLI
- shelling out
- `--api-key`
- key env vars
- backend endpoint names like `context` / `web`

### Backend

Use native `bx` directly via `pi.exec` argv.

No wrapper scripts.
No `bx config`.
No per-call env remapping.

Key usage:

```ts
pi.exec("bx", ["--api-key", process.env.BX_SEARCH_KEY!, "context", query, ...args], options)
pi.exec("bx", ["--api-key", process.env.BX_ANSWERS_KEY!, "answers", query, "--no-stream"], options)
```

Accepted tradeoff: `--api-key` can be visible in local process listings while the command runs. Do not log raw argv or expose key values in tool results.

### Key env vars

Expected to be available to Pi from fish:

```fish
set -gx BX_SEARCH_KEY "..."
set -gx BX_ANSWERS_KEY "..."
```

Pi receives these automatically when launched from that environment; subagents/tools inherit Pi’s process env.

Never print full key values.

### Extension placement

Create one global Pi extension:

```text
/home/vdawg/dotfiles/home/dot_pi/agent/extensions/web-search.ts
```

Global Pi extension dir:

```text
~/.pi/agent/extensions -> /home/vdawg/dotfiles/home/dot_pi/agent/extensions
```

Pi auto-loads:

```text
~/.pi/agent/extensions/*.ts
~/.pi/agent/extensions/*/index.ts
```

## Known backend facts

`bx` binary:

```text
/run/current-system/sw/bin/bx
```

Relevant backend commands:

```bash
bx context "query"
bx answers "question" --no-stream
```

`bx` accepts:

```text
--api-key <KEY>
```

`bx context` is the chosen search backend. Do not expose raw `web` backend in v1.

Reason: context is cleaner for agents: extracted, token-budgeted, source-oriented. Raw web/search-ranking features can be added later only if a concrete miss appears.

## Tool: `web_search`

### Purpose

Source discovery and source-grounded web context.

Use for:

- URLs / evidence
- docs and APIs
- error messages
- package/library behavior
- versions and release facts
- source discovery
- code/docs work

### Parameters

Expose only:

```ts
{
  query: string;
  maxResults?: number;
  includeSites?: string[];
}
```

Constraints:

```text
query: required, non-empty after trim
maxResults: integer, default 8, min 1, max 10
includeSites: optional domain list
```

No exposed:

- timeout
- token budget
- threshold
- country/language
- freshness
- exclude sites
- goggles
- raw backend mode

### Backend command shape

```ts
[
  "--api-key", searchKey,
  "context", query,
  "--count", String(maxResults),
  "--max-urls", String(maxResults),
  "--max-tokens", "6000",
  "--threshold", "balanced",
  ...includeSites.flatMap(site => ["--include-site", site]),
]
```

Timeout:

```text
20s fixed
```

### Output contract

Do not normalize or summarize backend output.

Parse backend stdout as JSON, then wrap parsed object in a stable envelope.

Successful content is pretty-printed JSON:

```json
{
  "status": "ok",
  "mode": "web_search",
  "result": {
    "...": "raw parsed backend JSON"
  }
}
```

Tool `details` should be minimal metadata only; do not duplicate bulky result:

```ts
{
  status: "ok",
  mode: "web_search",
  exitCode: 0
}
```

## Tool: `web_answer`

### Purpose

Broad synthesized web-grounded answer.

Use for:

- “what is…”
- “why…”
- “how does…”
- “compare…”
- “summarize…”
- broad current-facts questions

Prefer `web_search` instead when URLs/evidence/docs/API exactness matter.

### Parameters

Expose only:

```ts
{
  query: string;
}
```

No exposed:

- model
- citations
- entities
- research
- timeout
- source count

### Backend command shape

```ts
[
  "--api-key", answersKey,
  "answers", query,
  "--no-stream",
]
```

Timeout:

```text
30s fixed
```

### Streaming/citations/research

Do not implement streaming features in v1.

Reasons:

- citations/entities require streaming
- streaming stdout requires event/chunk parsing
- user reports streaming attempts often timed out
- upstream should ideally expose citations in non-streaming mode

Therefore v1 uses:

```text
--no-stream
```

No citations/entities/research.

### Success output

Parse backend stdout as JSON, then wrap parsed object.

Successful content:

```json
{
  "status": "ok",
  "mode": "web_answer",
  "result": {
    "...": "raw parsed backend JSON"
  }
}
```

## Fallback policy

`web_answer` falls back to `web_search` inside the same tool call on any non-auth/non-config backend failure.

Fallback triggers:

- rate limit
- timeout
- transient network failure
- backend non-zero exit, unless auth/config issue
- malformed JSON
- empty/invalid answer payload
- 5xx or similar upstream failure if detectable

Do **not** fallback on:

- missing `BX_ANSWERS_KEY`
- invalid/missing `BX_SEARCH_KEY` needed for fallback
- missing `bx` binary
- malformed user input
- auth/invalid key errors if clearly detectable

Fallback call:

```ts
runWebSearch({ query })
```

Uses normal `web_search` defaults:

```text
maxResults: 8
maxTokens: 6000
threshold: balanced
search timeout: 20s
```

No query rewriting. No inflated result count.

### Fallback output

If answer fails and fallback search succeeds:

```json
{
  "status": "fallback",
  "mode": "web_search_fallback",
  "reason": "answer_timeout",
  "result": {
    "...": "raw parsed web_search backend JSON"
  }
}
```

The agent can inspect `status` / `mode` / `reason`. Do not add prose instructions.

Worst-case duration:

```text
30s answer timeout + 20s search timeout ~= 50s
```

Accepted.

## Error policy

Expected failures should return JSON envelopes as tool content, not thrown tool errors.

Status vocabulary:

```ts
type Status = "ok" | "fallback" | "error";
```

Mode vocabulary:

```ts
type Mode = "web_search" | "web_answer" | "web_search_fallback";
```

Reason vocabulary:

```ts
type Reason =
  | "missing_key"
  | "command_failed"
  | "timeout"
  | "invalid_json"
  | "answer_rate_limited"
  | "answer_timeout"
  | "answer_failed"
  | "fallback_failed";
```

Examples.

Missing search key:

```json
{
  "status": "error",
  "mode": "web_search",
  "reason": "missing_key",
  "message": "Required key is not set"
}
```

Answer timeout and fallback failure:

```json
{
  "status": "error",
  "mode": "web_answer",
  "reason": "fallback_failed",
  "primaryError": {
    "reason": "answer_timeout"
  },
  "fallbackError": {
    "reason": "timeout"
  }
}
```

Throw only for unexpected extension bugs that cannot sensibly be serialized.

## Content / details contract

Visible tool content should be exactly pretty-printed JSON envelope:

```ts
JSON.stringify(envelope, null, 2)
```

This keeps output readable and `jq`-friendly after copy/paste.

Do not prepend prose.
Do not summarize backend output.
Do not duplicate normalized results.

Tool details should be minimal metadata only:

```ts
{
  status,
  mode,
  reason?,
  exitCode?
}
```

Never include API keys or raw argv in content/details.

## Implementation notes

Use `pi.exec`, direct argv, no shell interpolation:

```ts
const result = await pi.exec("bx", args, {
  cwd: ctx.cwd,
  signal,
  timeout,
});
```

Benefits:

- no shell quoting hazards
- no wrapper script
- simple cancellation
- simple stdout/stderr/code handling

Need schema import for tool params. Docs use:

```ts
import { Type } from "typebox";
```

Potential issue: local `node require.resolve('typebox')` from extension dir failed, while Pi’s global docs/examples assume it is available. Verify during implementation. If needed, add runtime dependency or use another Pi-supported schema source.

## Testing plan

Check env without printing secrets:

```bash
test -n "$BX_SEARCH_KEY" && echo BX_SEARCH_KEY=set
test -n "$BX_ANSWERS_KEY" && echo BX_ANSWERS_KEY=set
```

Backend smoke tests:

```bash
bx --api-key "$BX_SEARCH_KEY" context "test" --count 2 --max-urls 2 --max-tokens 512
bx --api-key "$BX_ANSWERS_KEY" answers "test" --no-stream
```

Type/check:

```bash
bunx tsc --noEmit
```

Runtime:

```text
/reload
```

Then test semantic tools:

```text
Use web_search for current TypeScript 5.9 release notes.
Use web_answer to explain what changed in React 19.
```

## Implementation order

1. Verify `BX_SEARCH_KEY` and `BX_ANSWERS_KEY` are visible to Pi.
2. Create `web-search.ts` extension.
3. Register `web_search` and `web_answer` tools.
4. Implement `runBxJson` helper:
   - direct `pi.exec`
   - timeout handling
   - JSON parse
   - redacted metadata
5. Implement `web_search` envelope.
6. Implement `web_answer` envelope plus same-call fallback.
7. Resolve schema import issue if present.
8. Run `bunx tsc --noEmit`.
9. `/reload` Pi.
10. Smoke test both tools.

## Open questions

None blocking for v1.
