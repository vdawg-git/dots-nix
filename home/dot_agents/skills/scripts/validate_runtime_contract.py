"""CI script: validates shared skills emit Pi-native runtime guidance."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

TEXT_GLOBS = [
    "AGENTS.md",
    "*/SKILL.md",
    "scripts/skills/**/*.py",
]

IGNORED_PARTS = {
    "__pycache__",
    "cc-history",  # Intentionally documents Claude Code history files and Task tool records.
    "papers",      # Research corpus, not executable guidance.
    # Matt Pocock prompt-only skills are upstream-owned; do not police them here.
    "codebase-design",
    "code-review",
    "diagnosing-bugs",
    "domain-modeling",
    "grilling",
    "grill-with-docs",
    "handoff",
    "improve-codebase-architecture",
    "prototype",
    "research",
    "resolving-merge-conflicts",
    "setup-matt-pocock-skills",
    "tdd",
    "teach",
    "ubiquitous-language",
    "writing-great-skills",
}

GENERATED_COMMANDS = [
    ["python3", "-m", "skills.codebase_analysis.analyze", "--step", "2"],
    ["python3", "-m", "skills.deepthink.think", "--step", "9"],
    ["python3", "-m", "skills.incoherence.incoherence", "--step-number", "3", "--thoughts", "test"],
    ["python3", "-m", "skills.refactor.refactor", "--step", "2", "--n", "2", "--mode", "code"],
]

FORBIDDEN_PATTERNS = [
    (re.compile(r"~/\.claude/skills/scripts"), "use ~/.agents/skills/scripts"),
    (re.compile(r"<invoke\b"), "use NEXT STEP / bash guidance, not Claude XML"),
    (re.compile(r"\bTask tool\b"), "use Pi subagent tool"),
    (re.compile(r"\bBash tool\b"), "use Pi bash tool name as `bash`"),
    (re.compile(r"\bsubagent_type\b"), "use subagent agent/task parameters"),
    (re.compile(r"agent=(['\"])(general-purpose|Explore|explore)\1"), "dispatch to a configured Pi agent"),
    (re.compile(r"agent_type=(['\"])(general-purpose|Explore|explore)\1"), "map legacy roles before emitting guidance"),
]


def iter_files() -> list[Path]:
    files: set[Path] = set()
    for glob in TEXT_GLOBS:
        files.update(ROOT.glob(glob))
    return sorted(
        p for p in files
        if p.is_file() and not (IGNORED_PARTS & set(p.parts))
    )


def collect_line_errors(label: str, text: str) -> list[str]:
    errors: list[str] = []
    in_forbidden_list = False
    for lineno, line in enumerate(text.splitlines(), 1):
        stripped = line.strip()
        if label == "AGENTS.md":
            if stripped == "### Forbidden in executable guidance":
                in_forbidden_list = True
                continue
            if in_forbidden_list and stripped.startswith("## "):
                in_forbidden_list = False
            if in_forbidden_list:
                continue
        for pattern, hint in FORBIDDEN_PATTERNS:
            if pattern.search(line):
                errors.append(f"{label}:{lineno}: {hint}: {line.strip()}")
    return errors


def main() -> None:
    errors: list[str] = []
    for path in iter_files():
        rel = path.relative_to(ROOT)
        errors.extend(collect_line_errors(str(rel), path.read_text(errors="ignore")))

    scripts_dir = ROOT / "scripts"
    for command in GENERATED_COMMANDS:
        result = subprocess.run(command, cwd=scripts_dir, text=True, capture_output=True, check=False)
        label = "generated:" + " ".join(command)
        if result.returncode != 0:
            errors.append(f"{label}: exited {result.returncode}: {result.stderr.strip()}")
        else:
            errors.extend(collect_line_errors(label, result.stdout))

    if errors:
        print("Runtime contract violations:")
        for error in errors:
            print(f"  {error}")
        sys.exit(1)

    print("Runtime contract validation passed")


if __name__ == "__main__":
    main()
