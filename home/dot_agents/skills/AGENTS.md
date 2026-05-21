# skills/

Pi-native, script-backed agent skills.

## MANDATORY: Read Before Modifying

Before editing any Python file in `skills/scripts/`, read `README.md`.

The README defines:

- file section ordering
- prompt constant naming
- dispatch prompt structure
- workflow step formatting
- anti-patterns to avoid

## Runtime Contract

These skills target Pi and other harnesses through the neutral agents home.

### Script invocation

Run Python skill scripts as modules from the neutral scripts root:

```text
Working directory: ~/.agents/skills/scripts
Command: python3 -m skills.<skill_name>.<module> --step 1
```

Example:

```text
Working directory: ~/.agents/skills/scripts
Command: python3 -m skills.problem_analysis.analyze --step 1
```

### Tool protocol

Executable guidance must use Pi tools:

- run shell commands with `bash`
- dispatch agents with `subagent`
- pass `subagent` arguments as `agent` and `task`

Configured Pi agents:

- `architect`
- `debugger`
- `developer`
- `quality-reviewer`
- `technical-writer`

### Forbidden in executable guidance

Do not emit Claude tool protocol from shared skills:

- `~/.claude/skills/scripts`
- `<invoke ...>`
- `Task tool`
- `Bash tool`
- `subagent_type`
- dispatch target `general-purpose`
- dispatch target `Explore`

Claude-specific paths may appear only in skills that intentionally analyze Claude data, such as Claude Code history under `~/.claude/projects/`.

## Files

| File        | What                                                      | When to read                    |
| ----------- | --------------------------------------------------------- | ------------------------------- |
| `AGENTS.md` | Pi runtime contract                                      | Before changing activation/dispatch behavior |
| `README.md` | File organization, prompt patterns, naming, anti-patterns | Before modifying skill code     |

## Subdirectories

| Directory             | What                                      |
| --------------------- | ----------------------------------------- |
| `scripts/`            | Python package root for all skill code    |
| `planner/`            | Planning and execution workflows          |
| `refactor/`           | Refactoring analysis across dimensions    |
| `problem-analysis/`   | Structured problem decomposition          |
| `decision-critic/`    | Decision stress-testing and critique      |
| `deepthink/`          | Structured reasoning for open questions   |
| `codebase-analysis/`  | Systematic codebase exploration           |
| `prompt-engineer/`    | Prompt optimization and engineering       |
| `incoherence/`        | Consistency detection                     |
| `cc-history/`         | Claude Code conversation history analysis |
