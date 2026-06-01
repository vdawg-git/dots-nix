"""Step assembly for workflow prompts.

format_step() is the sole assembler. invoke_after logic is internal.
"""

SKILLS_DIR = "~/.agents/skills/scripts"


def self_contained_command(cmd: str, working_dir: str = SKILLS_DIR) -> str:
    """Return a shell command that does not depend on tool cwd."""
    stripped = cmd.strip()
    if not stripped:
        return stripped
    if stripped.startswith(("cd ", "pushd ")):
        return stripped
    return f"cd {working_dir} && {stripped}"


def format_step(body: str, next_cmd: str = "", title: str = "",
                if_pass: str = "", if_fail: str = "") -> str:
    """Assemble complete workflow step: title + body + invoke directive.

    Args:
        body: Free-form prompt content (no wrapper needed)
        next_cmd: Command for next step (empty string signals completion)
        title: Optional title rendered as "TITLE\\n======\\n\\n" header
        if_pass: Branching command when QR gate passes
        if_fail: Branching command when QR gate fails

    Returns:
        Complete step output as plain text
    """
    if title:
        header = f"{title}\n{'=' * len(title)}\n\n"
        body = header + body

    if if_pass and if_fail:
        # Branching invoke for QR gate routing: the LLM chooses based on
        # aggregated QR outcome (all pass vs any fail).
        invoke = (
            f"NEXT STEP (MANDATORY -- execute exactly one):\n"
            f"    Working directory: {SKILLS_DIR}\n"
            f"    ALL agents returned PASS  ->  {self_contained_command(if_pass)}\n"
            f"    ANY agent returned FAIL   ->  {self_contained_command(if_fail)}\n\n"
            f"This is a mechanical routing decision. Do not interpret, summarize, "
            f"or assess the results.\n"
            f"Count PASS vs FAIL, then execute the matching command."
        )
        return f"{body}\n\n{invoke}"

    elif next_cmd:
        # Working directory is explicit because CLI execution context varies.
        # Command is literal shell invocation for next step.
        invoke = (
            f"NEXT STEP:\n"
            f"    Working directory: {SKILLS_DIR}\n"
            f"    Command: {self_contained_command(next_cmd)}\n\n"
            f"Execute this command now."
        )
        return f"{body}\n\n{invoke}"

    else:
        return f"{body}\n\nWORKFLOW COMPLETE - Return the output from the step above. Do not summarize."
