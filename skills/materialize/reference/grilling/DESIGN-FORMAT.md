# DESIGN.md Format

`DESIGN.md` is the visual glossary — the settled conventions of the project's design system. It is to design what `CONTEXT.md` is to the domain: what IS, not why.

If the repo already keeps a design-system doc, follow its structure and update that file instead. The shape below is a minimal fallback when none exists.

## Structure

```md
# {Project} Design

{One or two sentences on the product's visual lane and who it's for.}

## Color

**Primary**: `#2563eb` — actions, links, focus
**Surface**: `#ffffff` background, `#1a1a1a` text

## Type

**Body**: Inter, 16/1.5
**Headings**: Inter, 600

## Layout

**Primary actions**: sticky bottom bar on mobile, top-right on desktop
**Forms**: single column, label-above-field

## Components

**Button**: solid (primary), outline (secondary), ghost (tertiary)
```

## Rules

- **Settled conventions only.** A line earns its place once a decision is final, not while it's still being debated.
- **No rationale.** The *why* behind a hard visual trade-off goes in an ADR. `DESIGN.md` records the rule, not the argument for it.
- **Be opinionated.** When two patterns compete for the same job, pick one and write that down — the same way `CONTEXT.md` picks one term and lists the rest under `_Avoid_`.
- **Group under subheadings** (Color, Type, Layout, Components…) only as they fill out. A short flat list is fine early on.
