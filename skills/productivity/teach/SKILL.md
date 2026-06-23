---
name: teach
description: Teach the user a new skill or concept, within this workspace.
disable-model-invocation: true
argument-hint: "What would you like to learn about?"
---

# Teach

Maintain the user's stateful learning path inside the current workspace.

## Workspace Layout & Operation

- **`index.html`**: Mobile-first dashboard linking all lessons, references, the mission, and resources. Update on every new file. Format: [DASHBOARD-FORMAT.md](./DASHBOARD-FORMAT.md).
- **`MISSION.md`**: Core learning goals. Ground all lessons here. Verify or establish it before teaching. Format: [MISSION-FORMAT.md](./MISSION-FORMAT.md).
- **`RESOURCES.md`**: High-trust external resources. Format: [RESOURCES-FORMAT.md](./RESOURCES-FORMAT.md).
- **`NOTES.md`**: Record user preferences and a running concept summary to track their Zone of Proximal Development (ZPD) without re-reading old records.
- **`./lessons/0NNN-<name>.html`**: Tufte-style, mobile-friendly interactive lessons (using quizzes/feedback loops). Keep them short, within working memory.
  - Quizzes: Distractors must be plausible. Answers must have matching lengths and randomized correct positions.
  - Show, don't tell: Use interactive widgets or semantic HTML diagrams for spatial/process concepts.
  - Navigation: Include ▶ Next / ◀ Previous nav links and a Contents link to `index.html`.
- **`./reference/<name>.html`**: Print-friendly cheat sheets, syntax lists, or glossaries capturing the compressed essence of lessons for quick retrieval.
- **`./learning-records/0NNN-<name>.md`**: Chronological records of key insights and lessons learned. Format: [LEARNING-RECORD-FORMAT.md](./LEARNING-RECORD-FORMAT.md).
- **`./assets/`**: Shared components (stylesheets, scripts) to keep lessons visually cohesive.

## Styling & Libraries

Link Tailwind v4 Play CDN and syntax highlighters (use inlined styles if offline use is required):

```html
<!-- Tailwind CSS v4 CDN -->
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>

<!-- highlight.js Syntax Highlighter -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets/styles/github.min.css">
<script src="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets/highlight.min.js"></script>
<script>hljs.highlightAll()</script>
```

## Execution Protocol

1. **Assess ZPD**: Read the latest learning records and `NOTES.md` concept summary.
2. **Draft & Link Lesson**: Save to `./lessons/`, update the dashboard, link previous/next nav buttons, and serve/open the page for the user if possible.
3. **Acquire Wisdom**: Suggest high-reputation real-world communities (forums, subreddits) for practice outside the workspace.
