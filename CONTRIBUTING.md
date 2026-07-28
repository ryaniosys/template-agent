# Contributing to template-agent

Thanks for your interest in contributing! This guide covers the basics.

## How to Contribute

1. **Fork** the repository
2. **Create a branch** from `main` using the naming convention below
3. **Make your changes** following the guidelines in this document
4. **Open a pull request** against `main`

## Setup

Enable the pre-commit hook:

```bash
git config core.hooksPath .githooks
```

It runs two independent checks on each commit:

1. **Sensitive terms.** Staged changes are matched against a local deny-list (`.sensitive-terms`).
   That file is gitignored, so create your own with the patterns you want blocked; see the hook
   script for the format. If it does not exist, this check is skipped and the next one still runs.
2. **Injected agent hooks.** Rejects a `hooks` key in the committed `.claude/settings.json`, and any
   staged `.claude/*.bak`. Agent tooling installs itself by writing `PreToolUse` /
   `UserPromptSubmit` / `Stop` entries into that file and leaving a `.bak` beside it. Hooks are
   arbitrary code execution, and `settings.json` is committed, so an injected hook ships to every
   clone. Session hooks belong in `.claude/hooks.json`. Override once with `--no-verify` if you
   genuinely mean it.

The `.bak` is deliberately **not** gitignored: it showing up as untracked in `git status` is what
makes an unexpected rewrite of your settings visible at all.

A committed hook file is not a running hook. If you skip the `core.hooksPath` step above, neither
check ever executes.

## Branch Naming

| Prefix | Use |
|--------|-----|
| `feat/` | New features |
| `fix/` | Bug fixes |
| `refactor/` | Refactoring |
| `docs/` | Documentation |

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`

## Contributing Skills

New skills should follow the [11 conventions](https://github.com/ryaniosys/agent-atlas/blob/main/blueprints/best-practices.md) established in the agent ecosystem. Use `.claude/skills/example-skill/` as your starting template.

Key requirements:
- Every skill needs a `SKILL.md` with triggers, context sources, and workflow
- Scripts go in the skill's `scripts/` subdirectory
- Secrets use `.env` (gitignored), with a `.env.example` template

## Code of Conduct

This project follows the [Contributor Covenant v2.1](CODE_OF_CONDUCT.md). Please read it before participating.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Copyright Ryan iosys GmbH
