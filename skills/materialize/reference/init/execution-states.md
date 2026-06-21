# Execution states

The work-lifecycle states an issue passes through *while it's being built* — distinct from the
[triage labels](triage-labels.md), which only get an issue *to* `ready-for-agent`. These reflect
*what's happening now*:

| State | When | Representation (edit to your tracker) |
|---|---|---|
| **In Progress** | an executor has started implementing | a `status:in-progress` label, a board column, an assignee… |
| **In Review** | a PR is open for the issue | a `status:in-review` label, a board column… |
| **Done** | the PR merged / issue closed | closed — a merged `Fixes #N` PR closes it |

**Don't double-drive automated transitions.** Many trackers move these themselves — GitHub Projects
workflows, Linear/Jira PR integrations (a linked PR → In Review, a merge → Done). A phase sets a
state **only if it's listed manual below**; an automated transition is left to the tracker, so the
agent never races or duplicates it.

- **Automated by this tracker** (leave them alone): `Done on merge` — *edit: add `In Review on PR open`, etc.*
- **Manual** (the agent sets via the `tracker` slot): `In Progress`, `In Review`
