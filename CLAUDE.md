# What this repo is

**Materialize** ([`erikpr1994/Materialize`](https://github.com/erikpr1994/Materialize)) is a standalone repo.
The engineering pipeline that tools like [`mattpocock/skills`](https://github.com/mattpocock/skills) ship as
~two dozen separate skills is collapsed here into a single model-invoked conductor,
**[`materialize`](skills/materialize/SKILL.md)**, with each phase a `reference/<mode>/` loaded on demand. We
own our own path.

**Inspired by, not tracking.** We read [`mattpocock/skills`](https://github.com/mattpocock/skills) and other
community skill repos for *ideas* — borrow concepts, reimplement them our way. We never rebase onto them or
copy code verbatim; they're a read-only window onto good thinking, nothing more.

## Remotes

- `origin` → `erikpr1994/Materialize` (this repo — push here)
- `upstream` → `mattpocock/skills` (optional reference remote, for reading their work — never push, never rebase onto)

```bash
git fetch upstream    # read what upstream changed, for ideas only — no rebase
```

## How it's consumed

Other repos install from it:

```bash
npx skills@latest add erikpr1994/Materialize
npx skills update
```

# Architecture: the single-skill conductor

`materialize` is the one model-invoked skill that fronts the whole idea→ship pipeline. The design goal is to
spend **one description** in the agent's session-start context (instead of one per phase) while keeping
autonomous triggering, with phase detail progressively disclosed.

- `skills/materialize/SKILL.md` — the **router**: the always-on base (conductor / workflow-type picker /
  autonomy / capability slots / grilling / durability / marker) plus the **Modes** command table.
- `skills/materialize/reference/<mode>/<mode>.md` — one folder per phase (`map`, `prd`, `implement`, `tdd`,
  `review`, …). Reached via `/materialize <mode>` or by the conductor; **no per-mode skill description** (that's
  the context win). Sibling files (`tdd`'s `tests.md`, `prototype`'s `LOGIC.md`, …) live alongside their mode.
- Base references not in the Modes table (`work` multi-issue driver, `grilling` family, `handoff` family) also
  live under `reference/`, pulled in by the base prose.

**Adding or changing a phase** = add/edit a `reference/<mode>/` and a row in the SKILL.md Modes table. Do **not**
create a new top-level skill for a phase. Cross-references between modes use relative paths
(`../tdd/tdd.md`), never slash-commands or `SKILL.md` links.

**Capability slots** (`code-search`, `UI/design`, `review`, `verify`, `tracker`) are bound per consuming repo via
the `init` mode. The committed files name the *slot*, never a third-party product — a repo binds e.g. a design
skill to the UI slot in its own config.

# Repo conventions

Beyond `materialize`, a couple of standalone skills live under `skills/`:

- `productivity/` — non-code workflow tools (`teach`, `writing-great-skills`)
- `in-progress/` — drafts not yet ready to ship

`materialize` and every skill in `productivity/` must have a reference in the top-level `README.md` and an
entry in `.claude-plugin/plugin.json`. Skills in `in-progress/` must not appear in either. Each `README.md`
entry links the skill name to its `SKILL.md`. Each bucket folder's `README.md` lists its skills with a
one-line description, name linked to `SKILL.md`.

**Keep skill prose terse.** Short sections, often 1-3 sentences, no preamble or restated rationale. When adding to
a skill, write the minimum that conveys the instruction and mirror the density of the surrounding sections. Don't
bloat skills. Run the [`writing-great-skills`](skills/productivity/writing-great-skills/SKILL.md) lens over
material changes to `materialize`.

## Git & PR hygiene

- `main` is PR-protected: branch, open a PR, squash-merge. Never push directly to `main`.
- No third-party repo references in commits or PR titles/descriptions. The `owner/repo#NNN` form and full
  `github.com/owner/repo/...` URLs both ping that repo's tracker; bare `#NNN` dangles. When a change comes from a
  watch-list source, describe it generically ("a watch-list triage item") — the source identity lives only in
  source-triage's `LOG.md`, the one place it belongs.
