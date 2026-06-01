---
name: prd-to-beads
description: Break a PRD into independently-grabbable beads using tracer-bullet vertical slices. Use when user wants to convert a PRD to beads, create implementation tickets, or break down a PRD into work items.
disable-model-invocation: true
---

# PRD to Beads

Break a PRD into independently-grabbable beads using vertical slices (tracer bullets).

## Process

### 1. Locate the PRD

Ask the user for the PRD epic bead ID.

If the PRD is not already in your context window, fetch it with `bd show <id>`.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.

### 3. Draft vertical slices

Break the PRD into **tracer bullet** beads. Each bead is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories from the PRD this addresses

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### 5. Create the beads

For each approved slice, create a bead using `bd create`. Create in dependency order (blockers first) so you can capture real bead IDs for the `--deps` flag.

Use `--silent` to capture the bead ID for dependency wiring:

```sh
BEAD_ID=$(bd create "<Slice title>" \
  --type feature \
  --parent <epic-id> \
  -p 2 \
  -d "<description>" \
  --acceptance "<criteria>" \
  --design "<design-notes>" \
  --deps "blocks:<blocker-id>" \
  -l "<HITL-or-AFK>" \
  --silent)
```

Use `--body-file` when description content is long.

#### Field mapping — pack maximum context into each bead

**`--description`**: Write a self-contained narrative an agent can act on alone. Include:
- What end-to-end behavior this slice delivers
- The relevant user stories from the PRD, **inlined** (not just "User story 3")
- Architectural context: which layers are touched and how they interact
- Parent epic reference: "Part of PRD epic `<epic-id>`"

**`--acceptance`**: Concrete verification criteria as a markdown checklist.
- Each criterion is independently testable
- Include both happy-path and edge-case criteria
- Include "Tests pass" when applicable

**`--design`**: Implementation guidance for an agent picking this up:
- Modules and files likely involved (these are hints — they may have moved since writing)
- Interface changes or new interfaces needed
- Testing strategy: what to test, what prior art exists in the codebase
- Edge cases and gotchas surfaced during the PRD
- Schema or API contract changes if relevant

**`--deps`**: `"blocks:<bead-id>"` for each blocker. Multiple: `--deps "blocks:<id1>" --deps "blocks:<id2>"`

**`--parent`**: Always the PRD epic bead ID.

**`-l`** (labels): `HITL` or `AFK`.

**`--type`**: `feature` for new functionality, `task` for infrastructure/setup, `chore` for cleanup.

#### After creation

Print the dependency tree:

```sh
bd dep tree <epic-id>
```

Do NOT close or modify the parent PRD epic bead.
