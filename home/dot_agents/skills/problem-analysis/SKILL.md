---
name: problem-analysis
description: Invoke IMMEDIATELY via python script when user requests problem analysis or root cause investigation. Do NOT explore first - the script orchestrates the investigation.
disable-model-invocation: true
---

# Problem Analysis

Root cause identification skill. Identifies WHY a problem occurs, NOT how to fix
it.

## Invocation

Run with `bash`: `cd ~/.agents/skills/scripts && python3 -m skills.problem_analysis.analyze --step 1`.

Do NOT explore or analyze first. Run the script and follow its output.
