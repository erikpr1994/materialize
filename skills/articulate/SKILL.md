---
name: articulate
description: "The conductor for turning rough thinking into published writing: mines raw material (from you, and — for a coding project — from the repo, git log, and PR descriptions) and shapes it into a finished piece for a chosen platform. Triggers on developing fragments or ideas before structure, shaping notes into an article, building a piece beat by beat as narrative, or writing a post for LinkedIn / a blog / Twitter. Not for code, PRs, or one-off copyedits."
argument-hint: "[mode] [platform]"
user-invocable: true
---

`articulate` is the **conductor** for writing: it matches ceremony to the piece, picks the platform up front, and drives the pipeline to a finished, platform-ready draft — never reimplementing a phase inline when a mode owns it. Its sibling `materialize` owns code; `articulate` owns prose.

## Pick the platform first

A blog post and a LinkedIn post differ from the first fragment, not just at the end — length, hook, what's worth mining, voice. So **choose the target platform before mining**, and let it tune the whole run. Load its profile from [reference/platforms/](reference/platforms/) (`linkedin.md`, `blog.md`, `twitter.md`, …) and keep it in context across every phase. If the user hasn't said, ask which platform before starting.

Adding a platform is a new profile file, not a new mode. Repurposing a finished piece for a different platform (a blog → a LinkedIn teaser) is a fresh, platform-committed run seeded from the first.

## Setup

1. If the user invoked a **mode** (`init`, `fragments`, `shape`, `beats`), read `reference/<mode>/<mode>.md` next.
2. **Voice profile.** Load the author's voice, differentiators, hard rules, and cadence, and keep it in context across every phase; it's what makes the writing *theirs*. The profile is **user-global**, so one voice serves every repo: load repo-local `docs/writing/author.md` if it exists, else global `~/.claude/writing/author.md`. If neither exists, offer to run **`init`** before the first real piece (a writing session works without it, just more generic).
3. Load the target platform's profile (above). Voice (author) × format (platform) combine on every phase.
4. Read a sample of the author's existing writing on that platform when available, to match their voice before producing anything.

## The pipeline

Run it once; scale the ceremony to the piece. Every phase is platform-aware — it reads the profile.

1. **`fragments`** — mine raw material (from the user, and from the repo/git/PRs for a coding project). What's worth mining depends on the platform: a tweet needs one sharp nugget, a blog needs many.
2. **`shape`** (argument) or **`beats`** (narrative) — build the finished piece *for the platform*, to its length budget and formatting. Pick by whether the piece makes a case or tells a story; `beats` also fits a tweet thread (one beat per tweet).

Scale down for a quick piece (a tweet may go `fragments` → a short `beats`); scale up for a researched blog. Entering with notes already in hand → start at `shape`/`beats`; the platform is still chosen first.

## Grilling — the technique under every piece

`fragments` is a grilling session: interview the user relentlessly, one question at a time, capturing nuggets as they fall out — don't impose structure while mining. The shaping modes invert it: stop asking "what are you noticing?" and start asking "what is this piece arguing, and in what order does the reader need it?" Push back; refuse weak transitions.

## Durability

Two files, paths the user picks once and you remember:

- **The pile** — a markdown file `fragments` appends to. Raw material; read-only to the shaping modes.
- **The piece** — where `shape`/`beats` write the platform-ready draft.

Re-read from disk before every write — the user edits between turns. Never overwrite blindly; append, or edit a named block in place. No scratch-dir or marker machinery — a writing session is one sitting.

## Modes

| Mode | Stage | Description | Reference |
|---|---|---|---|
| `init` | Setup | Interview you once into a reusable voice profile — style, what makes it yours, hard rules, platforms & cadence | [reference/init/init.md](reference/init/init.md) |
| `fragments` | Mine | Grill you (and read the repo for a coding project) into a pile of raw material | [reference/fragments/fragments.md](reference/fragments/fragments.md) |
| `shape` | Shape | Build the piece for the platform as argument, paragraph by paragraph | [reference/shape/shape.md](reference/shape/shape.md) |
| `beats` | Shape | Build the piece for the platform as narrative, beat by beat | [reference/beats/beats.md](reference/beats/beats.md) |

**Platform profiles** (data, not modes — loaded up front and improved over time): [reference/platforms/](reference/platforms/) — one file per target with its length budget, hook, formatting, and failure modes.
