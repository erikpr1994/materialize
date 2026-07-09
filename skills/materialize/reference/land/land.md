# Land

The change is merged. That is not the same as **shipped**. `land` closes the ownership loop — the
problem goes from "we built a fix" to "we don't have to think about it again." It runs after
`pr`/`merge` and is the terminal beat on STANDARD and SPEC; invoke it on demand after any QUICK or
FREEFORM ship too. Don't reimplement `verify` or `pr` here — this confirms and communicates, it
doesn't re-check behaviour.

Three things, in order. Skip none silently: record each in the marker's `landed:` row and the work item.

## 1. Confirm it's live in production

Merged code that never deployed, or deployed behind an off flag, has solved no one's problem. Confirm
with evidence, not assumption:

- **Deployed** — the change reached the environment users hit. Check the deploy/CI run actually
  succeeded; a green merge is not a green deploy.
- **Flag on** — if it's behind a feature flag, is the flag enabled where it needs to be? Does the flag
  itself work?
- **Works there** — exercise the real behaviour in production (or the closest environment the repo ships
  to): run it, hit the endpoint, watch the metric move, read the log line. For a user-facing surface,
  observe it live through the **browser** slot. Not "it works on my machine" — "I saw it work where users
  are."

Record `landed: confirmed (<evidence>)`. If this repo doesn't deploy — a library, a docs repo, a tool
run locally — that's `landed: n/a: <reason>`: a deliberate verdict, not a skipped step.

## 2. Tell whoever needs to know

Don't underestimate peripheral vision: knowing that someone changed how Z works today saves the next
person three hours of debugging tomorrow. Work out who's affected and tell them, where they'll see it:

- **Colleagues** — a new convention, a changed behaviour, a tricky thing to be aware of.
- **The reporter / customer** — whoever raised the problem or was blocked on it. Close the loop with them.
- **The world** — if it's user-facing and worth announcing, announce it (or hand the note to whoever does).

Living docs capture durable knowledge (the conductor's **Durability**). This is the *human* ping — who
needs to hear it now, that a doc won't reach in time.

## 3. Set up the follow-up

Shipping isn't the end of attention. Decide what to watch, and when:

- A metric or log to check once it's had real traffic — an hour, a day, a week later?
- A leftover: a `TODO`, a temporary flag to remove, a migration to finish, a deprecation to complete?

Capture each as a concrete next action — an issue, a reminder, a note in the work item — not a vague
"keep an eye on it." Then the loop is genuinely closed: nothing left implicitly assumed for someone else
to notice.

## Return

One line: the production confirmation (or `n/a: <reason>`), who was told, and any follow-up recorded —
and set the marker's `landed:` row. Then the work item is done in the full sense: nobody has to think
about this problem again.
