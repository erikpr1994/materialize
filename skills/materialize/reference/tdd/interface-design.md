# Designing interfaces for testability

Test through the **public interface**, not the internals. A unit that's hard to test is usually telling you the interface — or a hidden dependency — is wrong. Fix the design before reaching for mocks.

## Functional core, imperative shell

- Put logic in pure functions (input → output; no I/O, no clock, no globals): trivial to test, zero setup.
- Push side effects (network, disk, time, randomness) into a thin shell around that core.
- Test the core directly and hard; keep the shell thin enough to need little testing.

## Inject hidden dependencies

- Global state, `now()`, random, env, the network, the filesystem are **hidden inputs**. Pass them in (parameter, constructor, port) so a test can supply a fake.
- A clean **seam** — a boundary where a collaborator can be substituted without touching the unit — is what lets a fake stand in without mock-everything churn. See [mocking](mocking.md) for when a fake is warranted.

## Keep interfaces narrow and honest

- Intention-revealing names; command–query separation (a method either does or asks, not both).
- A narrow interface over a [deep implementation](deep-modules.md) is inherently testable: few entry points, a stable contract.
- If a test must reach *past* the interface to set up or assert, the interface is leaking — narrow it or move the seam.

## Smell → fix

- "I need to mock five things" → too many dependencies or the wrong seam; extract a pure core.
- "The test breaks on every refactor" → it's testing internals; test the contract.
- "I can't trigger this branch" → a hidden input (time/random/env); inject it.
