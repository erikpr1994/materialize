This mode — **wayfinder** — applies when a loose idea requires more than one agent session to turn into a plan. It builds a **decision map** in the repo's issue tracker and drives the user through a sequence of tickets that resolve the open questions — by research, prototyping, discussion, or manual task.

The tracker is the bound `tracker` capability slot; its operations (create an issue, link a blocking edge, claim, close) live in `docs/agents/issue-tracker.md` — run `init` if it's missing.

## The decision map

The map lives in the tracker, not a single file, so it scales past one context window:

- **One map issue** is the index. Its body holds the fog of war and, per ticket, a one-line gist plus a link to the ticket, along with the blocking edges between them. It **gists and links; it never restates** a ticket's answer.
- **Each ticket is a child issue** of the map. The ticket body holds the question and, once resolved, the answer — the answer lives here and only here.

A session loads the **map issue at low resolution** — the index — then zooms into a single ticket to resolve it. You never need the whole map in context at once; that is what lets it grow.

### Ticket structure

Each ticket is a child issue:

```markdown
Title: <outcome-framed question>

Blocked by: <ticket links, via the tracker's native dependency mechanism>
Type: Research | Prototype | Discuss | Task

## Question

<question-here>

## Answer

<recorded when the ticket is resolved, then the issue is closed>
```

Size each ticket to one 100K-token agent session.

## Ticket Types

There are four types of tickets:

- **Research**: Reading documentation, third-party API's, or local resources like knowledge bases. Creates a markdown summary as an asset. Use this when knowledge outside the current working directory is required.
- **Prototype**: Writing UI or logic code to test a hypothesis, or to explore a design space. Uses the `prototype` mode. Creates a prototype as an asset. Use this when "how should it look" or "how should it behave" is the key question.
- **Discuss**: Conversation with the agent. Uses `grill` and `model`. The default case.
- **Task**: Literal manual work that must happen before the map can move — nothing to decide, prototype, or research: moving data, signing up for a service, provisioning access. Automate it where you can; otherwise hand the user a precise checklist. Resolved when done — the answer records what was done and any facts (credentials location, new URLs, counts) later tickets depend on.

## Fog of war

The map is _deliberately_ incomplete beyond the frontier. The fog lives in the map issue's body. Your job is to investigate the frontier and resolve tickets to push it forward — graduating a patch of fog into one or more child tickets, one node at a time. When fog graduates into a ticket, clear that patch from the map issue so a question never lives in two places.

At some point, the fog of war should have been pushed back far enough that the path to the finish line is clear. At that point, no more tickets will be required and the decision map can be considered 'done'.

**Fog or ticket?** Whether you can _state_ the question sharply now — not whether you can answer it. A blocked ticket you can't act on yet is still a ticket; fog is what you can't yet phrase that sharply. Don't pre-slice fog into ticket-sized pieces — one patch may graduate into several tickets, or none.

## Entry points

There are two ways to enter this mode: **bootstrap** and **resume**.

### Bootstrap

User invokes with a loose idea.

1. Run a `grill` and `model` session to surface the open decisions.
2. Create the **map issue** — mostly fog, frontier identified — and open a child ticket for each frontier question, resolving trivially-decidable ones inline. Record each ticket's gist, link, and blocking edges in the map issue.
3. Stop. Map-building is one session's work; do not also resolve tickets.

### Resume

User invokes with the map issue and a ticket.

1. Load the map issue (the index) and **claim** the ticket through the tracker so parallel agents don't collide.
2. Resolve it, invoking modes as needed. If in doubt, use `grill` and `model`. Record the answer in the ticket body and close it.
3. Update the map issue: replace the ticket's fog with its gist plus link, and open any newly-discovered child tickets with correct blocking edges.
4. Stop.

If the decisions made invalidate other tickets, update or close them.

## Parallelism

Tickets run in parallel — **claim** a ticket through the tracker before working it, and expect other agents to be resolving siblings. Native blocking edges keep a ticket from being picked up before its blockers close.

## Skipping The Decision Map

Many times, the initial grilling will result in no fog of war. No unresolved tickets. Nothing to do, except implement.

In those situations, you should offer the user the chance to skip the decision map - since the decision map is only needed if multi-session decisions need to be made.

If they skip it, you should recommend either implementing directly or using `prd` to schedule a multi-session implementation.
