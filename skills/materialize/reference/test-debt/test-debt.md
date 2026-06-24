# Prune Test Debt

Surface low-value tests in an existing suite and propose **prunings** — deletes, merges, and rewrites that refocus the suite on observable behavior. The aim is confidence per test and a suite that survives refactors.

Built on shared vocabulary:

- Run the `design` mode for **seam** and "the interface is the test surface"; run `tdd` for the behavior-not-implementation discipline. A good test exercises a behavior through the highest useful seam. A bad one couples to implementation, asserts what can't fail, or verifies its own mocks.
- Accepted ADRs in `docs/adr/` may record a deliberate testing decision — don't re-litigate it; a test that honors it is not debt.

## Process

### 1. Explore

Use the Agent tool with `subagent_type=Explore` to walk the test suite. Don't follow rigid heuristics — read organically and note where a test earns no confidence:

- Asserts **implementation details** rather than observable behavior — breaks on refactors that change nothing a caller sees.
- Assertions that **can't realistically fail** — tautologies, or asserting a mock returns what you told it to.
- **Mock-heavy** tests that mostly verify the mocks, not the code under test.
- **Overly defensive** patterns (broad catch-all, swallowed errors) that hide real failures.
- **Redundant** paths — a second test that can't fail unless the first already did, adding no confidence.
- **Coverage theater** — tests that exist for a number, exercising trivial wiring no one would break.
- Tests pinned to a **seam lower than necessary** — lifting them to the highest useful seam (per `tdd`/`design`) covers more with fewer tests.

Apply the **confidence test** to anything you suspect is low-value: if this test were deleted, what real regression would now slip through? "None" is the signal to prune.

### 2. Present candidates as an HTML report

Same report mechanism as the `architecture` mode — see [HTML-REPORT.md](../architecture/HTML-REPORT.md) for the scaffold, temp-dir handling, and styling. For each candidate, render a card with:

- **Tests** — which test files/cases are involved
- **Problem** — why the test earns no confidence (cite the smell above)
- **Action** — `delete`, `merge`, `rewrite to behavior`, or `lift to higher seam`
- **Benefit** — in terms of confidence, suite speed, and decoupling from implementation
- **Evidence** — the `file:line` that shows the friction, so the claim is checkable
- **Effort / Risk / Confidence** — `S`/`M`/`L`; risk the prune drops real coverage; `HIGH`/`MED`/`LOW`
- **Recommendation strength** — `Strong`, `Worth exploring`, or `Speculative`, as a badge

Order by **leverage** = confidence reclaimed ÷ effort, discounted by the risk of dropping real coverage.

**Net-coverage rule.** A delete or merge must not silently drop a behavior currently covered only by the test you're cutting. For each one, name the behavior and confirm it's covered elsewhere — or that it's genuinely not worth covering.

**"Keep it" is a valid verdict.** When the confidence test says a suspected test is actually pulling weight, record one line with the reason so the next sweep doesn't re-surface it.

End with a **Top recommendation**: which prune you'd do first and why. Do NOT change tests yet. Ask: "Which of these would you like to apply?"

### 3. Apply loop

Once the user picks, apply the prunes. For a **rewrite**, drive the replacement through [`tdd`](../tdd/tdd.md) so it's behavior-first, not a patched version of the old test. Run the full suite before and after to confirm it stays green and that intended-behavior coverage holds.

This mode prunes the **existing** suite; net-new coverage at a seam belongs in [`tdd`](../tdd/tdd.md), and friction in the code *under* the tests belongs in [`architecture`](../architecture/architecture.md).
