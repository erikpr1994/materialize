---
name: ask-author
description: Ask which skill or flow fits your situation. A router over the user-invoked skills in this repo.
disable-model-invocation: true
---

# Ask Author

You don't remember every skill, so ask.

**Unsure where to start? Run `materialize`.** It's the conductor: it asks how much process the task needs (QUICK, STANDARD, SPEC, or FREEFORM), then chains the phase modes for you. Reach below only when you want to drive the steps by hand with `/materialize <mode>`.

A **flow** is a path through the modes. Most paths run along one **main flow**, and two **on-ramps** merge onto it. Everything else is standalone.

## The main flow: idea → ship

The route most work travels. You have an idea and want it built.

1. **`/materialize grill`** — sharpen the idea by interview. Stateful when you **have a codebase**: it retains what it learns in `CONTEXT.md` and ADRs, writing docs as decisions settle. No codebase? It still works — it just skips the repo deliverables and surfaces conclusions inline.
2. **Branch — can you settle every question in conversation?** If a question needs a runnable answer (state, business logic, a UI you have to see), detour through a prototype, bridged by **`/materialize handoff`** in both directions (see Crossing sessions):
   - **`/materialize handoff`** out, then open a fresh session against that file,
   - **`/materialize prototype`** to answer the question with throwaway code,
   - **`/materialize handoff`** back what you learned, and reference it from the original idea thread.
3. **Branch — is this a multi-session build?**
   - **Yes** → **`/materialize prd`** (turn the thread into a PRD) → **`/materialize issues`** (split the PRD into independently-grabbable issues). Because the issues are independent, **clear context between each one**: start a fresh session per issue and kick off **`/materialize implement`** by passing it the PRD and the single issue to work on.
   - **No** → **`/materialize implement`** right here, in the same context window.

### Context hygiene

Keep steps 1–3 in **one unbroken context window** — don't compact or clear until after `issues` — so the grilling, PRD, and issues all build on the same thinking. Each `implement` then starts fresh, working from the issue.

The limit on this is the **[smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)**: the window (~120k tokens on state-of-the-art models) within which the model still reasons sharply. If a session approaches it before `issues`, don't push on degraded — `/materialize handoff` and continue in a fresh thread.

## Workflow phases

`materialize` chains these for you; reach for them directly when driving the steps by hand.

- **`/materialize research`** — research the codebase before designing. Fans out Explore sub-agents (locator / analyzer / pattern-finder), scaled to task complexity, and writes a concept-first doc of what IS. The research phase of STANDARD / SPEC workflows.
- **`/materialize verify`** — independently confirm a change does what the spec asked, run by a **fresh** sub-agent that didn't write the code. Reports PASS / FAIL per acceptance criterion with evidence. The default verify slot. (Distinct from `/materialize review`, which critiques code _quality_.)
- **`/materialize work`** — drive a whole project issue-by-issue: one stacked PR per issue, each delegated to its own sub-agent in dependency order, while the main session clears HITL blockers in parallel. Implements each with `tdd`. Use via `/materialize work <project>`.
- **`/materialize pr`** — write a clear PR description for the current branch from the diff and originating Issue, then push it to the PR body.

## On-ramps

A starting situation that generates work, then merges onto the main flow.

- **Bugs and requests piling up** → **`/materialize triage`**. It moves issues through triage roles and produces agent-ready issues, which **`/materialize implement`** later picks up.

  Triage is only for issues **you didn't create** — bug reports, incoming feature requests, anything that arrives raw. Issues that the `issues` mode produced are already agent-ready, so **don't triage them**.

- **Starting from a tracked Issue** → **`/materialize prepare`**. It fetches the ticket from this repo's tracker, summarizes it, then hands off to `grill` and the conductor.

## Codebase health

Not feature work — upkeep.

- **`/materialize architecture`** — run whenever you have a spare moment to keep the codebase good for agents to operate in. It surfaces deepening opportunities; picking one _generates an idea_ you can take into the main flow at `grill`.

## Crossing sessions

- **`/materialize handoff`** — when a thread is full or you need to branch off (e.g. into a `prototype` session), this compacts the conversation into a markdown file. You don't continue in place — you **open a new session and reference that file** to carry the context across. It's the bridge between context windows, in either direction. Use it when you want a **fresh session** but need the **current conversation preserved**.
- **`/compact`** (built-in) — stay in the **same conversation**, letting the earlier turns be summarized. Use it at **intentional breaks between phases**, when you don't mind losing the verbatim history. Don't compact mid-phase — the agent can lose its way. `handoff` forks; `/compact` continues.

## Standalone

Off the main flow entirely.

- **`/teach`** — learn a concept over multiple sessions, using the current directory as a stateful workspace.
- **`/writing-great-skills`** — reference for writing and editing skills well.

## Precondition

**Setup runs itself.** `materialize` runs its **`init`** mode on first use (and after an upgrade) to configure the issue tracker, triage labels, and doc layout the modes assume. Custom issue trackers also work. Nothing to run by hand.
