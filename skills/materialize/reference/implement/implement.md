`implement` is the single-Issue/PRD **executor**: it works ONE unit sequentially, slice by slice. (The multi-Issue driver is [`work`](../work/work.md), which dispatches one `implement` per Issue — don't re-do its orchestration here.)

Implement the work described by the user in the PRD or issues.

**Before coding (STANDARD/SPEC), clear two gates:**

- **Leverage checkpoint** (see SKILL.md). The plan artifact (research doc, tech-design, PRD) must have an explicit human go/no-go before implementation starts. No go, no code.
- **Principles check.** Verify the plan against `docs/agents/principles.md` (written by `init`). If a principle is intentionally violated, record an explicit justification line in the marker and the PR.

When coding starts, move the issue to its **In Progress** state via the `tracker` slot — unless `docs/agents/execution-states.md` marks that transition automated (then the tracker moves it; don't double-drive).

If the PRD has been broken into issue slices, work through the slices in order — each is an implementable unit. Don't implement from the PRD alone.

Use [`tdd`](../tdd/tdd.md) where possible, at pre-agreed seams.

Run typechecking and single test files regularly; run the full suite once at the end.

Hitting the irreversible / high-blast-radius gate (SKILL.md), stop and confirm with the human first.

Once done, run [`review`](../review/review.md) over the work.

Commit your work to the current branch.
