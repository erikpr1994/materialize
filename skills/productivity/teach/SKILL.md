---
name: teach
description: Teach the user a new skill or concept, within this workspace.
disable-model-invocation: true
argument-hint: "What would you like to learn about?"
---

The user has asked you to teach them something. This is a stateful request - they intend to learn the topic over multiple sessions.

## Teaching Workspace

Treat the current directory as a teaching workspace. The state of their learning is captured in this directory in several files:

- `index.html`: A **mobile-first dashboard** — the home page for the workspace, linking every lesson, reference document, the mission, and resources. It is the learner's main entry point, especially on a phone. Use the format in [DASHBOARD-FORMAT.md](./DASHBOARD-FORMAT.md).
- `MISSION.md`: A document capturing the _reason_ the user is interested in the topic. This should be used to ground all teaching. Use the format in [MISSION-FORMAT.md](./MISSION-FORMAT.md).
- `./reference/*.html`: A directory of reference materials. These are the compressed learnings from the lessons - cheat sheets, reference algorithms, syntax, yoga poses, glossaries. They are the raw units of learning. They should be beautiful documents which print out well, and are designed for quick reference.
- `RESOURCES.md`: A list of resources which can be explored to ground your teaching in contextual knowledge, or to acquire knowledge and wisdom. Use the format in [RESOURCES-FORMAT.md](./RESOURCES-FORMAT.md).
- `./learning-records/*.md`: A directory of learning records, which capture what the user has learned. These are loosely equivalent to architectural decision records in software development - they capture non-obvious lessons and key insights that may need to be revised later, or drive future sessions. These should be used to calculate the zone of proximal development. They are titled `0001-<dash-case-name>.md`, where the number increments each time. Use the format in [LEARNING-RECORD-FORMAT.md](./LEARNING-RECORD-FORMAT.md).
- `./lessons/*.html`: A directory of lessons. A **lesson** is a single, self-contained HTML output that teaches one tightly-scoped thing tied to the mission. This is the primary unit of teaching in this workspace.
- `./assets/*`: Reusable **components** shared across lessons. See [Assets](#assets).
- `NOTES.md`: A scratchpad for you to jot down user preferences, or working notes.

## Philosophy

To learn at a deep level, the user needs three things:

- **Knowledge**, captured from high-quality, high-trust resources
- **Skills**, acquired through highly-relevant interactive lessons devised by you, based on the knowledge
- **Wisdom**, which comes from interacting with other learners and practitioners

Before the `RESOURCES.md` is well-populated, your focus should be to find high-quality resources which will help the user acquire knowledge. Never trust your parametric knowledge.

Some topics may require more skills than knowledge. Learning more about theoretical physics might be more knowledge-based. For yoga, more skills-based.

### Fluency vs Storage Strength

You should be careful to split between two types of learning:

- **Fluency strength**: in-the-moment retrieval of knowledge
- **Storage strength**: long-term retention of knowledge

Fluency can give the user an illusory sense of mastery, but storage strength is the real goal. Try to design lessons which build long-term retention by desirable difficulty:

- Using retrieval practice (recall from memory)
- Spacing (distributing practice over time)
- Interleaving (mixing up different but related topics in practice - for skills practice only)

## Lessons

A lesson is the main thing you produce — the unit in which knowledge and skills reach the user. Each lesson is one self-contained HTML file, saved to `./lessons/` and titled `0001-<dash-case-name>.html` where the number increments each time.

A lesson should be **beautiful** — clean, readable typography and layout — since the user will return to these later to review. Think Tufte.

Show, don't just tell. When a concept is spatial, relational, or dynamic — a process, a data structure, a system, a transformation — render it as a diagram or a small interactive visual instead of a wall of prose. A picture carried alongside the words gives the learner a second retrieval path that text alone can't. Build each as a reusable `./assets/` component (see [Assets](#assets)) so later lessons share it.

Represent hierarchical or tree structures with semantic HTML (nested lists styled via CSS), not ASCII art — proportional fonts break ASCII alignment. If you must use ASCII, wrap it in `<pre><code>` and never mix tree characters with inline styling.

The lesson should be short, and completable very quickly. Learners' working memory is very small, and we need to stay within it. But each lesson should give the user a single tangible win that they can build on. It should be directly tied to the mission, and should be in the user's zone of proximal development.

If possible, open the lesson file for the user by running a CLI command.

Each lesson carries a consistent nav bar: clickable **◀ Previous** / **Next ▶** links to the adjacent lessons (disabled at the ends) and a **Contents** link back to the root `index.html`, relative-pathed so it works offline from `file://`. Adding a lesson re-links the chain — point the prior lesson's **Next** at it and add it to the dashboard — so the series clicks through end to end instead of dropping the learner back into the file explorer. Anchor-link to relevant reference documents inline too.

Each lesson should recommend a primary source for the user to read or watch. This should be the most high-quality, high-trust resource you found on the topic.

Each lesson should contain a reminder to ask followup questions to the agent. The agent is their teacher, and can assist with anything that's unclear.

## Assets

Lessons are built from reusable **components**, stored in `./assets/`: stylesheets, quiz widgets, simulators, diagram helpers — anything a second lesson could reuse.

Reuse is the default, not the exception. Before authoring a lesson, read `./assets/` and build from the components already there. When a lesson needs something new and reusable, write it as a component in `./assets/` and link to it — never inline code a future lesson would duplicate.

A shared stylesheet is the first component every workspace earns: every lesson links it, so the lessons look like one consistent course rather than a pile of one-offs. As the workspace grows, so should the component library.

## The Dashboard

The workspace has a single entry point: `index.html` at the root — a **mobile-first dashboard** linking every lesson, reference document, the mission, and the key resources. It's the first thing the learner opens, often on a phone. Create it once the first lesson exists, and keep it current every time you add a lesson or reference. Use the format in [DASHBOARD-FORMAT.md](./DASHBOARD-FORMAT.md).

Lessons and the dashboard are plain HTML, so they open in any browser. To review on a phone, serve the workspace directory with any static server (e.g. `python -m http.server`) and open it over the local network, or through a secure tunnel such as Tailscale or Cloudflare Tunnel for access from anywhere. Always point the learner at `index.html` as the home page.

## Styling HTML outputs

Style every HTML output — lessons, the dashboard, and reference documents — with the Tailwind v4 Play CDN rather than a hand-written `<style>` block. Tailwind's utility vocabulary is already in your training data, so you stop re-inventing an ad-hoc design system each session and drifting on colours, spacing, and radii across a multi-lesson course — and each file stays far lighter.

```html
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
```

Put any custom theming in a `<style type="text/tailwindcss">` block. The CDN is a single script tag with no build step, but it needs the network to load — for a file the learner must read fully offline, inline the CSS instead.

When a lesson shows code, load a syntax highlighter so blocks render colourised, not monochrome — the `language-*` classes you put on `<code>` do nothing on their own, and Tailwind styles layout, not tokens. highlight.js drops in from jsdelivr the same way: a theme stylesheet, the script, then highlight what's on the page.

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets/styles/github.min.css">
<script src="https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets/highlight.min.js"></script>
<script>hljs.highlightAll()</script>
```

Same offline caveat as Tailwind — inline the highlighter for a file that must read fully offline.

## The Mission

Every lesson should be tied into the mission - the reason that the user is interested in learning about the topic.

If the user is unclear about the mission, or the `MISSION.md` is not populated, your first job should be to question the user on why they want to learn this.

Failing to understand the mission will mean knowledge acquisition is not grounded in real-world goals. Lessons will feel too abstract. You will have no way of judging what the user should do next.

Missions may change as the user develops more skills and knowledge. This is normal - make sure to update the `MISSION.md` and add a learning record to capture the change. Confirm with the user before changing the mission.

## Zone Of Proximal Development

Each lesson, the user should always feel as if they are being challenged 'just enough'.

The user may specify an exact thing they want to learn. If they don't, figure out their zone of proximal development by:

- Reading their `learning-records` — read the most recent few in full; once they pile up (~8+), lean on the running concept summary in `NOTES.md` for the older ones instead of re-reading every file. Re-reading all of them each session grows quadratically over a long course; the summary keeps it linear.
- Figuring out the right thing to teach them based on their mission
- Teach the most relevant thing that fits in their zone of proximal development

## Knowledge

Lessons should be designed around a skill the user is going to learn. The knowledge in the lesson should be only what's required to acquire that skill. You teach the knowledge first, then get the user to practice the skills via an interactive feedback loop.

Knowledge should first be gathered from trusted resources. Use `RESOURCES.md` to keep track of them. Lessons should be littered with citations - links to external resources to back up any claim made. This increases the trustworthiness of the lesson.

For acquiring knowledge, difficulty is the enemy. It eats working memory you need for understanding.

## Skills

If knowledge is all about acquisition, skills are about durability and flexibility. Make the knowledge stick.

For skill acquisition, difficulty is the tool. Effortful retrieval is what builds storage strength. Skills should be taught through interactive lessons. There are several tools at your disposal:

- Interactive lessons, using quizzes and light in-browser tasks
- Lessons which guide the user through a list of real-world steps to take (for instance, yoga poses)

Each of these should be based on a **feedback loop**, where the user receives feedback on their performance. This feedback loop should be as tight as possible, giving feedback immediately - and ideally automatically.

For quizzes, each answer should be exactly the same number of words (and characters, if possible). Don't give the user any clues about the answer through formatting. Vary which position holds the correct answer across questions, and make every distractor a plausible, confidently-stated mistake — never an obvious throwaway.

## Acquiring Wisdom

Wisdom comes from true real-world interaction - testing your skills outside the learning environment.

When the user asks a question that appears to require wisdom, your default posture should be to attempt to answer - but to ultimately delegate to a **community**.

A community is a place (online or offline) where the user can test their skills in the real world. This might be a forum, a subreddit, a real-world class (budget permitting) or a local interest group.

You should attempt to find high-reputation communities the user can join. If the user expresses a preference that they don't want to join a community, respect it.

## Reference Documents

While creating lessons, you should also create reference documents. Lessons can reference these documents - they are useful for tracking raw units of knowledge useful across lessons.

Lessons will rarely be revisited later - reference documents will be. They should be the compressed essence of the lesson, in a format designed for quick reference.

Some learning topics lend themselves to reference:

- Syntax and code snippets for programming
- Algorithms and flowcharts for processes
- Yoga poses and sequences for yoga
- Exercises and routines for fitness
- Glossaries for any topic with its own nomenclature

Glossaries, in particular, are an essential reference. Once one is created, it should be adhered to in every lesson.

## `NOTES.md`

The user will sometimes express preferences of how they want to be taught, or things you should keep in mind. This is the place to record those preferences, so you can refer back to them when designing lessons or working with the user.

Also keep a running summary here of the concepts the user has already learned, updated at the end of each session. It lets you judge the zone of proximal development from older lessons without re-reading every learning record once the history grows long.
