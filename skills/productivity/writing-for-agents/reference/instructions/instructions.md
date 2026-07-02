`instructions` mode — the mechanics of an agent instruction file. The universal principles (leading words, pruning, relevance, single source of truth, the failure modes) live in the base; skill-system specifics live in [../skills/skills.md](../skills/skills.md). This file holds only what is specific to instruction files.

## One artifact, many filenames

An instruction file is **injection, not documentation** — a prompt prepended to the session, not a place to explain the project. Different tools read different filenames (`CLAUDE.md`, `AGENTS.md`, and other per-tool variants), but the content model is identical: one artifact kind wearing different names.

So keep **one** source of truth and bridge the filename gap mechanically — a hand-maintained second file is duplication that drifts. Prefer a one-line **import directive** in the alias (e.g. `CLAUDE.md` containing `@AGENTS.md`); it's robust cross-platform. A symlink works too but is unreliable on some platforms and checkouts.

## What earns a line

Capture only what the agent gets **wrong** without being told: non-obvious conventions, exact commands, hard boundaries. Prefer cutting anything the model already knows — language and framework defaults are no-ops here.

- **Send deterministic checks to a hook, not the prose.** Formatting, lint rules, import order belong in hooks or CI; the model runs them less reliably and you pay their context every turn.
- **Name the capability, not the path.** Paths go stale and a stale path poisons the context. Prefer the stable domain concept — "auth lives behind the session service", not a directory listing.

## Length is a budget

Every line is paid each session. Target ~200 lines; treat ~300 as a ceiling. Adherence degrades past a practical ~50-instruction budget, and some tools hard-truncate the file (~32 KiB) — past that, lines silently vanish.

Prune test: **if I remove this line, will the agent get it wrong?** If not, cut it. Generated starter files run verbose — trim one before trusting it.

## Order — operative constraints first

1. One line: project + stack.
2. Exact build/test/run commands, copy-pasteable, with the flags you actually use (`pnpm test --filter web`, not "run the tests").
3. Non-default conventions, only where the agent would otherwise guess wrong.
4. Reference pointers last.

## Disclose the rest

Inline only what every session needs; push depth behind imports. Give each pointer a **"Read when…" trigger** so the model opens the doc at the right moment (`see api/README.md when touching endpoints`) instead of carrying it always. On-demand skills are the same move — point, don't inline.

## Scoping & precedence

Files compose; nearer and more-managed wins. Precedence, strongest last overriding: enterprise/managed → project file → user/global file → local personal (gitignored). In a monorepo, a child-directory file loads only while working there and overrides files farther up the tree — keep package-specific rules in the package, not the root.

## Maintenance — living record, then prune

Run a quick-add loop: when the agent errs in a way a rule would have prevented, add that rule. The budget breaks if you only ever add, so **periodically prune** — cut stale lines, fold duplicates, demote always-on detail behind a pointer. Without this, sediment is the file's default fate.

Reserve `IMPORTANT` / `YOU MUST` for the handful of non-negotiable, most-violated rules; spend them everywhere and they stop meaning anything.
