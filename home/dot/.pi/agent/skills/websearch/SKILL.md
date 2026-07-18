---
name: websearch
description: Runs regular Brave Search queries through the `bx` CLI and turns search results into cited findings. Use whenever external or current public information would improve the answer, including web search requests, freshness-sensitive facts, public-source comparison, or Brave Search usage; never use Brave Answers/API-style answer generation.
---

# Web Search

## Boundary

Use `bx` only for regular Brave Search result retrieval. Do **not** use Brave Answers, answer-generation endpoints, AI summaries, or any `bx` mode/flag that asks Brave to synthesize an answer.

The agent may synthesize findings itself from returned search results and fetched pages, with citations.

## Quick start

1. Use this skill whenever external or current public information would improve the answer; explicit permission is not required.
2. Convert the user's request into a concise search query.
3. Run a regular search with `bx`.
3. Inspect result titles, snippets, URLs, and dates if present.
4. Inspect result titles, snippets, URLs, and dates if present.
5. Fetch promising pages with `web_fetch` when the answer depends on page content, not just discovery.
6. Answer with cited URLs and note uncertainty when sources conflict.

Example:

```bash
bx "site:example.com release notes product name 2026"
```

## Workflow

- Clarify when the query scope is ambiguous: timeframe, jurisdiction, product version, or source type.
- Prefer precise queries over broad ones; use operators such as `site:`, quoted phrases, and exclusion terms when useful.
- Run follow-up searches when first results are sparse, SEO-heavy, stale, or contradictory.
- Treat snippets as leads, not evidence. Use `web_fetch` for claims that matter.
- Prefer primary sources: official docs, release notes, standards, repositories, filings, papers.
- Cite the final answer with source URLs.

## Prohibited use

Never invoke:

- Brave Answers API
- AI answer/summary modes in `bx`
- Flags or subcommands whose purpose is generated answers rather than ordinary search results

If `bx --help` reveals both search and answer modes, choose only the regular search mode. If unsure whether a flag uses Answers, do not use it.

## Failure handling

- If `bx` is missing, say so and ask whether to install/configure it; do not substitute another search tool silently.
- If authentication or quota fails, report the exact error class and stop.
- If results are low quality, revise the query before answering.
