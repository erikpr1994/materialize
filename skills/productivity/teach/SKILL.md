---
name: teach
description: Teach the user a new skill or concept, within this workspace.
disable-model-invocation: true
argument-hint: "What would you like to learn about?"
---

The user has asked you to teach them something. This is a stateful request - they intend to learn the topic over multiple sessions.

## Teaching Workspace

Treat the current directory as a teaching workspace. State lives in these files:

- `index.html`: A **mobile-first dashboard** — the home page, linking every lesson, reference document, the mission, and resources. Use the format in [DASHBOARD-FORMAT.md](./DASHBOARD-FORMAT.md).
- `MISSION.md`: Why the user wants to learn the topic. Grounds all teaching. Use the format in [MISSION-FORMAT.md](./MISSION-FORMAT.md).
- `GLOSSARY.md`: The canonical, compressed term set for this topic — every lesson and reference document adheres to it. Use the format in [GLOSSARY-FORMAT.md](./GLOSSARY-FORMAT.md).
- `./reference/*.html`: Compressed learnings — cheat sheets, algorithms, syntax, poses. Beautiful, print-friendly, quick-lookup. May render `GLOSSARY.md` as HTML.
- `RESOURCES.md`: Resources to ground teaching or acquire knowledge/wisdom. Use the format in [RESOURCES-FORMAT.md](./RESOURCES-FORMAT.md).
- `./learning-records/*.md`: What the user has learned — like ADRs, capturing non-obvious lessons and insights, used to gauge the zone of proximal development. Use the format in [LEARNING-RECORD-FORMAT.md](./LEARNING-RECORD-FORMAT.md).
- `./lessons/*.html`: One self-contained HTML output per tightly-scoped thing tied to the mission. The primary unit of teaching.
- `./assets/*`: Reusable **components** shared across lessons. See [Assets](#assets).
- `NOTES.md`: Scratchpad for user preferences and working notes.

## Philosophy

Deep learning needs three things: **knowledge** (high-quality, high-trust resources — never trust parametric knowledge), **skills** (interactive lessons built on that knowledge), and **wisdom** (from other learners and practitioners). Weight the mix per topic — theoretical physics skews knowledge, yoga skews skills. Before `RESOURCES.md` is well-populated, prioritize finding good resources.

Split learning into **fluency strength** (in-the-moment retrieval) and **storage strength** (long-term retention) — fluency feels like mastery, but storage strength is the goal. Build it with desirable difficulty: retrieval practice, spacing, and interleaving (skills practice only).

## Lessons

A lesson is the main unit of output: one self-contained HTML file in `./lessons/`, titled `0001-<dash-case-name>.html`, number incrementing.

Make it beautiful — clean, readable, Tufte-like typography — since the user returns to it later. Show, don't just tell: render spatial, relational, or dynamic concepts as a diagram or small interactive visual rather than prose, as a reusable `./assets/` component (see [Assets](#assets)) — it gives a second retrieval path.

Represent hierarchical/tree structures with semantic HTML (nested lists, CSS), not ASCII art — proportional fonts break alignment. If you must use ASCII, wrap it in `<pre><code>`, never mixed with inline styling.

Keep lessons short and quickly completable — working memory is small. Each still lands one tangible win, tied to the mission, in the user's zone of proximal development. Open the lesson file for the user via CLI command if possible.

Every lesson carries a consistent nav bar: clickable **◀ Previous** / **Next ▶** (disabled at the ends) and a **Contents** link back to root `index.html`, relative-pathed for offline `file://` use. Adding a lesson re-links the chain — point the prior lesson's **Next** at it and add it to the dashboard. Anchor-link to relevant reference documents inline too.

Each lesson recommends a primary source (the highest-quality, highest-trust one found) and reminds the user to ask the agent followup questions.

Doubts surface mid-read, and leaving the lesson to retype them from memory breaks flow and loses the passage that raised them. Give every lesson a shared `./assets/` doubt-capture component (see [Assets](#assets)): a persisted place to jot questions in context, with a one-tap copy that formats each doubt with its quoted passage for pasting back to you — since a lesson opened from disk can't reach you any other way.

## Assets

Lessons are built from reusable components in `./assets/`: stylesheets, quiz widgets, simulators, diagram helpers.

Reuse is the default: read `./assets/` before authoring a lesson and build from what's there. New reusable needs get written as a component and linked — never inlined for a future lesson to duplicate. A shared stylesheet is the first component every workspace earns, so lessons read as one course; grow the library as the workspace grows.

## The Dashboard

The workspace's single entry point is `index.html` at the root. Use the format in [DASHBOARD-FORMAT.md](./DASHBOARD-FORMAT.md).

Lessons and the dashboard are plain HTML. To review on a phone, serve the workspace directory with any static server (e.g. `python -m http.server`) and open it over the local network, or through a secure tunnel such as Tailscale or Cloudflare Tunnel for remote access. Always point the learner at `index.html`.

## Styling HTML outputs

Style every HTML output — lessons, dashboard, reference documents — with the Tailwind v4 Play CDN rather than hand-written `<style>`, so output stays consistent across a multi-lesson course and each file stays light:

```html
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
```

Put custom theming in a `<style type="text/tailwindcss">` block. The CDN needs network access — inline the CSS instead for files the learner must read fully offline.

When a lesson shows code, load a syntax highlighter so blocks render colourised — `language-*` classes alone do nothing, and Tailwind styles layout, not tokens. highlight.js drops in the same way (same offline caveat — inline it for fully-offline files):

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets/styles/github.min.css">
<script src="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets/highlight.min.js"></script>
<script>hljs.highlightAll()</script>
```

## The Mission

Every lesson ties back to the mission — why the user wants to learn the topic. If the user is unclear or `MISSION.md` is unpopulated, first question them on why; otherwise lessons stay abstract and ungrounded.

Missions can change as skills and knowledge grow — update `MISSION.md` and add a learning record to capture the change. Confirm with the user first.

## Zone Of Proximal Development

Each lesson should feel challenged 'just enough'. If the user hasn't specified an exact target, find their zone by:

- Reading `learning-records` — the most recent few in full; once they pile up (~8+), lean on the running concept summary in `NOTES.md` for older ones instead of re-reading every file (avoids quadratic cost over a long course).
- Weighing what fits their mission.
- Teaching the most relevant thing that fits their zone.

## Knowledge

Lessons are designed around a skill to learn; include only the knowledge required for that skill. Teach knowledge first, then have the user practice via an interactive feedback loop.

Gather knowledge from trusted resources, tracked in `RESOURCES.md`. Cite external sources throughout to raise lesson trustworthiness. For knowledge acquisition, difficulty is the enemy — it eats working memory needed for understanding.

## Skills

Skills are about durability and flexibility — make knowledge stick. Here difficulty is the tool: effortful retrieval builds storage strength. Teach skills through interactive lessons — quizzes, light in-browser tasks, or lessons guiding the user through real-world steps (e.g. yoga poses) — each running on as tight a feedback loop as possible, ideally automatic.

For quizzes: keep every answer the same length (words and, if possible, characters) so formatting gives no clue. Vary which position holds the correct answer, and make every distractor a plausible, confidently-stated mistake — never an obvious throwaway.

## Acquiring Wisdom

Wisdom comes from real-world interaction — testing skills outside the learning environment. When a question needs wisdom, attempt an answer but ultimately point the user to a **community**: a forum, subreddit, real-world class, or local interest group where they can test skills for real. Look for high-reputation communities; respect it if the user doesn't want to join one.

## Reference Documents

Alongside lessons, create reference documents — the compressed essence of a lesson, in a format built for quick lookup. Lessons are rarely revisited; reference documents are. Topics that lend themselves to reference: syntax/code snippets (programming), algorithms/flowcharts (processes), poses/sequences (yoga), exercises/routines (fitness).

The glossary (`GLOSSARY.md` above) is essential for any topic with its own nomenclature. Once terms are defined, adhere to them in every lesson; a reference document may render the glossary as HTML for quick lookup.

## `NOTES.md`

Record user teaching preferences here to refer back to when designing lessons. Also keep a running summary of concepts already learned, updated at session end — it lets you judge the zone of proximal development from older lessons without re-reading every learning record once the history grows long.
