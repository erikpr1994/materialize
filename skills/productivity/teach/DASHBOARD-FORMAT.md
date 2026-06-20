# DASHBOARD Format

`index.html` lives at the workspace root. It is the **mobile-first dashboard** — the single entry point to the whole course, tying together every lesson, reference document, the mission, and the key resources. Learners often review on a phone, so this is the first thing they open.

## When to create and update it

- Create it once the first lesson exists.
- Update it every time you add or rename a lesson or reference document, so it never goes stale. It is the living index of the workspace.

## What it contains (in priority order)

1. **Header** — the topic, a one-line distillation of the mission, and a simple progress indicator (e.g. "Lesson 3 of 3 · start here").
2. **Lessons** — the core. Every lesson as a large, tappable card, in order, each with a one-line description and a status hint (_start here_ / _done_ / _up next_).
3. **Reference** — quick links to the reference documents.
4. **Mission** — a short summary inline, or a link, so the learner can re-ground in _why_.
5. **Resources** — a few of the highest-trust links from `RESOURCES.md`.
6. A reminder that the agent is their teacher and can answer follow-up questions.

## Rules

- **Mobile-first.** Single column, width constrained (~600px) so it also reads well on desktop. Tap targets at least ~44px tall, with generous spacing. Include `<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">` and respect safe-area insets.
- **One file, no build step.** Style it like the lessons so it opens in any browser and prints cleanly.
- **Visually consistent with the lessons.** Reuse the same palette and typography so the course feels like one product, not a pile of pages.
- **Link to HTML, not raw Markdown.** A phone browser renders a `.md` file as plain text. Surface the mission or glossary as HTML (e.g. a glossary reference document), or inline their essence — don't link `MISSION.md` / `GLOSSARY.md` directly from something opened on a phone.
- **One dashboard per workspace.** It is the root `index.html`; every other artifact hangs off it.
