---
name: vertical-plan
description: Creates implementation plans organized as small vertical, testable slices with TDD where applicable. Use when the user asks to create a development plan, plan before editing code, break implementation into vertical slices, or plan test-first work.
---

# Vertical Plan

## Purpose

Create a development plan before editing code. Prefer vertical, testable implementation slices over horizontal layer work.

A vertical slice delivers one small end-to-end behavior, can be tested independently, touches only necessary layers, and leaves the system working.

Avoid: database → service → UI → tests.
Prefer: happy path end-to-end → test → validation/error path → test → integration/polish → test.

## Rules

- Do not edit code before the plan is written.
- If paths or architecture are unknown, inspect first, then write or revise the plan.
- Use TDD when applicable: failing test → minimal code → passing test → refactor.
- Keep slices small; split any slice that cannot be verified quickly.
- Do not create broad abstractions before the first working slice.
- Be explicit about uncertainty.

## Workflow

1. Clarify the goal if needed.
2. Inspect only the files needed to plan responsibly.
3. Identify existing architecture, patterns, tests, and commands.
4. Draft vertical slices in execution order.
5. Attach tests, verification, risks, and rollback to each slice.
6. Surface open questions before implementation.

## Required plan structure

### 1. Goal

- Desired behavior
- User-visible outcome
- Explicit non-goals

### 2. Repo understanding

- Relevant architecture
- Existing patterns to follow
- Assumptions and unknowns

### 3. Files to inspect

For each file: filepath, why inspect it, what to look for.

### 4. Vertical slices

For each slice include: behavior delivered, why now, files likely modified, implementation steps, tests, commands, expected passing state.

Each slice must be independently useful or independently verifiable.

### 5. Design decisions

Chosen approach, alternatives rejected, API/interface changes, compatibility concerns, and slice ordering rationale.

### 6. Edge cases

Attach edge cases to the relevant slice where possible.

### 7. Verification

After every slice: compile/typecheck, targeted tests pass, no unrelated changes, system remains runnable.

Final verification: full test suite, lint/format, manual smoke test if relevant.

### 8. Risks and rollback

For each slice: risk, how to detect failure, rollback strategy.

### 9. Final report format

Report slices completed, files changed per slice, tests run per slice, failures, known limitations, and follow-up work.

## Execution loop when asked to implement

For each approved slice:

1. Write/update the smallest failing test.
2. Run it; confirm the expected failure.
3. Write minimal implementation code.
4. Run targeted tests until green.
5. Refactor only within the slice boundary.
6. Run typecheck/compile if available.
7. Report before continuing if risk or scope changed.

## Slice template

```md
#### Slice N: Name

- Behavior delivered:
- Why now:
- Files likely modified:
- Test first:
- Implementation steps:
- Commands:
- Expected passing state:
- Risks / detection / rollback:
```
