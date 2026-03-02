---
name: example-skill
description: Annotated example skill demonstrating all standard sections. Delete or replace with your first real skill.
---

# Example Skill

<!-- This is an annotated template. Each section below is standard for agent skills. -->
<!-- Delete this file once you have a real skill, or rename the folder. -->

A brief one-liner explaining what this skill does and when it's useful.

## Triggers

<!-- Natural language phrases that invoke this skill, plus the slash command -->

- "run the example"
- "show me how skills work"
- "/example-skill"

## Context Sources

<!-- What information does this skill need? List files, configs, MCP servers, other skills -->

| Source | Path / Tool | Purpose |
|--------|-------------|---------|
| Config | `config.local.yaml` | User-specific settings |
| AGENTS.md | `AGENTS.md` → Configuration section | Parametrized paths |

## Prerequisites

<!-- Step 0: Verify everything exists before proceeding -->
<!-- This is critical for agent-native execution — agents fail silently on missing prereqs -->

1. Verify config exists: `test -f config.local.yaml`
2. If missing: "Copy `config.template.yaml` to `config.local.yaml` and fill required fields."

## Workflow

### Step 1: Gather context

Read the relevant configuration and context files.

### Step 2: Execute

Perform the core action. Be explicit about tool names:
- Use `ToolSearch` to discover MCP tools before calling them
- Add `sleep` after async operations (page loads, API calls)

### Step 3: Output

Generate the deliverable and save to the configured output path.

## Output Format

<!-- Template or example of what this skill produces -->

```markdown
# Example Output

**Generated:** {date}

## Summary

{content}
```

## Guidelines

- Keep the skill focused on one clear purpose
- Parametrize all user-specific paths via AGENTS.md Configuration section
- Use explicit, full MCP tool names (or ToolSearch to discover them)
- Validate prerequisites before starting work
- Include success criteria for each step

## Anti-Patterns

- **Kitchen-sink skills** — too many responsibilities in one skill
- **Hardcoded paths** — always use AGENTS.md Configuration section
- **Missing triggers** — users can't discover the skill
- **Silent failures** — always surface errors with recovery instructions
- **Ambiguous instructions** — "look for" without specifying priority/fallback order
