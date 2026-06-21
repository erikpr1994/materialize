---
name: materialize
description: "The conductor for non-trivial development work: takes an idea — however rough — all the way to shipped code, picking the right amount of process (a one-line fix vs. a full product spec) and driving it end to end rather than ad hoc. Triggers on mapping a loose idea into open questions, grilling a plan to shared understanding, researching unknowns, writing a PRD, breaking work into issues, technical or domain design, prototyping UI, implementing a feature, test-driven development, code review, independent verification, writing a PR description, debugging to root cause, improving architecture, or resolving merge conflicts. Not for one-off prose or writing tasks."
argument-hint: "[mode|workflow] [target]"
user-invocable: true
---

`materialize` is the **conductor**: it matches ceremony to the task, chains the right phases, and drives them to completion — never reimplementing a phase inline when a mode owns it.

## Setup

1. If the user invoked a **mode** (`map`, `prd`, `implement`, …), read `reference/<mode>/<mode>.md` next.
2. **Setup check.** Run the **`init`** mode if `docs/agents/.init-version` is missing or differs from the skill's `.skill-version` — first-time setup, or a reconcile after a skill upgrade (`init` is idempotent: it keeps existing config and backfills only what's missing). Skip if already checked this session. On Claude Code the `SessionStart` hook `init` installs does this number-compare automatically; the inline check covers harnesses without hooks.
3. Read at least one representative file to match the repo's conventions before producing anything.

## Conduct the work

### 1. Mint the work-item ID

First, before anything else. The ID keys the `.workflow/<id>/` scratch dir, the marker, and `NN-{phase}-{slug}.md` artifacts.

- Existing tracker Issue → use its number/key.
- From scratch → mint a 2–4 word kebab-case slug from the request.
- Return the ID to the user immediately so they can resume later.

### 2. Pick the workflow

Present the four; suggest a default, the user's pick wins. A workflow named in the invocation (`/materialize spec …`) is the pick — skip the recommendation.

| Workflow | For | Phases |
|---|---|---|
| **QUICK** | typo, one-liner, obvious fix | implement → PR |
| **STANDARD** | a single feature | research → design → prepare → implement → verify → PR |
| **SPEC** | a feature needing a product spec | research → PRD → design → issues → [per issue: prepare → implement → verify → review → pr] → merge → accept |
| **FREEFORM** | ad-hoc, no fixed shape | nothing — just work |

`design` happens **once** up front; `issues` then slices that design, and each issue implements a slice. `accept` is a final `verify` pass at PRD scope — the whole spec end-to-end against the running app; unresolved FAILs become new issues (see `verify`). `map`, `grill`, `triage`, and `debug` are **invoked on demand at any phase** — not pipeline steps.

**Entering with existing inputs:** accept an already-made artifact (a `docs/` path or link) and enter at the phase it satisfies, skipping upstream phases. Existing PRD → enter at **design** (or **issues** if design is settled); existing tech-design (`docs/<id>-tech-design.md`) → enter at **issues**/**prepare**.

When the idea is still loose and unsequenced, start with **`map`** to turn it into open-question tickets before picking a workflow.

### 3. Autonomy — the three gates

Auto-advance through autonomous phases, fanning out via whatever orchestration the host harness supports (see **Orchestration**). Halt only at one of the **three gates**:

1. **gated-design** — UI/visual work with no settled design.
2. **irreversible / high-blast-radius** — migration, delete, deploy, force-push.
3. **genuine blocker** — missing info, or a decision only a human can supply.

Three standing rules reinforce the gates:

- **Leverage checkpoint.** On STANDARD/SPEC, before `implement`, surface the plan artifact (research doc, tech-design, PRD) for an explicit go/no-go — review the *plan*, not the diff: a wrong line of plan becomes thousands of wrong lines of code. QUICK/FREEFORM stay gate-free.
- **Completeness gate.** A spec-producing phase (`prd`, `model`, `research`) emits a literal `[NEEDS CLARIFICATION: …]` token per unresolved branch, and may not exit while any remain.
- **Pipeline gate.** The pipeline for the chosen workflow type (see **Workflow types**) is a contract, not a menu. Stamp the workflow's prescribed phases into the marker `pipeline:` when you pick it, then mark each `done` or `skipped: <reason>` as you reach it; never declare done or open a PR while any stays pending. Two phases carry an independent contract the orchestrator cannot self-satisfy: **verify** (an *independent* agent — never the implementer, never your loop-close review — records a predicate verdict, no open FAILs) and **accept** (independent verify at PRD scope, driving the live app through the **browser** slot before a SPEC project is done). Set `verified:`/`accepted:` in the marker; refuse to declare done otherwise.

### 4. Recommend the next step + context strategy

End every phase by stating what to trigger next and how to carry context — exactly one of: **continue inline** (small phase, context lean), **fan out** (parallel sub-agents nested to the working depth, or a workflow primitive — per **Orchestration**), or **reset to a clean context** (re-seed from marker + committed artifacts between heavy phases: research → design, design → implement).

## Capability slots

Swappable phases delegate to per-repo bindings, each falling back to a built-in default when nothing is bound. The slot names below are the **canonical binding keys** — the `init` mode writes bindings under these exact names.

| Slot | Phase it powers | Default |
|---|---|---|
| **code-search** | research | built-in Explore |
| **UI/design** | prototype | built-in `prototype` mode |
| **review** | review | built-in `review` mode |
| **verify** | verify | built-in `verify` mode |
| **browser** | accept, verify (live UI) | manual run |
| **tracker** | issues, triage, work | local markdown issues |

A repo binds whatever installed skill fills a slot best (e.g. a dedicated design skill on the UI/design slot, a semantic code-search tool on code-search). Bindings live in the consuming repo's config, never hardcoded here.

## Orchestration

How the conductor fans work out depends on what the **host harness** supports — sub-agents and their nesting depth, parallelism, a workflow/pipeline primitive, a native task tracker — and the limits drift with versions. `init` **investigates the live harness** and records them in `docs/agents/orchestration.md`; the conductor and `work` read that file to decide how to fan out. See [`init`](reference/init/init.md) for the full detection list and how each is probed.

**Prefer delegating the actual work to sub-agents** when the harness supports them — keep the main session a thin conductor that orchestrates and talks to the user, so it stays free to respond and is occupied only when genuine HITL input is needed. A phase's procedure loads in **whoever executes it**: when you delegate, the sub-agent reads that mode's `reference/<mode>/<mode>.md` itself — you pass the mode and work-item ID, not the procedure. Read the mode file yourself only when you're the executor (direct invocation, or no sub-agents — Setup 1). Fan a phase out across parallel sub-agents (or a workflow) up to the working depth; with none available, run inline and sequentially. A workflow primitive fits **gate-free segments** — the per-issue `work` loop above all: keep the three gates in the conductor and invoke a workflow per segment, reading its results between gates. Offer it, don't auto-spin — some harnesses gate it behind explicit opt-in. When a **task tracker** is present, the conductor and each sub-agent mirror their `pipeline:` rows into it as the live view; the marker stays the durable source of truth the gate, resume, and handoff read — with no tracker, the marker is the only view. Default when unrecorded: single-level sub-agents, no nesting, no task tracker.

## Grilling — the technique under every phase

Before building anything non-trivial, interview the user relentlessly to reach shared understanding: walk each branch of the design tree, one question at a time, each with your recommended answer. Explore the codebase (via sub-agent) to answer what you can instead of asking. When a question is spatial (layout, flow, hierarchy), **prototype it** — throwaway HTML with 2+ variants side by side — don't describe it. Full loop, branch-tracking, and the doc-grounded variant: `reference/grilling/grilling.md`.

Existing artifacts (PRD, tech-design, ADRs) are **inputs, not gospel**: any phase that hits an ambiguity, gap, or contradiction drops back to grilling to resolve it with the user, then updates the affected artifact. Skipping a phase means the artifact answered it — not that questions are closed forever.

## Durability

- **Committed to `docs/`**: `docs/<id>-tech-design.md` (technical design), ADRs, PRD, and diagram / design HTML views. The lasting record. Diagrams are **Mermaid in the markdown** (diffable, GitHub-rendering); for complex/interactive diagrams or persistent UI mockups also emit a self-contained `docs/<id>-tech-design.html` view alongside.
- **Tracker**: Issues (the plan) + their states (progress) — execution state tracks the live phase (In Progress while implementing → In Review on PR → closed on merge), leaving any tracker-automated transition alone (`docs/agents/execution-states.md`).
- **Gitignored scratch** under `.workflow/<id>/`: research docs and the marker — serves implementation, then discardable.

Root `DESIGN.md` is **reserved** for the design-system spec (colors/typography/components), owned by the UI/design phase — never the technical design.

## Marker & sessions

Keep one gitignored marker per work item at `.workflow/<id>/marker.md`, written at each phase transition and read on resume (independent of handoff):

```
work item:  <PRD link or Issue number>
workflow:   QUICK | STANDARD | SPEC | FREEFORM
entry:      <phase entered at>
phase:      <current>
pipeline:   <prescribed phases stamped at pick — each done | pending | skipped:<reason>; SPEC: one row per issue>
verified:   <verify verdict path per shipped issue, or —>
accepted:   <SPEC only: accept verdict, or —>
artifacts:  <paths from Durability: docs/<id>-tech-design.md / PRD / Issues / PRs>
next:       <next action or blocker>
```

Small workflows stay in one session. For a deep run, reset between heavy phases per step 4. To hand off mid-stream or resume someone else's, see `reference/handoff/handoff.md`.

## Modes

| Mode | Category | Description | Reference |
|---|---|---|---|
| `init` | Setup | Bind capability slots, learn project context, set conventions | [reference/init/init.md](reference/init/init.md) |
| `map` | Plan | Turn a loose idea into a sequenced map of open-question tickets | [reference/map/map.md](reference/map/map.md) |
| `grill` | Plan | Interview you relentlessly to stress-test a plan or design to shared understanding | [reference/grilling/grilling.md](reference/grilling/grilling.md) |
| `research` | Plan | Investigate open questions via sub-agents, write findings to `docs/` | [reference/research/research.md](reference/research/research.md) |
| `prd` | Plan | Write the product spec (PRD) | [reference/prd/prd.md](reference/prd/prd.md) |
| `issues` | Plan | Slice the settled design into vertical-slice issues (the plan) | [reference/issues/issues.md](reference/issues/issues.md) |
| `prepare` | Plan | Prepare a single task/issue for implementation | [reference/prepare/prepare.md](reference/prepare/prepare.md) |
| `triage` | Plan | Clear blocked / needs-info issues so they become actionable | [reference/triage/triage.md](reference/triage/triage.md) |
| `model` | Design | Domain modeling → technical design (`docs/<id>-tech-design.md`) + ADRs | [reference/model/model.md](reference/model/model.md) |
| `design` | Design | Codebase design — design it twice, then deepen | [reference/design/design.md](reference/design/design.md) |
| `prototype` | Design | Build an interactive UI prototype to settle the look | [reference/prototype/prototype.md](reference/prototype/prototype.md) |
| `implement` | Build | Implement a feature/issue slice-by-slice | [reference/implement/implement.md](reference/implement/implement.md) |
| `tdd` | Build | Test-driven development at the seams | [reference/tdd/tdd.md](reference/tdd/tdd.md) |
| `review` | Verify | Code review of the change | [reference/review/review.md](reference/review/review.md) |
| `verify` | Verify | Independently confirm the change does what it should | [reference/verify/verify.md](reference/verify/verify.md) |
| `accept` | Verify | Final whole-PRD acceptance — live end-to-end verify of the shipped spec | [reference/verify/verify.md](reference/verify/verify.md) |
| `pr` | Ship | Write the PR description | [reference/pr/pr.md](reference/pr/pr.md) |
| `debug` | Fix | Diagnose a bug to root cause | [reference/debug/debug.md](reference/debug/debug.md) |
| `architecture` | Fix | Improve codebase architecture | [reference/architecture/architecture.md](reference/architecture/architecture.md) |
| `merge` | Fix | Resolve merge conflicts | [reference/merge/merge.md](reference/merge/merge.md) |

## Base references (not modes)

Loaded by the conductor and the cross-cutting techniques — not invoked as slash-commands:

- **[`work`](reference/work/work.md)** — the multi-issue driver: many issues at once, one stacked PR each in its own sub-agent, dependency-ready issues dispatched in parallel waves, HITL blockers cleared concurrently. The conductor uses it for project-scale SPEC runs. Each issue is **one row** on the conductor's `pipeline:`; its sub-agent self-registers the inner pipeline (`prepare → implement → verify → review → pr`) as its own task list and returns a one-line verdict (`PR opened` / `blocked: <reason>`) — the inner state never enters the conductor's marker.
- **[`handoff`](reference/handoff/handoff.md)** — hand off mid-stream or resume someone else's run.
