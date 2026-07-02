Don't re-run the full grilling loop — synthesize the PRD from the on-disk record: the decision ledger (`docs/decisions/`), grill notes, and research doc (`.workflow/<id>/NN-research-*.md`), plus the codebase. The conversation is a cache of those files, never the source — a fresh executor must be able to produce this PRD from files alone. Ask the user only to resolve seam mismatches (step 2) and any remaining `[NEEDS CLARIFICATION]` tokens; delegated, leave the tokens in the artifact and return `blocked: needs-decision` for the conductor to grill.

**Skip the PRD for implementation-heavy work.** When the work is design or refactoring — module boundaries, invariants, data/control flow, test seams, rollout — rather than product/user-facing behavior, its home is the technical-design artifact, not a PRD: run [`model`](../model/model.md) (design + ADRs), or [`design`](../design/design.md) / [`architecture`](../architecture/architecture.md) for code shape. The STANDARD workflow already routes there without a PRD.

The issue tracker and triage label vocabulary should have been provided to you — run `init` if not.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the PRD, and respect accepted ADRs in the area you're touching; treat proposed ADRs as planning context only when they belong to the current work. If the feature has a decision ledger (`docs/decisions/`), read it — its records are the resolved answers this PRD must preserve verbatim, not soften. If the project keeps a `ROADMAP.md` (or a product/vision doc), read it so this PRD is grounded in the larger goal the slice advances.

2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.

Check with the user that these seams match their expectations.

3. Write the PRD using the template below. **Completeness gate:** emit a literal `[NEEDS CLARIFICATION: <question>]` token inline for each unresolved open question, and do not exit this phase while any remain. Before saving, check coverage: every decision-ledger record must map to a user story, implementation decision, or testing decision, with its constraints preserved exactly — surface any record you couldn't place rather than dropping it. Then write the PRD as a committed markdown file under `docs/` — this is the durable source of truth. Only publish it to the project issue tracker if the user asks for it; when you do, apply the `ready-for-agent` triage label - no need for additional triage. If a `ROADMAP.md` tracks this work, move the slice you just specified to its `Now`/`Done` bucket and link this PRD, so the roadmap stays a live picture of what's left.

<prd-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Acceptance Criteria

Write each criterion as an EARS predicate — `WHEN <trigger> THE SYSTEM SHALL <response>` — using the right EARS variant: ubiquitous (`THE SYSTEM SHALL`), event (`WHEN`), state (`WHILE`), unwanted-behaviour (`IF … THEN THE SYSTEM SHALL`), optional (`WHERE`). One testable predicate per criterion; these feed `issues` and `verify` downstream. Default to EARS in SPEC.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.

</prd-template>
