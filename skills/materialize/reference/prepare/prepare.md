# Prepare Task

Thin orchestrator: **fetch Issue** → [`grill`](../grilling/grilling.md) → materialize. Do not implement here.

## Input gate

- Needs an **Issue ref** — an issue number, key, or URL for this repo's tracker.
- No ref in the message or `argument-hint`? **Stop and ask** for one before continuing. Don't guess ticket content.
- Starting from scratch with no Issue at all? Use materialize instead — this mode assumes an existing ticket.

## Phase 1 — Fetch the Issue

Read `docs/agents/issue-tracker.md` (recorded by `init`) to learn which tracker this repo uses, then fetch the issue that way — e.g. `gh issue view`, `glab issue view`, a `.scratch/` markdown file, or the freeform workflow the doc describes. If that doc is missing, ask the user which tracker to use.

Pull what planning needs: title, description, type/status, acceptance criteria, parent/epic, labels, and any comments that carry requirements.

### Present a summary

Brief, in-conversation:

- Ref, title, type, status
- Description + acceptance criteria
- Parent/epic and links worth following

Keep it in context — the next phases use it.

## Phase 2 — Grill

Run [`grill`](../grilling/grilling.md), seeding it with the Issue as the plan to sharpen (questions + research + design → `docs/<id>-tech-design.md` / ADRs).

### Self-contained story

prepare's output must be a self-contained story: the Issue plus its marker bundle enough that a fresh `implement` sub-agent can build from the issue+marker **alone**, without further context. Inline into the marker (or link from it):

- the research excerpts the change depends on,
- the relevant slice of `docs/<id>-tech-design.md` (not the whole doc),
- acceptance criteria / EARS predicates,
- file pointers to the code the slice touches.

### Executable handoff contract

A self-contained story isn't enough — make it executable by a zero-context implementer. The marker must also carry:

- **Out-of-scope** — files NOT to touch even if they look related, each with a one-line why.
- **Done criteria** as machine-checkable commands + expected results (`typecheck exits 0`, `grep -rn '<old>' returns nothing`), never prose like "works correctly".
- **STOP conditions** — stop and report instead of improvising when: current-state code excerpts don't match the live code, a verification fails twice after a reasonable fix, the fix needs an out-of-scope file, or a stated key assumption proves false.
- **Drift check** — record the commit SHA prepared at; the implementer diffs the in-scope paths against that SHA before starting and treats any mismatch as a STOP.

Completion gate — don't advance until all hold:

- [ ] Shared understanding reached; no open blocking questions.
- [ ] `docs/<id>-tech-design.md` / ADRs captured where the skill puts them.
- [ ] User had a chance to correct terminology and boundaries (one question at a time, wait for answers).
- [ ] Self-contained story bundled — a fresh `implement` agent could build from the issue + marker alone.
- [ ] Handoff contract present — out-of-scope list, machine-checkable done criteria, STOP conditions, and prepared-at SHA for the drift check.

If the user wants to pause, respect it — don't advance until they continue and the gate clears.

## Phase 3 — Workflow

Hand back to materialize to pick the workflow this work warrants (QUICK / STANDARD / SPEC / FREEFORM) and run its phases. Carry forward the Issue and the grill's decisions; don't re-interview.

## Rules

| Rule | Detail |
|---|---|
| Order | Phase 1 → 2 → 3 only |
| Issue required | No ref → ask, then stop |
| No coding | Don't implement the Issue in this mode |
| Chaining | Load the sibling `grilling` reference; don't paraphrase it or the workflow |
| Target repo | Work in the current workspace unless the user names another |
