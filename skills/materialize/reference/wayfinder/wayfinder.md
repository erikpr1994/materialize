# Wayfinder

This mode — **wayfinder** — applies when a loose idea requires more than one agent session to turn into a plan. It builds a **decision map** in the repo's issue tracker and drives the user through a sequence of issues that resolve the open questions — by research, prototyping, discussion, or manual task.

The tracker is the bound `tracker` capability slot; its operations (create an issue, link a blocking edge, claim, close) live in `docs/agents/issue-tracker.md` — run [`init`](../init/init.md) if it's missing.

## The decision map

The map lives in the tracker, not a single file, so it scales past one context window:

- **One map issue** is the index. Its body holds the fog of war and, per issue, a one-line gist plus a link to the issue, along with the blocking edges between them. It **gists and links; it never restates** an issue's answer.
- **Each issue is created as a child issue** of the map. The issue body holds the question and, once resolved, the answer — the answer lives here and only here.

A session loads the **map issue at low resolution** — the index — then zooms into a single issue to resolve it. You never need the whole map in context at once; that is what lets it grow.

### Issue structure

Each issue is created as a child of the map:

```markdown
Title: <outcome-framed question>

Blocked by: <issue links, via the tracker's native dependency mechanism>
Type: Research | Prototype | Grilling | Task

## Question

<question-here>

## Answer

<recorded when the issue is resolved, then the issue is closed>
```

These issues capture open questions to resolve, not implementation work — implementation slices are created later by the separate [`issues`](../issues/issues.md) mode.

Size each issue to one 100K-token agent session.

## Issue Types

There are four types of issues:

- **Research**: Reading documentation, third-party API's, or local resources like knowledge bases. Prefer primary sources — official docs, specs, first-party APIs — over secondary write-ups, and follow each claim to its owning source. Creates a markdown summary as an asset. Use this when knowledge outside the current working directory is required.
- **Prototype**: Writing UI or logic code to test a hypothesis, or to explore a design space. Uses the [`prototype`](../prototype/prototype.md) mode. Creates a prototype as an asset. Use this when "how should it look" or "how should it behave" is the key question.
- **Grilling**: Conversation with the agent. Uses [`grill`](../grill/grill.md) and [domain modeling](../design/domain-modeling.md). The default case.
- **Task**: Literal manual work that must happen before the map can move — nothing to decide, prototype, or research: moving data, signing up for a service, provisioning access. Automate it where you can; otherwise hand the user a precise checklist. Resolved when done — the answer records what was done and any facts (credentials location, new URLs, counts) later issues depend on.

## Fog of war

The map is _deliberately_ incomplete beyond the frontier. The fog lives in the map issue's body. Your job is to investigate the frontier and resolve issues to push it forward — graduating a patch of fog into one or more child issues, one node at a time. When fog graduates into an issue, clear that patch from the map issue so a question never lives in two places.

At some point, the fog of war should have been pushed back far enough that the path to the finish line is clear. At that point, no more issues will be required and the decision map can be considered 'done'.

**Fog or issue?** Whether you can _state_ the question sharply now — not whether you can answer it. A blocked issue you can't act on yet is still an issue; fog is what you can't yet phrase that sharply. Don't pre-slice fog into issue-sized pieces — one patch may graduate into several issues, or none.

## Entry points

There are two ways to enter this mode: **bootstrap** and **resume**.

### Bootstrap

User invokes with a loose idea.

1. Run a `grill` session with [domain modeling](../design/domain-modeling.md) to surface the open decisions.
2. Create the **map issue** — mostly fog, frontier identified — and open a child issue for each frontier question, resolving trivially-decidable ones inline. Record each issue's gist, link, and blocking edges in the map issue.
3. Stop. Map-building is one session's work; do not also resolve issues.

### Resume

User invokes with the map issue and an issue.

1. Load the map issue (the index) and **claim** the issue through the tracker so parallel agents don't collide.
2. Resolve it, invoking modes as needed. If in doubt, use `grill` with domain modeling. Record the answer in the issue body and close it.
3. Update the map issue: replace the issue's fog with its gist plus link, and open any newly-discovered child issues with correct blocking edges.
4. Stop.

If the decisions made invalidate other issues, update or close them.

## Parallelism

Issues run in parallel — **claim** an issue before working it, and expect other agents to be resolving siblings. Prefer the tracker's native assignee as the claim: an open, unassigned issue is unclaimed. Native blocking edges keep an issue from being picked up before its blockers close — native matters because the tracker's own UI then renders the frontier visually, takeable at a glance without opening the map; fall back to a body convention only when the tracker has none.

## Skipping The Decision Map

Many times, the initial grilling will result in no fog of war. No unresolved issues. Nothing to do, except implement.

In those situations, you should offer the user the chance to skip the decision map - since the decision map is only needed if multi-session decisions need to be made.

If they skip it, you should recommend either implementing directly or the SPEC workflow (PRD → issues) for multi-session work. Running as SPEC's opening phase, record the skip as the phase's `pipeline:` row (`skipped: no fog`) and continue the pipeline.
