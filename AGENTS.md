# <!-- CUSTOMIZE: Agent Name --> — Claude Code Instructions

<!-- CUSTOMIZE: Add a one-liner linking to PRD.md if you have one -->
> **Strategic context & roadmap:** See `PRD.md` for the overarching product vision, capability map, and what's planned next.

## Git Workflow

**Always commit and push changes after every change** unless explicitly instructed otherwise. Use descriptive commit messages.

### Conventional Commits

```
<type>(<scope>): <description>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`

### Branch Naming

| Prefix | Use |
|--------|-----|
| `feat/` | New features |
| `fix/` | Bug fixes |
| `refactor/` | Refactoring |
| `docs/` | Documentation |

### Git Hooks

After cloning, install the pre-push hook to block direct pushes to `main`:
```bash
ln -sf ../../scripts/hooks/pre-push .git/hooks/pre-push
```

## Updating Documentation & Instructions

When updating skill instructions, style guides, or AGENTS.md based on learnings:
- **Keep guidance agnostic** — extract the general pattern, not the specific case
- **Don't overfit** — one example doesn't warrant a detailed rule
- **Prefer principles over prescriptions**

## Permission Settings

**All permission changes go in `.claude/settings.local.json`** (gitignored, user-specific) — never modify the committed `.claude/settings.json`.

| File | Committed | Purpose |
|------|-----------|---------|
| `.claude/settings.json` | Yes | Shared deny rules (secrets protection) |
| `.claude/settings.local.json` | No (gitignored) | User-specific allow/deny, MCP servers, additional directories |

The committed `settings.json` hard-blocks `.env` file reads. Add your repo-specific permissions (MCP tool allows, directory access, etc.) to `settings.local.json`.

## Data Privacy

**NEVER read `.env`, `.env.mcp`, or any file containing secrets/tokens.** If the user needs to edit these files, open them with `xdg-open` so the user can edit manually. Reading secrets into conversation context exposes them irreversibly.

**NEVER output credential values** found in config files. Tokens, API keys, passwords, and auth secrets must never be printed, quoted, or referenced by value in conversation — only by their key name or env var reference.

### Git Restrictions

**NEVER commit to any git repository:**
- API keys, `.env` files, credentials
- Customer or project names (use anonymized references)
- Personal information (names, contacts, addresses)
- Meeting transcripts or recordings

<!-- CUSTOMIZE: Add domain-specific restrictions (e.g., financial data, student records) -->

**Anonymization patterns for committed files:**
- Companies: `acme-corp`, `globex-inc`, or `Customer A`, `Customer B`
- Email domains: `@customer-a.example.com`
- People: `Developer X`, `Contact Y`, or role descriptions

## Configuration

<!-- CUSTOMIZE: Define all user-specific paths as variables here -->
<!-- Skills should read this section to get configured paths -->
<!-- Never hardcode user-specific paths in skills or code -->

```yaml
# Paths (override in config.local.yaml)
# OUTPUT_FOLDER: ~/Documents/...
# DATA_FOLDER: ~/Documents/...
```

User settings in `config.local.yaml` (gitignored). Copy from template:
```bash
cp config.template.yaml config.local.yaml
```

## Running Python Scripts

Scripts in `scripts/` use a shared venv managed by `run_in_venv.sh`:

```bash
# Preferred: use the wrapper script
scripts/run_in_venv.sh my_script.py --arg value

# For one-shot Python with env vars + venv:
source .env && /tmp/${REPO_NAME}-venv/bin/python scripts/my_script.py
```

**Note:** The venv lives in `/tmp/{repo-name}-venv` (not project-local). Created automatically by `run_in_venv.sh` on first run.

## Skills

Run `/help` to see all available skills.

<!-- CUSTOMIZE: Add skills as you create them -->

| Skill | Trigger | Description |
|-------|---------|-------------|
| `/example-skill` | "example trigger phrase" | Example skill — delete or replace |

## MCP Servers

<!-- CUSTOMIZE: Add MCP servers as needed. Secrets go in .env.mcp (gitignored). -->

Configured in `.mcp.json`. Secrets in `.env.mcp` (gitignored).

| Server | Purpose | Required Env Vars |
|--------|---------|-------------------|
| — | — | — |

## Session Lifecycle

Session hooks (`.claude/hooks.json`) manage ephemeral skill data:

- **SessionStart:** Checks for crash recovery (stale `.heartbeat`), writes new heartbeat
- **SessionEnd:** Flushes `/tmp/{repo-name}-session/` artifacts to `data_dir`, clears heartbeat

**Where skills write artifacts:**
- During session: `/tmp/{repo-name}-session/{skill-name}/` (fast, volatile)
- For crash-critical data: `<data_dir>/{skill-name}/` directly (persistent)

The `data_dir` is configured in `config.local.yaml`. Point it to a file-synced folder for cross-machine availability. See the README for the full pattern.

## Quick Reference

| File | Purpose |
|------|---------|
| `config.local.yaml` | User-specific settings (gitignored) |
| `.claude/hooks.json` | Session lifecycle hooks (heartbeat, flush) |
| `.env` | API keys and secrets (gitignored) |
| `.mcp.json` | MCP server configurations |
| `instructions/INSTRUCTIONS.md` | Detailed workflow instructions |
| `tasks/lessons.md` | Self-improvement log |

<!-- CUSTOMIZE: Add repo-specific file references -->

## For Full Details

<!-- CUSTOMIZE: Add links to deeper docs as your repo grows -->

| Topic | File |
|-------|------|
| Detailed instructions | `instructions/INSTRUCTIONS.md` |
| Solution knowledge base | `docs/solutions/` |
| Best practices blueprint | See `ryaniosys/agent-atlas` → `blueprints/best-practices.md` |
