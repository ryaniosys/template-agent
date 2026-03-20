---
description: Example path-scoped rule — only loaded when Claude works with matching files
paths:
  - "scripts/my_integration.py"
  - ".claude/skills/my-skill/**"
---

<!-- CUSTOMIZE: Replace this with integration-specific rules for your agent.

Path-scoped rules are loaded conditionally — only when Claude touches files
matching the glob patterns above. This keeps AGENTS.md lean while ensuring
domain-specific details are available when needed.

Good candidates for .claude/rules/:
- API details (owner IDs, endpoints, auth patterns)
- Integration quirks (workarounds, known limitations)
- Service-specific conventions (naming, routing, labels)

Bad candidates (keep in AGENTS.md instead):
- Rules that prevent mistakes in any context (data privacy, git restrictions)
- Workflow preferences that apply broadly
- Configuration patterns used every session
-->

# Example Integration

**API Base URL:** `https://api.example.com/v2`

**Authentication:** Bearer token from `.env` (`EXAMPLE_API_KEY`). Never hardcode.

**Rate limits:** 100 req/min. Batch operations where possible.

**Related docs:**

| Topic | Doc |
|-------|-----|
| Setup guide | `docs/setup/example-integration.md` |
| Known quirks | `docs/solutions/integration-issues/example-api-quirks.md` |
