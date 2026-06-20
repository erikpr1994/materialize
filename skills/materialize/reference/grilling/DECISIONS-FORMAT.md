# DECISIONS.md Format

A decision ledger records the resolved, implementation-relevant answers from grilling so they survive `prd` and `issues` intact instead of being softened into prose. It is the feature-level source of truth `CONTEXT.md` is not: the glossary says what a word *means*, `DESIGN.md` what a screen *looks like*, an ADR *why* a hard trade-off was made — the ledger says what the feature must *do*, verbatim.

One ledger per feature/plan, created lazily during grilling and committed. Lives under `docs/decisions/` (or the context's own `docs/decisions/` in a multi-context repo), parallel to `docs/adr/`.

## Structure

```md
# {Feature} — Decisions

Resolved, implementation-relevant answers from grilling. Each record is the
source of truth for downstream work; `prd` and `issues` cover every one.

## D1 — Tabs survive restart

**Resolved:** Every open tab must survive a restart with its identity and order unchanged; tabs are never collapsed into one session.
**Requirement:** On restart, the set, identity, and order of open tabs match the pre-restart state exactly.
**Constraints:** No tab merging. Order is preserved, not just membership.

## D2 — Retry preserves prior state

**Resolved:** A failed message can be retried without clearing prior messages or unsent input.
**Requirement:** Retrying a failed send leaves earlier messages and any draft input untouched.
**Constraints:** Retry is non-destructive — never clears the thread or the composer.
```

## Rules

- **Implementation-relevant answers only.** Constraints, negative requirements, edge cases, numeric defaults, ordering decisions — the precise things prose softens. Glossary terms go in `CONTEXT.md`, visual conventions in `DESIGN.md`, trade-off rationale in an ADR.
- **Keep the answer verbatim.** `Resolved` is the user's exact decision; `Requirement` is its testable restatement, not a replacement. Don't generalize "identity and order unchanged" into "persist sessions".
- **Stable IDs.** Number records `D1`, `D2`… in resolution order and never renumber — downstream skills reference them.
- **Revise in place.** If an answer changes, edit its record and keep the ID, so artifacts built on the old version are visibly out of date.
