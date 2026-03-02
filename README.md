# template-agent

> [!WARNING]
> **Experimental** — This project is under active development and subject to breaking changes, refactoring, and restructuring without notice. It is provided as-is with no warranty of any kind. Use at your own risk.

Cookiecutter template for Claude Code agent repositories. Distills patterns from the [ryaniosys multi-agent ecosystem](https://github.com/ryaniosys/agent-atlas).

## Quick Start

1. **Clone or use as template:**
   ```bash
   gh repo create ryaniosys/my-new-agent --private --template ryaniosys/template-agent --clone
   # Or manually:
   git clone git@github.com:ryaniosys/template-agent.git my-new-agent
   cd my-new-agent && rm -rf .git && git init
   ```

2. **Customize:**
   - Search for `<!-- CUSTOMIZE -->` markers in `AGENTS.md` and `PRD.md`
   - Replace agent name, purpose, paths, and domain-specific sections
   - Delete `example-skill/` once you have a real skill

3. **Configure:**
   ```bash
   cp config.template.yaml config.local.yaml
   cp .env.example .env
   # Fill in your values
   ```

4. **Add skills:** Create `.claude/skills/{name}/SKILL.md` — see the example skill for structure.

5. **Register in agent-atlas:** Add your repo to `agent-atlas/content/current.yaml` so it's tracked in architecture snapshots.

## What's Included

| File | Purpose |
|------|---------|
| `CLAUDE.md` | One-liner `@AGENTS.md` redirect (Claude Code convention) |
| `AGENTS.md` | Primary instruction doc with `<!-- CUSTOMIZE -->` markers |
| `PRD.md` | Product vision and roadmap template |
| `.claude/settings.json` | Hard-deny rules blocking secret file reads (committed, shared) |
| `.claude/settings.local.json` | User-specific allows/denies (gitignored, create your own) |
| `.claude/skills/example-skill/` | Annotated skill template with all standard sections |
| `config.template.yaml` | Configurable settings schema |
| `.env.example` | Environment variable template |
| `.gitignore` | Comprehensive ignore rules (secrets, data, caches) |
| `scripts/run_in_venv.sh` | Python venv runner (auto-creates `/tmp/{repo}-venv`) |
| `instructions/INSTRUCTIONS.md` | Detailed workflow docs (progressive disclosure layer 2) |
| `docs/solutions/` | Knowledge base scaffold with category structure |
| `tasks/lessons.md` | Self-improvement loop log |
| `persona/` | Optional: writing style guide |

## Key Design Decisions

### Two files, two audiences

- **`README.md`** (this file) — for humans. Setup, rationale, references.
- **`AGENTS.md`** — for the agent. Loaded into context every session. Keep it lean.
- **`CLAUDE.md`** — one-liner `@AGENTS.md` redirect. Never put content here.

### Settings: committed vs. local

Claude Code has a [documented settings hierarchy](https://code.claude.com/docs/en/settings):

```
~/.claude/settings.json          → global (all projects)
.claude/settings.json            → project (committed, shared)
.claude/settings.local.json      → local (gitignored, personal)
```

Precedence: **local > project > global**. This template uses:

- **`.claude/settings.json`** (committed) — shared deny rules that protect secrets. Every clone gets these.
- **`.claude/settings.local.json`** (gitignored) — your personal allow/deny rules, MCP server toggles, additional directories. Claude Code auto-adds this to `.gitignore` on creation.

### Progressive disclosure

Instructions are layered for context window efficiency:

```
AGENTS.md            → Skim (always loaded, key reference tables)
instructions/*.md    → Read (detailed workflows, loaded on demand)
docs/solutions/*     → Deep dive (problem → solution knowledge base)
```

### Template-to-local config

All user-specific values follow the same pattern: a committed template documenting the schema, and a gitignored local copy with actual values.

| Committed (schema) | Gitignored (values) |
|---------------------|---------------------|
| `config.template.yaml` | `config.local.yaml` |
| `.env.example` | `.env` |
| `.claude/settings.json` | `.claude/settings.local.json` |

## Conventions

This template follows the 11 conventions documented in the [agent-atlas best-practices blueprint](https://github.com/ryaniosys/agent-atlas/blob/main/blueprints/best-practices.md):

1. Instruction Architecture (`CLAUDE.md → @AGENTS.md`)
2. Security & Privacy (hard-deny + defense in depth)
3. Configuration (template-to-local pattern)
4. Skills (folder structure, agent-native authoring)
5. Python Execution (`run_in_venv.sh`)
6. Knowledge Base (`docs/solutions/`)
7. Task Tracking (`tasks/lessons.md`)
8. Git & Commits (conventional commits)
9. MCP Integration (`.mcp.json` + `.env.mcp`)
10. Documentation Hygiene (sharding, progressive disclosure)
11. Agent-Native Design (action parity, tools as primitives)

## References

Official Claude Code docs and community guides that informed these patterns:

- [Claude Code Settings](https://code.claude.com/docs/en/settings) — official settings hierarchy and permissions
- [Claude Code Permissions Guide](https://www.eesel.ai/blog/claude-code-permissions) — allow/deny rules, precedence
- [Settings and Permissions Deep Dive](https://deepwiki.com/FlorianBruniaux/claude-code-ultimate-guide/4.2-settings-and-permissions-files) — committed vs. local, team workflows
- [Developer's Guide to settings.json](https://www.eesel.ai/blog/settings-json-claude-code) — practical configuration patterns
- [Agent-Atlas Best Practices Blueprint](https://github.com/ryaniosys/agent-atlas/blob/main/blueprints/best-practices.md) — our living conventions doc with audit matrix
