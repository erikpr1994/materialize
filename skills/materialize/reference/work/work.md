# Work a project issue-by-issue

Take a **project** ($project — a tracker project URL/id or a set of Issues) and drive every issue to
its own PR. `work` is the multi-Issue **conductor**: it never implements slice-by-slice itself — it
fans each Issue to its own **sub-agent** (nesting further, up to the harness's **working depth** —
`docs/agents/orchestration.md`, ≤5 on Claude Code) that **runs `implement`** for that one Issue,
while the main session orchestrates, **stacks** each dependent PR on its predecessor's branch, and
clears **HITL** issues in parallel so they join the work. If the harness has no sub-agents, run the
Issues sequentially inline; if it offers a workflow/pipeline primitive, drive the dependency waves
with it. **Run
autonomously by default**: keep moving through the **AFK** (agent-actionable) issues in dependency
order without stopping.

**Stop only at the three gates defined in SKILL.md** — gated-design here is step 3 (a UI issue with
no settled design). Everything else runs to completion without check-ins.

## Workflow

Each step states its success check. Do not advance until the check passes.

1. **Load context** — Read the project at $project and all its issues via the **Issue tracker**. Read
   every ADR (`docs/adr/`), `CONTEXT.md`, and any docs the issues reference.
   → verify: you can name every issue, its acceptance criteria, and the dependencies between them.

2. **Partition and order** — Build the dependency graph. Classify each issue as **AFK**
   (agent-actionable now: `ready-for-agent` or already actionable) or **HITL** (blocked on a human:
   `needs-info` / `ready-for-human` label, **Triage** state, or a pending decision). Order the graph
   so no issue precedes one it depends on. Move the project to **In Progress** in the tracker.
   → verify: every issue is classified AFK or HITL, and its dependencies are known.

3. **Gate UI work on a settled design** — For each issue that ships a new or changed UI surface, check
   whether the design is already decided: a relevant ADR or `CONTEXT.md` decision, prototype artifacts
   in the repo, or screenshots/mockups the issue references. If a UI issue has none of these, stop and
   propose a UI-refinement pass (`prototype`, or the project's bound UI-refinement skill) to settle
   the look before implementing — don't let a sub-agent invent the design mid-issue.
   → verify: every UI-bearing issue either points to a design decision / prototype / screenshots, or
   has been surfaced to the user for a `prototype` pass first.

4. **Work both tracks** — Create one task per issue (TaskTool) so the sweep continues across turns; the model can't set a `/goal` itself, so suggest the user run `/goal "every issue in $project has an open PR"` to drive it unattended. Then run two tracks until
   every issue has a PR:
   - **AFK** — Work the AFK issues in **dependency-ordered waves**: dispatch *every* issue whose
     dependencies all have a PR open as one **concurrent wave**, then form the next wave from issues the
     just-opened PRs unblocked. Delegate each to its own sub-agent that owns the issue end to end and
     may nest sub-agents (to the working depth) to manage its context: move the issue to **In Progress**; branch
     with a tracker-derived name (off `main`, or off the predecessor's branch when it depends on an
     unmerged issue — stacked PR); **run `implement` for that one Issue** (UI issues get a
     `prototype` pass first) — it owns the slices, tests, and review, stopping at the diff (the PR
     opens only after verify, below). On the **irreversible /
     high-blast-radius** gate, stop and confirm with the human before proceeding.
   - **Review the executor (close the loop)** — when a sub-agent returns, don't trust its report:
     (1) **re-run every done criterion yourself**; (2) **scope** — `git diff --stat` against the
     issue's in-scope list, any out-of-scope file fails; (3) **audit new tests for gaming** — read
     what each asserts; a test that asserts nothing passes and proves nothing. Verdict **APPROVE** /
     **REVISE** (specific actionable feedback, max 2 rounds, then **BLOCK**) / **BLOCK**. Never merge,
     push, or commit to the user's branch — merging is the user's call.
   - **HITL** — While that sub-agent runs, the main session works each HITL issue through `triage`. As
     an issue clears, it joins the AFK queue.
   → **verify, then ship (per issue, AFK and formerly-HITL alike)** — dispatch the **verify** slot as a
   fresh sub-agent that did **not** write the issue's code (distinct from your loop-close review above);
   it records a predicate verdict to `.workflow/<id>/NN-verify-*.md`. Only with no open FAILs: open the
   PR (body via `pr`, referencing the issue so the tracker advances) and set `verified:` in the marker.
   Once every issue has shipped, run **accept** (whole-PRD live verify through the **browser** slot)
   before declaring the project done; set `accepted:`.

## Sub-agent contract

Each dispatched sub-agent gets the same explicit contract:

- **role** — own one Issue end to end by running `implement` for it; never the whole project.
- **depth** — nest its own sub-agents up to the working depth where that keeps context lean.
- **built-ins first** — use built-in **Explore** for reads (don't define custom agents); the
  **code-search** slot binds a semantic tool when the repo records one.
- **file contract (no telephone game)** — the sub-agent **WRITES** results to the files SKILL.md
  Durability defines (`.workflow/<id>/` scratch, `docs/` durable); the main session **READS** those
  files. Never relay long content back through the prompt.

## Marker

Track sweep state under `.workflow/<issue>/marker.md` per materialize's marker format, so a resumed
session re-orients without re-deriving the dependency graph.
