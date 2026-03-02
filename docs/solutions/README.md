# Solution Docs — Knowledge Base

Pattern: `docs/solutions/{category}/{slug}.md`

Each doc captures a solved problem for future reference.

## Categories

```
docs/solutions/
├── integration-issues/    # API quirks, auth problems, workarounds
├── integration-patterns/  # How-tos for external service integration
├── workflow-patterns/     # Recurring workflow solutions
└── skill-creation/        # Patterns for building skills
```

## Template

```markdown
---
title: Brief descriptive title
category: integration-issues
tags: [api, auth, workaround]
created: YYYY-MM-DD
---

# Title

## Problem

What went wrong or what needed solving.

## Investigation

What was tried, what was observed.

## Root Cause

Why it happened.

## Solution

How it was fixed (with code/config examples).

## Gotchas

Edge cases, caveats, things to watch for.
```
