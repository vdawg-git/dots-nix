"""Plain-text dispatch prompt building blocks.

Composition via f-strings. No XML, no AST.

Three dispatch patterns:
- subagent_dispatch: Single agent, optional prompt, mandatory invoke command
- template_dispatch: Parallel agents, template with $var substitution per agent
- roster_dispatch: Parallel agents, shared context + unique tasks, fixed command
"""

from string import Template

from skills.lib.workflow.prompts.step import self_contained_command


# ============================================================================
# CONFIGURATION
# ============================================================================

SKILLS_DIR = "~/.agents/skills/scripts"


# ============================================================================
# SHARED PROMPTS
# ============================================================================
# Building block templates used by multiple dispatch patterns

SUBAGENT_TOOL_INSTRUCTION = """\
ACTION: Use the `subagent` tool to spawn this agent.

subagent parameters:
  - agent: {agent_name}
  - task: Include the task and invoke command below

Note: requested role `{agent_type}` maps to Pi agent `{agent_name}`. Model selection is handled by the agent definition; ignore requested model `{model_param}`."""

SUB_AGENT_INVOKE = """\
MANDATORY INVOKE BLOCK - Copy VERBATIM into the agent's task:
================================================================================
FIRST ACTION REQUIRED: Run this command via `bash` before any other response.
Do NOT skip. Do NOT produce analysis first. Execute this command IMMEDIATELY.

Working directory: {working_dir}
Command: {cmd}
================================================================================
CRITICAL: Copy the block above EXACTLY. Do not paraphrase or summarize.
The subagent needs "FIRST ACTION REQUIRED" to know it must run the command."""

PARALLEL_CONSTRAINT = """\
PARALLEL EXECUTION (MANDATORY):
    You MUST dispatch ALL {count} agents in ONE assistant message.
    Send exactly {count} `subagent` tool calls together.

    CORRECT:
        [ONE message with subagent call 1, subagent call 2, ... subagent call N]

    WRONG:
        [Message with subagent call 1] -> [wait] -> [Message with subagent call 2]

    FORBIDDEN: Waiting for any agent before dispatching the next."""


# ============================================================================
# MESSAGE TEMPLATES
# ============================================================================

# --- SUBAGENT DISPATCH (Single Agent) ---------------------------------------

SUBAGENT_TEMPLATE = """\
DISPATCH SUB-AGENT
==================

{task_tool_block}

TASK FOR THE SUB-AGENT:
{task_section}

{invoke_block}

After the sub-agent returns, continue with the next workflow step."""

# --- TEMPLATE DISPATCH (Parallel, Variable Substitution) --------------------

TEMPLATE_DISPATCH_TEMPLATE = """\
DISPATCH {count} PARALLEL AGENTS
================================

{parallel_block}

For EACH agent below, use the `subagent` tool with:
  - agent: {agent_name}
  - task: Task description + MANDATORY INVOKE BLOCK (copy exactly as shown)

PROMPT CONSTRUCTION RULES:
  - The MANDATORY INVOKE BLOCK must appear VERBATIM in each task
  - DO NOT reduce it to just "Working directory: X / Command: Y"
  - The subagent needs "FIRST ACTION REQUIRED" to execute the command

{instruction_section}AGENTS:
{agents_section}

After ALL {count} agents return, continue with the next workflow step."""

TEMPLATE_AGENT_ENTRY = """\
--- Agent {index} ---
Task: {prompt}

{invoke_block}"""

# --- ROSTER DISPATCH (Parallel, Unique Tasks) -------------------------------

ROSTER_DISPATCH_TEMPLATE = """\
DISPATCH {count} PARALLEL AGENTS
================================

{parallel_block}

For EACH agent below, use the `subagent` tool with:
  - agent: {agent_name}
  - task: Shared context + agent's unique task + MANDATORY INVOKE BLOCK (copy exactly)

PROMPT CONSTRUCTION RULES:
  - The MANDATORY INVOKE BLOCK must appear VERBATIM in each task
  - DO NOT reduce it to just "Working directory: X / Command: Y"
  - The subagent needs "FIRST ACTION REQUIRED" to execute the command

{instruction_section}{shared_context_section}AGENTS:
{agents_section}

After ALL {count} agents return, continue with the next workflow step."""

ROSTER_AGENT_ENTRY = """\
--- Agent {index} ---
Unique Task: {task}

{invoke_block}"""


# ============================================================================
# MESSAGE BUILDERS
# ============================================================================

# --- Building block functions -----------------------------------------------

def pi_agent_name(agent_type: str) -> str:
    """Map Claude-style agent roles to configured Pi agents."""
    return {
        "general-purpose": "developer",
        "Explore": "developer",
        "explore": "developer",
    }.get(agent_type, agent_type)


def subagent_tool_instruction(agent_type: str, model: str | None) -> str:
    """Tell main agent how to spawn sub-agent via Pi subagent tool."""
    model_param = model if model else "default"
    return SUBAGENT_TOOL_INSTRUCTION.format(
        agent_type=agent_type,
        agent_name=pi_agent_name(agent_type),
        model_param=model_param,
    )


def sub_agent_invoke(cmd: str) -> str:
    """Tell sub-agent what command to run after spawning."""
    return SUB_AGENT_INVOKE.format(
        working_dir=SKILLS_DIR,
        cmd=self_contained_command(cmd),
    )


def parallel_constraint(count: int) -> str:
    """Enforce MANDATORY_PARALLEL execution for multiple agents."""
    return PARALLEL_CONSTRAINT.format(count=count)


# --- Dispatch pattern functions ---------------------------------------------

def subagent_dispatch(
    agent_type: str,
    command: str,
    prompt: str = "",
    model: str | None = None,
) -> str:
    """Generate prompt for single sub-agent dispatch.

    Args:
        agent_type: requested agent role (e.g., "general-purpose", "Explore")
        command: Shell command sub-agent must run after spawning
        prompt: Optional task description for sub-agent
        model: Optional model override ("haiku", "sonnet", "opus")

    Returns:
        Complete dispatch prompt as plain text
    """
    task_section = prompt if prompt else "(No additional task - agent follows invoke command)"

    return SUBAGENT_TEMPLATE.format(
        task_tool_block=subagent_tool_instruction(agent_type, model),
        task_section=task_section,
        invoke_block=sub_agent_invoke(command),
    )


def template_dispatch(
    agent_type: str,
    template: str,
    targets: list[dict[str, str]],
    command: str,
    model: str | None = None,
    instruction: str | None = None,
) -> str:
    """Generate prompt for parallel dispatch with variable substitution.

    Template and command use $var syntax. Variables are substituted per-target
    before the LLM sees the prompt (expansion happens here, not at runtime).

    Args:
        agent_type: requested agent role for all agents
        template: Prompt template with $var placeholders
        targets: List of dicts, each providing variable bindings for one agent
        command: Command template with $var placeholders
        model: Optional model override for all agents
        instruction: Optional instruction text

    Returns:
        Complete dispatch prompt with expanded agent entries

    Raises:
        KeyError: If template contains $var not present in target dict
    """
    expanded = []
    for t in targets:
        expanded.append({
            "prompt": Template(template).substitute(t),
            "command": Template(command).substitute(t),
        })

    count = len(expanded)
    model_display = model if model else "default (omit parameter)"
    instruction_section = f"NOTE: {instruction}\n\n" if instruction else ""

    agents_lines = []
    for i, e in enumerate(expanded, 1):
        agents_lines.append(TEMPLATE_AGENT_ENTRY.format(
            index=i,
            prompt=e["prompt"],
            invoke_block=sub_agent_invoke(e["command"]),
        ))

    return TEMPLATE_DISPATCH_TEMPLATE.format(
        count=count,
        agent_type=agent_type,
        agent_name=pi_agent_name(agent_type),
        model_display=model_display,
        parallel_block=parallel_constraint(count),
        instruction_section=instruction_section,
        agents_section="\n\n".join(agents_lines),
    )


def roster_dispatch(
    agent_type: str,
    agents: list[str],
    command: str,
    shared_context: str = "",
    model: str | None = None,
    instruction: str | None = None,
) -> str:
    """Generate prompt for parallel dispatch with unique tasks per agent.

    Each agent receives shared_context + their unique task + the fixed command.
    Use when agents have fundamentally different roles (MIMD pattern).

    Args:
        agent_type: requested agent role for all agents
        agents: List of unique task descriptions, one per agent
        command: Fixed command all agents run (same for all)
        shared_context: Optional context included in every agent's prompt
        model: Optional model override for all agents
        instruction: Optional instruction text

    Returns:
        Complete dispatch prompt with agent entries
    """
    count = len(agents)
    model_display = model if model else "default (omit parameter)"
    instruction_section = f"NOTE: {instruction}\n\n" if instruction else ""
    shared_context_section = f"SHARED CONTEXT (include in every agent's prompt):\n{shared_context}\n\n" if shared_context else ""

    agents_lines = []
    for i, task in enumerate(agents, 1):
        agents_lines.append(ROSTER_AGENT_ENTRY.format(
            index=i,
            task=task,
            invoke_block=sub_agent_invoke(command),
        ))

    return ROSTER_DISPATCH_TEMPLATE.format(
        count=count,
        agent_type=agent_type,
        agent_name=pi_agent_name(agent_type),
        model_display=model_display,
        parallel_block=parallel_constraint(count),
        instruction_section=instruction_section,
        shared_context_section=shared_context_section,
        agents_section="\n\n".join(agents_lines),
    )


__all__ = [
    # Building blocks
    "subagent_tool_instruction",
    "sub_agent_invoke",
    "parallel_constraint",
    "pi_agent_name",
    # Dispatch templates
    "subagent_dispatch",
    "template_dispatch",
    "roster_dispatch",
]
