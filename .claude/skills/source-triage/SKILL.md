---
name: source-triage
description: Triage the projects this fork learns from (the README Inspiration watch-list) — their code, open and closed issues, and discussions — against our fork, recording a verdict for each so we never re-analyse the same item twice. Use to sync the triage log across sources, find ideas to port into the fork, or review a single backlog item.
metadata:
  internal: true
---

# Source triage

Repo-only skill. It lives in this repo's `.claude/skills/` so Claude Code auto-loads it
whenever you work in Materialize. It's kept out of `plugin.json`'s `skills` array
**and** marked `metadata.internal: true` — the `skills` CLI scans `.claude/skills/`
directly, so the manifest omission alone isn't enough; the `internal` flag is what hides
it from `npx skills add` (installable only with `INSTALL_INTERNAL_SKILLS=1`). It keeps
[`LOG.md`](./LOG.md) — the durable record of every source item we've looked at and what
we decided. The point is **incremental**: each run only triages items not already in the
log, so harvesting the watch-list compounds instead of repeating.

**Sources.** The watch-list is the **Inspiration** section of `README.md` — upstream plus
every repo we credit or watch (incl. brooks-lint and Claude Code `/code-review`). `LOG.md`'s
`## Sources` registry mirrors it as `owner/name` rows with per-track **last synced**
markers; sync iterates the registry. A row marked **credit-only** — a deprecated/no-public-repo source, or one we deliberately exclude from harvesting (e.g. a single-domain skill we credit for an idea but never port from) — is an inspiration credit only and is skipped by sync.

**Standalone — ideas, not code.** Per `CLAUDE.md` we no longer rebase onto or copy any
source. Nothing arrives automatically: a `COMPLETED`-closed upstream issue or a slick
commit in another repo is a *candidate idea to reimplement our way*, never code we inherit.
`implement` means port the idea, terse and our-style — never paste theirs.

**Tracks** (per source): **Issues** (open), **Discussions**, **Closed**, and **Code**
(ideas harvested from commits / implementation). All share the verdict vocabulary. Every
row cites an **exact ref**: issues/discussions by `#N`, **code by `<sha> path:Lstart-Lend`**
so a later run can re-find it. Discussions skew to `watch`/`skip` (ideas without a repro;
Q&A / show-and-tell rarely imply a change). Code and Closed are where the richest sources
(e.g. a review skill) pay off — work them down incrementally.

Verdicts: **new** (synced, not yet deliberated), **done** (ported into our fork),
**implement** (decided to port, not yet done), **watch** (good idea, needs design or the
source may evolve it), **skip** (not relevant — other tools/platforms, pure discussion,
already-have, collides-keep-ours). A row is **resolved** at `done`/`skip`; `new`/
`implement`/`watch` stay in the backlog.

Two flows. "sync"/"reconcile"/"check for new" → Flow 1; "review one"/"what should I port"
→ Flow 2. The scheduled [`glean`](../../../docs/routines/glean.md) routine drives both
autonomously (sync all, then port from the backlog into a PR). No steer → ask which.

## Flow 1 — Sync the list

Pure list maintenance across **every source** in the `## Sources` registry. No deliberation,
no code changes.

1. **Pull, per source, since its `last synced`:**
   - Open issues: `gh issue list --repo <owner/name> --state open --limit 100 --json number,title`.
   - Closed issues: `gh issue list --repo <owner/name> --state closed --limit 500 --json number,title,stateReason`.
   - Discussions: `gh api graphql` for the repo's discussions (number, title, category, closed).
   - Code: `gh api repos/<owner/name>/commits` since the last code-sync date; capture notable commits as `<sha> — subject` for examination in Flow 2.
2. **Reconcile against [`LOG.md`](./LOG.md):** any item (issue / discussion / closed / commit) not already in that source's track → append a `new` row with a factual one-line note and its exact ref (`#N` or `<sha>`). A logged open issue that's since closed → move to the Closed track, preserving its note. Don't deliberate.
3. **Update each source's `last synced`** markers (highest issue number + today's date; latest commit sha).
4. **Report** the delta per source: new issues / discussions / closed / commits, moves, and the new unresolved count. No fixes here.

## Flow 2 — Review one item

1. **Pick one unresolved item** (`new` / `implement` / `watch`) from any source and any track. Vary across runs — rotate sources and tracks; don't always pick open issues over code or closed. None unresolved → say so, suggest Flow 1.
2. **Study it at the source.** Issue/discussion → read its body + comments. Code/commit → read the actual diff and the exact `path:Lstart-Lend`. Map it to a skill/mode we ship (`plugin.json` + bucket READMEs; items about tools we don't ship are an immediate `skip`), and grep our modes to see whether we already do it.
3. **Assess against our modes** — already-have / collides-keep-ours / genuinely-new (`materialize`'s `review` disprove-before-emit applies: a vague "could be better" isn't a finding). State which skill/mode it touches, whether we already handle it, and a recommended verdict with one-line rationale, citing the exact source ref.
4. **Decide.** Interactive: ask the user, wait. Autonomous (via `glean`): port the `implement`-worthy item.
   - **Port** → reimplement the idea our way (never paste source code), match the target mode's voice, run the [`writing-great-skills`](../../../skills/productivity/writing-great-skills/SKILL.md) lens, verify (grep / run any repro). Record `done` with the PR link.
   - **Discard / defer** → record `skip` or `watch` with the reason.
5. **Record** the row in its track with the exact ref and verdict. One item per run unless asked for more.
