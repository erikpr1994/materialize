---
name: materialize
description: "The conductor for non-trivial development work: takes an idea — however rough — all the way to shipped code, picking the right amount of process (a one-line fix vs. a full product spec) and driving it end to end rather than ad hoc. Triggers on mapping a loose idea into open questions, grilling a plan to shared understanding, researching unknowns, writing a PRD, breaking work into issues, technical or domain design, prototyping UI, implementing a feature, test-driven development, code review, independent verification, writing a PR description, debugging to root cause, improving architecture, or resolving merge conflicts. Not for one-off prose or writing tasks."
argument-hint: "[mode|workflow] [target]"
user-invocable: true
---

`materialize` is the **conductor**: it matches ceremony to the task, chains the right phases, and drives them to **done** — never reimplementing a phase inline when a mode owns it. **Done means ownership**: the problem goes from "we have a problem" to "we don't have to think about it again" — the change confirmed live in production, communicated to whoever needs to know, and set up for any follow-up, not merely merged. Longer-form prose and writing tasks belong to the sibling `articulate` skill, not here.

## Setup

1. If the user invoked a **mode** (`wayfinder`, `prd`, `implement`, …), read that mode's reference file as listed in the Modes table next.
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
| **STANDARD** | a single feature | research → grill → prototype → design → prepare → implement → verify → PR → land |
| **SPEC** | a feature needing a product spec | wayfinder → research → PRD → prototype → design → issues → [per issue: prepare → implement → review → verify → pr] → merge → accept → land |
| **FREEFORM** | ad-hoc, no fixed shape | nothing — just work |

The design phases — **`prototype`** (UI, via the UI/design slot) then **`design`** (technical) — happen **once** up front. `prototype` settles the look of any user-facing surface and runs by default; **skip it only when the work has no UI**, recording the skip as its `pipeline:` row (`skipped: no UI surface`) — never silently drop it. `issues` then slices the settled design, and each issue implements a slice. `accept` is a final `verify` pass at PRD scope — the whole spec end-to-end against the running app; unresolved FAILs become new issues (see `verify`). **`land`** is the terminal beat on STANDARD/SPEC (invokable on demand after any ship): confirm the change is live in production — deployed, any flag on, working there — then tell whoever needs to know and record any follow-up. Merged is not shipped. STANDARD's **`grill`** step resolves research's `[NEEDS CLARIFICATION]` tokens with the user and ends only when they confirm shared understanding — never skip it silently. SPEC opens with **`wayfinder`** — the decision map for discovery bigger than one session; when its opening grill leaves no fog, record `skipped: no fog`. `triage` and `debug` are **invoked on demand at any phase** — not pipeline steps; `grill` and `wayfinder` stay invokable anywhere too.

**Entering with existing inputs:** accept an already-made artifact (a `docs/` path or link) and enter at the phase it satisfies, skipping upstream phases. Existing PRD → enter at **prototype** (or **design**/**issues** if the UI and design are already settled); existing tech-design (`.workflow/<id>/tech-design.md`) → enter at **issues**/**prepare**.

When the idea is still loose and unsequenced, start with **`wayfinder`** to turn it into open-question issues before picking a workflow.

### 3. Autonomy — the three gates

Auto-advance through autonomous phases, fanning out via whatever orchestration the host harness supports (see **Orchestration**). Halt only at one of the **three gates**:

1. **gated-design** — a user-facing surface whose look isn't settled. The `prototype` phase settles it (UI/design slot); halt there for sign-off before `design`/`implement`. Never fold UI design into the tech-design or defer it to the implementer.
2. **irreversible / high-blast-radius** — migration, delete, deploy, force-push.
3. **genuine blocker** — missing info, or a decision only a human can supply.

Four standing rules reinforce the gates:

- **Ask, don't assume.** When a choice materially changes the output and the user's intent isn't certain, **ask rather than guess** — one question at a time, each with your recommended answer (per **Grilling**). Resolve from the codebase and existing artifacts first; ask the moment real doubt remains, front-loaded over discovering the gap mid-build. A **delegated executor usually can't reach the user** (`docs/agents/orchestration.md` records whether yours can): it finishes everything the answer doesn't change, records each open question in its artifact as `[NEEDS DECISION: <question> — recommend: <answer>]`, and returns `blocked: needs-decision`. The conductor asks the user exactly those questions, records the answers in the decision ledger, and re-dispatches.
- **Leverage checkpoint.** On STANDARD/SPEC, before `implement`, surface the plan artifact (research doc, UI prototype / DESIGN.md, tech-design, PRD) for an explicit go/no-go — review the *plan*, not the diff: a wrong line of plan becomes thousands of wrong lines of code. QUICK/FREEFORM stay gate-free.
- **Completeness gate.** A spec-producing phase (`prd`, `design`) emits a literal `[NEEDS CLARIFICATION: …]` token per unresolved branch, and may not exit while any remain. `research` emits the same tokens but exits with them open — the pipeline step after it (`grill` on STANDARD, `prd` on SPEC) clears them with the user. This is distinct from `NEEDS DECISION`: clarification tokens mark unresolved branches inside an artifact, decision tokens are a delegated executor's escalation of a blocked question to the conductor.
- **Pipeline gate.** The pipeline for the chosen workflow type (see **Pick the workflow**) is a contract, not a menu. Stamp the workflow's prescribed phases into the marker `pipeline:` when you pick it, then mark each `done` or `skipped: <reason>` as you reach it; never declare done or open a PR while any stays pending. Three phases carry an independent contract the orchestrator cannot self-satisfy: **verify** (an *independent* agent — never the implementer, never your loop-close review — records a predicate verdict, no open FAILs), **accept** (independent verify at PRD scope, driving the live app through the **browser** slot before a SPEC project is done), and **land** (the change confirmed live in production — deployed, any flag on, working there — not merely merged; `n/a: <reason>` when the repo doesn't deploy). Set `verified:`/`accepted:`/`landed:` in the marker; refuse to declare done otherwise. The marker's `docs:` row is part of the same contract: stamp it `pending` at pick, and never declare done or open a PR until it reads `synced` or `nothing-to-sync: <reason>` (see **Durability**).

### 4. Recommend the next step + context strategy

End every phase by stating what to trigger next and how to carry context. A pipeline run **delegates every phase to its own sub-agent** (per **Orchestration**) — choose **fan out** (independent phases in parallel) or **sequential delegation** (one sub-agent per phase, re-seeded from marker + committed artifacts between heavy phases: research → design, design → implement). Run a phase inline **only** when the harness has no sub-agents.

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

**Delegate every phase of a pipeline run to its own sub-agent** whenever the harness has sub-agents — the main session is a **pure conductor**: it picks the next phase, spawns one sub-agent to run it, reads the verdict back, and never runs phase work itself. It stays free to respond, occupied only at genuine HITL (human-in-the-loop) input. A phase's procedure loads in **whoever executes it**: when you delegate, you pass the mode's reference path (as listed in the Modes table) and the work-item ID, and the sub-agent reads that reference file itself — not the procedure. Read the mode file yourself only when you **are** the executor — a direct single-mode invocation, or a harness with no sub-agents (Setup 1).

**Executor return contract — paths, not content.** Every delegated executor, whatever the mode, ends the same way: results in files per **Durability**, and a **one-line verdict + artifact path** (when the mode produces one) back through the prompt. The conductor routes paths: it hands the next executor the artifact paths and reads at most an artifact's opening verdict/summary block — an artifact's full reader is the next executor, never the conductor.

**Depth.** Run independent phases as parallel sub-agents, dependent ones one sub-agent at a time, nested to the working depth. **Where the harness allows no nesting, the top-level conductor flattens** — driving each inner phase (down to an issue's prepare → implement → tests) as its own single-level child rather than running it inline. Only with **no sub-agents at all** does a phase run inline and sequentially.

**Choosing the primitive** — at every fan-out the host may offer three: lead-reporting **sub-agents**, a deterministic **workflow/pipeline**, and a peer-coordinated **team** (independent sessions sharing a task list, messaging each other). Pick in order: (1) **crosses a gate** (gated-design, irreversible, genuine blocker) → **conductor keeps it**, sub-agents only, never a team or workflow. (2) gate-free, by shape: single phase or dependent chain → **sub-agent(s)**; fan-out over a known list of independent items with deterministic control flow → **workflow**; parallel units that must coordinate — claim shared work, message peers, per-issue `work` dependency-waves → **team**. Sub-agents are the portable **baseline**: when the fitter primitive is absent or disabled, degrade to sub-agents, then inline. Offer richer primitives, don't auto-spin — some are experimental/opt-in and a team costs markedly more tokens. `init` records what exists in `docs/agents/orchestration.md`; read it for the live menu.

When a **task tracker** is present, the conductor and each sub-agent mirror their `pipeline:` rows into it as the live view; the marker stays the durable source of truth the gate, resume, and handoff read — with no tracker, the marker is the only view. Default when unrecorded: single-level sub-agents, no nesting, no task tracker.

## Grilling — the technique under every phase

Before building anything non-trivial, interview the user relentlessly to reach shared understanding: walk each branch of the design tree, one question at a time, each with your recommended answer. Explore the codebase (via sub-agent) to answer what you can instead of asking. When a question is spatial (layout, flow, hierarchy), **prototype it** — throwaway HTML with 2+ variants side by side — don't describe it. Full loop, branch-tracking, and the doc-grounded variant: `reference/grill/grill.md`.

Existing artifacts (PRD, tech-design, ADRs) are **inputs, not gospel**: any phase that hits an ambiguity, gap, or contradiction drops back to grilling to resolve it with the user, then updates the affected artifact. Skipping a phase means the artifact answered it — not that questions are closed forever.

## Durability

- **Living docs, committed**: `CONTEXT.md`, `DESIGN.md`, `ROADMAP.md`, `docs/adr/`, `docs/decisions/`, and the PRD under `docs/`. The lasting record — no file named after a work item ever lands in `docs/`. Diagrams are **Mermaid in the markdown** (diffable, GitHub-rendering).
- **Promote on settle**: the moment a phase settles something durable, route it to its living doc — term → `CONTEXT.md`, UI convention → `DESIGN.md`, hard trade-off → ADR, implementation-relevant answer → the feature's decision ledger, scope shift → `ROADMAP.md` — and set the marker's `docs:` row: `synced` (with paths) or `nothing-to-sync: <reason>`. Per-work-item artifacts draft knowledge; living docs keep it.
- **Tracker**: Issues (the plan) + their states (progress) — execution state tracks the live phase (In Progress while implementing → In Review on PR → closed on merge), leaving any tracker-automated transition alone (`docs/agents/execution-states.md`).
- **Gitignored scratch** under `.workflow/<id>/`: research docs, the technical design (`tech-design.md`, plus a self-contained `.html` view when a diagram or mockup needs one), and the marker — serves the work item, then discardable.
- **Human-facing prose reads like prose**: a deliverable meant for a person — wayfinder map, PRD, design doc, issue body, PR description — reads like explaining the work to a teammate, not machine output. Short paragraphs that say why; a concrete value such as a flag or default named in a sentence; where things live pointed to in plain English ("the coverage-email job"), never fenced code, a `path/to/file.ts:65` line, or backtick soup. Dense technical detail belongs in the code change, not the prose. This is the readability axis; avoiding paths/snippets that *go stale* (`prd`, `issues`) is the separate durability axis — both hold at once.

Root `DESIGN.md` is **reserved** for the design-system spec (colors/typography/components). The UI/design phase is its **authority**; other modes (design, grilling) may append settled conventions there. It never holds the technical design.

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
landed:     <production-live confirmation: pending | confirmed (evidence) | n/a:<reason>>
docs:       <living-docs sync: pending | synced (paths) | nothing-to-sync:<reason>>
artifacts:  <paths from Durability: tech-design / PRD / Issues / PRs>
next:       <next action or blocker>
```

Small workflows stay in one session. For a deep run, reset between heavy phases per step 4. At a phase boundary the marker plus its `artifacts:` paths **are** the conductor's working state: after any context compaction or session reset, re-anchor by re-reading the marker — never trust a summarized history over it. To hand off mid-stream or resume someone else's, see `reference/handoff/handoff.md`.

## Modes

| Mode | Stage | Description | Reference |
|---|---|---|---|
| `init` | Setup | Bind capability slots, learn project context, set conventions | [reference/init/init.md](reference/init/init.md) |
| `wayfinder` | Plan | Plan work too big for one agent session — a sequenced map of open-question issues | [reference/wayfinder/wayfinder.md](reference/wayfinder/wayfinder.md) |
| `grill` | Plan | Interview you relentlessly to stress-test a plan or design to shared understanding | [reference/grill/grill.md](reference/grill/grill.md) |
| `research` | Plan | Investigate open questions via sub-agents, write findings to `.workflow/<id>/` | [reference/research/research.md](reference/research/research.md) |
| `prd` | Plan | Write the product spec (PRD) | [reference/prd/prd.md](reference/prd/prd.md) |
| `issues` | Plan | Slice the settled design into vertical-slice issues (the plan) | [reference/issues/issues.md](reference/issues/issues.md) |
| `prepare` | Plan | Prepare a single task/issue for implementation | [reference/prepare/prepare.md](reference/prepare/prepare.md) |
| `triage` | Plan | Clear blocked / needs-info issues so they become actionable | [reference/triage/triage.md](reference/triage/triage.md) |
| `design` | Design | Codebase design — design it twice, then deepen; domain modeling + ADRs when domain-heavy; writes `.workflow/<id>/tech-design.md` | [reference/design/design.md](reference/design/design.md) |
| `prototype` | Design | Build an interactive UI prototype to settle the look | [reference/prototype/prototype.md](reference/prototype/prototype.md) |
| `implement` | Build | Implement a feature/issue slice-by-slice | [reference/implement/implement.md](reference/implement/implement.md) |
| `tdd` | Build | Test-driven development at the seams | [reference/tdd/tdd.md](reference/tdd/tdd.md) |
| `review` | Verify | Code review of the change | [reference/review/review.md](reference/review/review.md) |
| `verify` | Verify | Independently confirm the change does what it should | [reference/verify/verify.md](reference/verify/verify.md) |
| `accept` | Verify | Final whole-PRD acceptance — live end-to-end verify of the shipped spec | [reference/verify/verify.md](reference/verify/verify.md) |
| `pr` | Ship | Write the PR description | [reference/pr/pr.md](reference/pr/pr.md) |
| `land` | Ship | Confirm it's live in production, tell who needs to know, record follow-up | [reference/land/land.md](reference/land/land.md) |
| `debug` | Fix | Diagnose a bug to root cause | [reference/debug/debug.md](reference/debug/debug.md) |
| `architecture` | Fix | Improve codebase architecture | [reference/architecture/architecture.md](reference/architecture/architecture.md) |
| `test-debt` | Fix | Prune low-value tests; refocus the suite on observable behavior | [reference/test-debt/test-debt.md](reference/test-debt/test-debt.md) |
| `merge` | Fix | Resolve merge conflicts | [reference/merge/merge.md](reference/merge/merge.md) |

## Base references (not modes)

Loaded by the conductor and the cross-cutting techniques — not invoked as slash-commands:

- **[`work`](reference/work/work.md)** — the multi-issue driver: many issues at once, one stacked PR each, dependency-ready issues dispatched in parallel waves, HITL blockers cleared concurrently. The conductor uses it for project-scale SPEC runs. Each issue is **one row** on the conductor's `pipeline:`; its executor owns implementation through the inner phases and returns a one-line verdict (`diff ready` / `blocked: <reason>`), stopping at the diff. The conductor then runs the **independent** review → verify the gate requires and opens the PR, marking the row done — the executor's inner state never enters the conductor's marker.
- **[`handoff`](reference/handoff/handoff.md)** — hand off mid-stream or resume someone else's run.
