# Feature: Scope `--robot-triage` to a specific epic / subgraph

## Problem

`bv --robot-triage` operates globally across all open issues. There is no way to scope triage output to a specific epic or label subgraph.

This is a problem for orchestration tools that work **epic-by-epic**: the script selects an epic, fetches its open issues via `br dep tree <epicId>`, but then calls `bv --robot-triage` which returns recommendations across the *entire* project. The orchestrator has to post-filter recommendations by intersecting with the epic's issue set, which means:

1. **Irrelevant scores** — triage scores and reasons are computed in the context of the full graph. An issue that scores low globally might be the highest-priority item *within* the epic. The global ranking doesn't reflect intra-epic urgency.
2. **Wasted tokens / noise** — for AI consumers, the triage payload contains recommendations for hundreds of unrelated issues. This wastes context window and forces client-side filtering.
3. **Human review friction** — the whole point of working epic-by-epic is that a human can review changes scoped to a coherent feature. Global triage actively undermines this by not respecting that scope boundary.

## Proposed solution

Allow `--robot-triage` to accept a scoping parameter — either:

- **`--graph-root <epicId>`** — reuse the existing flag to scope triage to the subgraph rooted at the given issue (epic). This would be the most natural fit since `--graph-root` already exists for other commands.
- **`--label <label>`** — if the `--label` flag already scopes `--robot-insights` and `--robot-plan`, extending it to `--robot-triage` would be consistent.

When scoped, triage should:

- Only score and rank issues within the subgraph
- Compute "unblocks" counts relative to the subgraph (how many *in-scope* issues does this unblock?)
- Still surface cross-scope blockers, but annotated as such (e.g. `"external_blocker": true`)
- Adjust the `quick_ref` counts (`open_count`, `actionable_count`, `blocked_count`) to reflect the scope

## Expected usage

```bash
# Triage scoped to an epic
bv --robot-triage --graph-root EPIC-42

# Triage scoped to a label
bv --robot-triage --label backend-v2
```

## Why this matters for agent orchestration

Agent loops that process epics one-at-a-time need triage that respects scope boundaries. Without it, the triage layer — which is supposed to be the "smart" part — is actually the blind spot. The orchestrator knows which epic matters, but bv doesn't, so its recommendations are context-free where context matters most.
