# Work a project issue-by-issue

Take a **project** ($project — a tracker project URL/id or a set of Issues) and drive every issue to
its own PR. `work` is the multi-Issue **conductor**: it never implements slice-by-slice itself — it
fans each Issue to its own **sub-agent** (nesting further, up to the harness's **working depth** —
`docs/agents/orchestration.md`, ≤5 on Claude Code) that **runs `implement`** for that one Issue,
while the main session orchestrates, **stacks** each dependent PR on its predecessor's branch, and
clears **HITL** issues in parallel so they join the work. If the harness has no sub-agents, run the
Issues sequentially inline; if it offers a peer-coordinated **team** (preferred for these gate-free
waves) or a workflow/pipeline primitive, drive the dependency waves with it — the gates stay in this
conductor. **Run
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
   so no issue precedes one it depends on. Move the project to **In Progress** in the tracker (unless `docs/agents/execution-states.md` marks that automated).
   → verify: every issue is classified AFK or HITL, and its dependencies are known.

3. **Gate UI work on a settled design** — For each issue that ships a new or changed UI surface, check
   whether the design is already decided: a relevant ADR or `CONTEXT.md` decision, prototype artifacts
   in the repo, or screenshots/mockups the issue references. If a UI issue has none of these, stop and
   propose a UI-refinement pass (`prototype`, or the project's bound UI-refinement skill) to settle
   the look before implementing — don't let a sub-agent invent the design mid-issue.
   → verify: every UI-bearing issue either points to a design decision / prototype / screenshots, or
   has been surfaced to the user for a `prototype` pass first.

4. **Work both tracks** — Mirror each issue's `pipeline:` row into the **task tracker** when the harness has one (per `docs/agents/orchestration.md`), so the sweep stays visible across turns; if the harness offers an unattended/goal loop, suggest the user start it toward "every issue in $project has an open PR". Then run two tracks until
   every issue has a PR:
   - **AFK** — Work the AFK issues in **dependency-ordered waves**: dispatch *every* issue whose
     dependencies all have a PR open as one **concurrent wave**, then form the next wave from issues the
     just-opened PRs unblocked. Delegate each to its own sub-agent that owns the issue end to end and
     may nest sub-agents (to the working depth) to manage its context: branch
     with a tracker-derived name (off `main`, or off the predecessor's branch when it depends on an
     unmerged issue — stacked PR); **run `implement` for that one Issue** (UI issues get a
     `prototype` pass first) — it owns the issue's **In Progress** transition, slices, tests, and
     review, stopping at the diff (the PR opens only after verify, below). On the **irreversible /
     high-blast-radius** gate, stop and confirm with the human before proceeding.
   - **Review the executor (close the loop)** — when a sub-agent returns, don't trust its report; run
     the **`review` slot** on its diff independently (it never wrote the code):
     (1) **re-run every done criterion yourself**; (2) **scope** — `git diff --stat` against the
     issue's in-scope list, any out-of-scope file fails; (3) **audit new tests for gaming** — read
     what each asserts; a test that asserts nothing passes and proves nothing. Verdict **APPROVE** /
     **REVISE** (specific actionable feedback, max 2 rounds, then **BLOCK**) / **BLOCK**. Never merge,
     push, or commit to the user's branch — merging is the user's call.
   - **Fail-stop a stuck issue, don't guess** — an executor that can't reach a clean result — a
     **BLOCK**, a crash, or a return with no reviewable, criteria-meeting diff — is a stop signal, not
     a skip. Never fabricate its PR or retry past the review cap; flag it **ready-for-human** in the
     tracker and the marker `next:` with the reason, surface it, and let the independent branches run
     on (its dependents are already gated out — no PR opened). The marker entry makes it resumable as
     that one issue, not a re-run of the whole sweep.
   - **HITL** — While that sub-agent runs, the main session works each HITL issue through `triage`. As
     an issue clears, it joins the AFK queue.
   → **verify, then ship (per issue, AFK and formerly-HITL alike)** — dispatch the **verify** slot as an
   **independent** sub-agent (not the executor, not your loop-close review); it records a verdict to
   `.workflow/<id>/NN-verify-*.md`. Only with no open FAILs: open the PR (body via `pr`, referencing the
   issue so the tracker advances) and set `verified:` in the marker.
   Once every issue has shipped and merged, **accept gates project-done**: an **independent** agent runs
   `accept` against the **live app** via the **browser** slot, recording a verdict to
   `.workflow/<id>/NN-accept-*.md`. Don't declare the project done or report it shipped while any
   predicate is FAIL/UNVERIFIED; set `accepted:` only on a clean run.

## Sub-agent contract

Each dispatched sub-agent gets the same explicit contract:

- **role** — own one Issue's **implementation** by conducting `implement` for it — delegating each inner step (prepare → slices → tests) to its own sub-agent where the harness nests, else leaving them for the top-level conductor — stopping at the diff; never the whole project, never its own verify/PR. Return a one-line verdict (`diff ready` / `blocked: <reason>`); detail goes to files, not the prompt.
- **boundary (stay in your lane)** — the conductor hands each executor the **sibling Issues it borders and the scope they own**, not just its own Issue, so it builds *only* its slice. An adjacent need a sibling owns (Issue #2 parses Word, #3 parses PDF) isn't yours — surface it as a dependency if it blocks you, never absorb it. Without this the executor knows only its own Issue, so same-wave executors each grab the ambiguous adjacent area and collide at merge; step 4's scope check catches the spill only after the work is spent.
- **depth** — nest its own sub-agents up to the working depth where that keeps context lean.
- **built-ins first** — use built-in **Explore** for reads (don't define custom agents); the
  **code-search** slot binds a semantic tool when the repo records one.
- **file contract (no telephone game)** — the sub-agent **WRITES** results to the files SKILL.md
  Durability defines (`.workflow/<id>/` scratch, `docs/` durable); the main session **READS** those
  files. Never relay long content back through the prompt.
- **worktree placement** — concurrent waves mutate the tree at once, so each executor needs its own
  worktree. Put it **workspace-local** under a gitignored `.worktrees/<issue>/`, never a sibling
  outside the workspace root — a worktree outside the opened workspace makes the executor's file,
  build, test, and git tools read as out-of-workspace access and trip repeated approval prompts.

## Marker

Track sweep state under `.workflow/<issue>/marker.md` per materialize's marker format, so a resumed
session re-orients without re-deriving the dependency graph. Each issue is **one row** on the
`pipeline:`; the executor's inner steps stay in the executor, never the conductor's marker.
