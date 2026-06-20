# Init

Interview the author once and write a **voice profile** the pipeline loads on every run, so pieces sound like *them*, not generic AI. Prompt-driven, not a script: read what they've already written, propose a draft, confirm, then write. Re-running is safe — keep what's there, fill the gaps.

The profile lives at `docs/writing/author.md` (ask if the user prefers another path; remember it). Platform profiles under `reference/platforms/` cover *format*; this covers *voice* — the two combine on every piece.

## Process

### 1. Read what exists

- Is there already a `docs/writing/author.md`? On a re-init, skip settled sections and only fill gaps.
- Ask for 2-3 samples the author is proud of (links or paths) — their posts, their blog, even a long message that sounds like them. **Read them and infer the voice before asking anything.** Inferring from real writing and confirming beats asking cold.

### 2. Walk the decisions one at a time

Present a section, get the answer, move on — don't dump them all. Lead each with a one-line why. Propose a draft answer from the samples; the author corrects.

- **Voice** — tone, person (I / you / we), sentence rhythm, formality, how deep technically, where humor sits. Draft it from the samples and have them adjust.
- **What makes it yours** — signature moves, recurring themes, the opinions they'll defend, the angle others don't take. This is the differentiator; spend the most time here.
- **Audience** — who they're writing for, and who they're explicitly *not*.
- **Topics** — the projects, stacks, and domains they write about (so `fragments` knows where to dig).
- **Hard rules** — concrete do / don'ts: banned phrases ("excited to share", "in today's fast-paced world"), emoji policy, em-dash and exclamation policy, formatting and profanity prefs. High-leverage; capture every "never write X" they have.
- **Platforms & cadence** — which platforms they're on, handles/URLs, and the target rhythm per platform ("LinkedIn weekly, blog monthly"). Recorded as intent — wiring an actual scheduler is the host's job, separate from this profile.

### 3. Confirm

Show the drafted `docs/writing/author.md`. Let the author edit before writing. Don't invent a voice the samples don't support — record what's there and leave gaps they can grow.

### 4. Write

Write `docs/writing/author.md` in this layout:

```markdown
# Author voice profile

## Voice
<tone, person, rhythm, formality, technical depth, humor — a few concrete lines>

## What makes it mine
<signature moves, recurring themes, defended opinions, the distinct angle>

## Audience
<who it's for; who it's not for>

## Topics
<projects, stacks, domains worth writing about>

## Hard rules
- Never: <banned phrases / patterns>
- Always: <required habits>
- Emoji / em-dash / exclamation / formatting: <policy>

## Platforms & cadence
- <platform> — <handle/URL> — <target rhythm>

## Samples
- <path or link> — <one line on why it's representative>
```

### 5. Done

Tell the author it's set, that every piece now loads this profile alongside the target platform's, and that they can edit `docs/writing/author.md` directly anytime — re-running `init` by hand is only for a fresh start.
