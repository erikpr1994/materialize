# Implement

`implement` is the single-Issue/PRD **executor**: it works ONE unit sequentially, slice by slice. (The multi-Issue driver is [`work`](../work/work.md), which dispatches one `implement` per Issue — don't re-do its orchestration here.)

Implement the work described by the user in the PRD or issues.

**Before coding (STANDARD/SPEC):** the leverage checkpoint gate (conductor base) must be clear — no go, no code. Also clear the **Principles check**: verify the plan against `docs/agents/principles.md` (written by `init`); if a principle is intentionally violated, record an explicit justification line in the marker and the PR.

When coding starts, move the issue to its **In Progress** state via the `tracker` slot — unless `docs/agents/execution-states.md` marks that transition automated (then the tracker moves it; don't double-drive).

If the PRD has been broken into issue slices, work through the slices in order — each is an implementable unit. Don't implement from the PRD alone.

At each pre-agreed test seam, drive the work through [`tdd`](../tdd/tdd.md): load it and follow its red→green→refactor loop one test at a time. Don't write tests ad-hoc alongside the implementation — that skips the loop, which is the whole point of the seam.

Run typechecking and single test files regularly; run the full suite once at the end.

Hitting the irreversible / high-blast-radius gate, stop and confirm with the human first.

Once done, on QUICK/STANDARD run [`review`](../review/review.md) over the work yourself. On SPEC, stop at the diff — [`review`](../review/review.md) is a separate pipeline phase the conductor runs independently of you.

That self-review is a **bounded pass, not an open loop**: review once, fix what surfaces, then re-review once to confirm the fixes hold and introduced nothing new. If that confirmation pass still turns up substantive findings, stop and hand the outstanding list to the human — legitimate findings every round is a signal to escalate the call, not a licence to keep cycling autonomously.

Commit your work to the current branch.

On QUICK/STANDARD you're the terminal actor, so **close out** the source issue if the work came from a tracker item: move it to its **Done** state via the `tracker` slot and append a completion note — what shipped, the commit, the verification that passed, and anything left unverified — unless `docs/agents/execution-states.md` marks that transition automated (then the tracker closes it; don't double-drive) or the tracker conventions are unknown (report the issue wasn't updated rather than guess). On SPEC or under `work` you stop at the diff — leave the state alone; the `pr` phase moves the issue to In Review and its merge advances it to Done.
