# To Issues

Issues **slice the already-settled design** (`design` ran once up front): each issue is a vertical slice of that design, not a place to re-decide it. If a slice hits an undecided question, drop back to grilling — don't invent the design here.

The issue tracker and triage label vocabulary should have been provided to you — run `init` if not.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes an issue reference (issue number, URL, or path) as an argument, fetch it from the issue tracker and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Issue titles and descriptions should use the project's domain glossary vocabulary, and respect accepted ADRs in the area you're touching; treat proposed ADRs as planning context only when they belong to the current work. If the plan has a decision ledger (`docs/decisions/`), read it — its records are the resolved answers the issue set must cover end-to-end without weakening their constraints.

### 3. Draft vertical slices

Break the plan into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
- A slice MAY be a deliberate prep/refactor slice that isn't end-to-end — but then it must name the user-facing half it defers AND the later slice that closes it. A deferred half no slice closes is the gap: a connective path (e.g. a read path split across a prep slice and a later UI slice) owned by no slice
</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: a user-facing slice's title is its outcome (`<user action> → <visible result>`), not a layer — a layer-only title (`"Config UI"`, `"Backend resolver"`) hides whether the vertical is covered
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **`[P]`**: mark a slice `[P]` when it has no unmet dependencies (nothing blocking it now) — `work` dispatches all `[P]` slices as one concurrent wave, then re-marks the next wave as its blockers' PRs open
- **User stories covered**: which user stories this addresses (if the source material has them)
- **Decisions covered**: which decision-ledger records (`D1`, `D2`…) this slice implements, if a ledger exists

Before presenting, trace one concrete value end-to-end through every layer against the code for the first user-facing slice (after any prep slices) — a layer no slice owns is an unowned connective step; carve a slice for it. Working from a pre-authored plan/PRD, re-derive the slices and run this trace rather than rubber-stamping the existing cut.

A blocker is not only a slice that produces a type or data another consumes. Scan each slice's acceptance criteria for a *mechanism* another parallel slice builds — a CLI flag, an endpoint, a shared utility — and record that edge too, even when no domain type flows between them. Miss it and both slices reimplement the same mechanism and collide at merge.

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?
- Is every user-facing slice end-to-end, with no connective path left unowned?
- Does the union of slices cover every ledger record? Flag any record no slice owns.

Iterate until the user approves the breakdown.

### 5. Publish the issues to the issue tracker

For each approved slice, publish a new issue to the issue tracker using the body template below.

AFK-ready issues MUST carry the correct triage label (`ready-for-agent` by default — see the tracker binding's `triage-labels.md`). Labelling is its own required step, not a flag on create: if the tracker's create call can't set labels (some connectors can't), make a follow-up label call, then read the issue back to confirm the label landed. Never report a label as applied that no tool call set — an issue missing its label isn't published.

Attach whatever evidence the slice already produced — prototype renders, design screenshots, diagrams, failing-test or log output — when the tracker supports it, so the implementing agent inherits context prose can't carry.

Publish issues in dependency order (blockers first) so you can reference real issue identifiers in the "Blocked by" field.

If the tracker or repo is PUBLIC and a slice describes a security vulnerability or where a credential lives, warn the user and get explicit confirmation before publishing it. Never put a secret value in an issue body — reference `file:line` and the credential type only. After publishing, record each created issue's URL/ID back in the source marker.

<issue-template>
## Parent

A reference to the parent issue on the issue tracker (if the source was an existing issue, otherwise omit this section).

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

Avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it here and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Acceptance criteria

Carry the EARS predicates from the source PRD/spec that this slice owns, written as `WHEN <trigger> THE SYSTEM SHALL <response>` (or the matching EARS variant) so they feed `verify` downstream.

- [ ] WHEN … THE SYSTEM SHALL …
- [ ] WHEN … THE SYSTEM SHALL …
- [ ] WHEN … THE SYSTEM SHALL …

## Blocked by

- A reference to the blocking ticket (if any)

Or "None - can start immediately" if no blockers.

</issue-template>

If the source was an existing tracker issue, it's now an epic, not a slice to implement — don't close or re-scope it, but don't leave it `ready-for-agent` either. Move it to `paused`, blocked by the child issues, with a one-line body note ("Decomposed into #N, #M — implement those, not this"). Left agent-ready, a sweep grabs the parent and builds the whole epic in one pass, orphaning the children; `paused` keeps it out of the AFK queue and surfaces it for closure once every child closes.
