---
name: excalidraw-diagram
description: Generate visual diagrams as Excalidraw JSON, rendered to PNG via Playwright.
---

# Excalidraw Diagram Creator

Generate `.excalidraw` JSON files that **argue visually**, not just display information. Render to PNG via Playwright + Excalidraw ESM.

Based on [coleam00/excalidraw-diagram-skill](https://github.com/coleam00/excalidraw-diagram-skill).

## Triggers

- "create a diagram", "draw a diagram", "visualize this"
- "architecture diagram", "flow diagram", "sequence diagram"
- `/excalidraw-diagram`

## Prerequisites (Step 0)

First-time setup (cached after first run):

```bash
cd .claude/skills/excalidraw-diagram/references
uv sync
uv run playwright install chromium
```

## Context Sources

| Source | Path | Purpose |
|--------|------|---------|
| Color palette | `references/color-palette.md` | Semantic colors for shapes, text, evidence artifacts |
| Element templates | `references/element-templates.md` | Copy-paste JSON building blocks |
| JSON schema | `references/json-schema.md` | Excalidraw format reference |

**Read `references/color-palette.md` before generating any diagram** — it is the single source of truth for all color choices.

## Customization

To produce diagrams in your own brand style, edit `references/color-palette.md`. Everything else in this skill is universal design methodology.

<!-- CUSTOMIZE: Replace the default color palette with your brand colors -->

---

## Core Philosophy

**Diagrams should ARGUE, not DISPLAY.**

A diagram isn't formatted text. It's a visual argument that shows relationships, causality, and flow that words alone can't express. The shape should BE the meaning.

**The Isomorphism Test**: If you removed all text, would the structure alone communicate the concept? If not, redesign.

**The Education Test**: Could someone learn something concrete from this diagram, or does it just label boxes? A good diagram teaches — it shows actual formats, real event names, concrete examples.

---

## Depth Assessment (Do This First)

Before designing, determine what level of detail this diagram needs:

### Simple/Conceptual Diagrams
Use abstract shapes when:
- Explaining a mental model or philosophy
- The audience doesn't need technical specifics
- The concept IS the abstraction (e.g., "separation of concerns")

### Comprehensive/Technical Diagrams
Use concrete examples when:
- Diagramming a real system, protocol, or architecture
- The diagram will be used to teach or explain (e.g., YouTube video)
- The audience needs to understand what things actually look like
- You're showing how multiple technologies integrate

**For technical diagrams, you MUST include evidence artifacts** (see below).

---

## Research Mandate (For Technical Diagrams)

**Before drawing anything technical, research the actual specifications.**

If you're diagramming a protocol, API, or framework:
1. Look up the actual JSON/data formats
2. Find the real event names, method names, or API endpoints
3. Understand how the pieces actually connect
4. Use real terminology, not generic placeholders

Bad: "Protocol" -> "Frontend"
Good: "AG-UI streams events (RUN_STARTED, STATE_DELTA)" -> "CopilotKit renders via createA2UIMessageRenderer()"

---

## Evidence Artifacts

Evidence artifacts are concrete examples that prove your diagram is accurate and help viewers learn. Include them in technical diagrams.

| Artifact Type | When to Use | How to Render |
|---------------|-------------|---------------|
| **Code snippets** | APIs, integrations | Dark rectangle + syntax-colored text |
| **Data/JSON examples** | Data formats, schemas | Dark rectangle + colored text |
| **Event/step sequences** | Protocols, workflows | Timeline pattern (line + dots + labels) |
| **UI mockups** | Showing actual output | Nested rectangles mimicking real UI |
| **API/method names** | Real function calls | Use actual names from docs |

---

## Multi-Zoom Architecture

Comprehensive diagrams operate at multiple zoom levels simultaneously:

| Level | Purpose | Example |
|-------|---------|---------|
| **1: Summary Flow** | Full pipeline at a glance | `Input -> Processing -> Output` |
| **2: Section Boundaries** | Visual "rooms" grouping related components | Backend / Frontend / External |
| **3: Detail Inside Sections** | Evidence artifacts, code snippets | Actual API response format |

**For comprehensive diagrams, aim to include all three levels.**

---

## Workflow

### Step 1: Assess Depth & Research

Determine if this needs to be simple/conceptual or comprehensive/technical. For technical diagrams, research actual specs, formats, and event names first.

### Step 2: Map Concepts to Visual Patterns

For each concept, find the visual pattern that mirrors its behavior:

| If the concept... | Use this pattern |
|-------------------|------------------|
| Spawns multiple outputs | **Fan-out** (radial arrows from center) |
| Combines inputs into one | **Convergence** (funnel, arrows merging) |
| Has hierarchy/nesting | **Tree** (lines + free-floating text) |
| Is a sequence of steps | **Timeline** (line + dots + labels) |
| Loops or improves continuously | **Spiral/Cycle** (arrow returning to start) |
| Is an abstract state or context | **Cloud** (overlapping ellipses) |
| Transforms input to output | **Assembly line** (before -> process -> after) |
| Compares two things | **Side-by-side** (parallel with contrast) |
| Separates into phases | **Gap/Break** (visual separation) |

### Step 3: Ensure Variety

For multi-concept diagrams: **each major concept must use a different visual pattern**. No uniform cards or grids.

### Step 4: Build .excalidraw JSON Section-by-Section

**For large diagrams, build one section at a time.** Do NOT generate the entire file in a single pass — Claude Code has a ~32,000 token output limit per response.

1. Create the base file with JSON wrapper and first section of elements
2. Add one section per edit — think carefully about layout and cross-section connections
3. Use descriptive string IDs (e.g., `"trigger_rect"`, `"arrow_fan_left"`)
4. Namespace seeds by section (section 1 uses 100xxx, section 2 uses 200xxx)
5. Update cross-section bindings as you go

### Step 5: Render & Validate (MANDATORY)

```bash
cd .claude/skills/excalidraw-diagram/references && uv run python render_excalidraw.py <path-to-file.excalidraw>
```

This outputs a PNG next to the `.excalidraw` file. Then use the **Read tool** on the PNG to view it.

### Step 6: Iterate Until Clean

Run the render-view-fix loop:

1. **Render & View** — Run the script, Read the PNG
2. **Audit against vision** — Does visual structure match conceptual structure? Is hierarchy correct?
3. **Check for defects** — Text clipping, overlaps, misrouted arrows, uneven spacing
4. **Fix** — Edit JSON (widen containers, adjust coordinates, add arrow waypoints)
5. **Re-render** — Repeat until the diagram passes both vision and defect checks

Typically takes 2-4 iterations.

## Output Format

- `.excalidraw` JSON file (editable in Excalidraw app or excalidraw.com)
- `.png` rendered image

## Container vs. Free-Floating Text

**Not every piece of text needs a shape around it.** Default to free-floating text. Add containers only when they serve a purpose.

| Use a Container When... | Use Free-Floating Text When... |
|------------------------|-------------------------------|
| It's the focal point of a section | It's a label or description |
| Arrows need to connect to it | It describes something nearby |
| The shape carries meaning (decision diamond) | Typography alone creates hierarchy |
| It represents a distinct "thing" in the system | It's a section title or annotation |

**Rule**: Aim for <30% of text elements inside containers.

## Shape Meaning

| Concept Type | Shape | Why |
|--------------|-------|-----|
| Labels, descriptions | **none** (free-floating text) | Typography creates hierarchy |
| Markers on a timeline | small `ellipse` (10-20px) | Visual anchor, not container |
| Start, trigger, input | `ellipse` | Soft, origin-like |
| End, output, result | `ellipse` | Completion, destination |
| Decision, condition | `diamond` | Classic decision symbol |
| Process, action, step | `rectangle` | Contained action |
| Abstract state, context | overlapping `ellipse` | Fuzzy, cloud-like |

## Modern Aesthetics

- `roughness: 0` — Clean, crisp edges (default for professional diagrams)
- `roughness: 1` — Hand-drawn feel (brainstorming/informal only)
- `strokeWidth: 2` — Standard. Use 1 for subtle lines, 3 for emphasis
- `opacity: 100` — Always. Use color/size for hierarchy, not transparency
- `fontFamily: 3` — Monospace, always

## Layout Principles

- **Hero**: 300x150 (visual anchor), **Primary**: 180x90, **Secondary**: 120x60, **Small**: 60x40
- Most important element gets most whitespace (200px+)
- Flow left-to-right or top-to-bottom for sequences, radial for hub-and-spoke
- Every relationship needs an arrow — position alone doesn't show connections

## Guidelines

- Read `references/color-palette.md` before every diagram — never hardcode colors
- Every element needs a unique `seed` value
- Use descriptive string IDs for cross-referencing between sections
- For comprehensive diagrams, include all three zoom levels (summary, sections, detail)
- `text` and `originalText` contain ONLY readable words — no formatting codes

## Anti-Patterns

- **Generating entire large diagram in one pass** — will hit token limits and produce broken JSON
- **Card-grid layouts** — uniform boxes convey nothing; prefer visual arguments
- **Hardcoded colors** — always pull from `color-palette.md`
- **Using a coding agent** — won't have skill context; hand-craft the JSON
- **Writing a Python generator** — coordinate math indirection makes debugging harder
- **Boxes around everything** — most text should be free-floating

## Quality Checklist

### Depth & Evidence (Technical Diagrams)
- [ ] Research done: actual specs, formats, event names looked up
- [ ] Evidence artifacts: code snippets, JSON examples, or real data included
- [ ] Multi-zoom: summary flow + section boundaries + detail
- [ ] Educational value: someone could learn something concrete

### Conceptual
- [ ] Isomorphism: visual structure mirrors concept behavior
- [ ] Argument: diagram shows something text alone couldn't
- [ ] Variety: each major concept uses a different visual pattern

### Technical
- [ ] Text clean: `text` contains only readable words
- [ ] `fontFamily: 3`, `roughness: 0`, `opacity: 100`
- [ ] Container ratio: <30% of text elements inside containers
- [ ] Colors from palette, unique seeds

### Visual Validation (Render Required)
- [ ] Rendered to PNG and visually inspected
- [ ] No text overflow or overlapping elements
- [ ] Arrows route cleanly and connect correctly
- [ ] Balanced composition, consistent spacing
