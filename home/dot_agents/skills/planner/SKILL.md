---
name: planner
description: Interactive planning and execution for complex tasks. IMMEDIATELY invoke when user asks to use planner.
disable-model-invocation: true
---

## Activation

When this skill activates, IMMEDIATELY invoke the corresponding script. The
script IS the workflow.

| Mode      | Intent                             | Command                                                                                                          |
| --------- | ---------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| planning  | "plan", "design", "architect"      | Run with `bash`: `cd ~/.agents/skills/scripts && python3 -m skills.planner.orchestrator.planner --step 1`  |
| execution | "execute", "implement", "run plan" | Run with `bash`: `cd ~/.agents/skills/scripts && python3 -m skills.planner.orchestrator.executor --step 1` |
