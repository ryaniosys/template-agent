# Contributing to template-agent

Thanks for your interest in contributing! This guide covers the basics.

## How to Contribute

1. **Fork** the repository
2. **Create a branch** from `main` using the naming convention below
3. **Make your changes** following the guidelines in this document
4. **Open a pull request** against `main`

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
