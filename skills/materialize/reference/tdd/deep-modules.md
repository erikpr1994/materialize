# Deep modules

A module is **deep** when a simple interface hides a powerful implementation — maximum behaviour per unit of interface a caller must learn (see [`design`](../design/design.md) for the full glossary). Prefer deep modules: they are the ones worth testing and the ones tests stay stable against.

## Deep vs shallow

- **Deep** — Unix file I/O (`open`/`read`/`write`/`close`/`lseek`) hides buffering, scheduling, permissions, device drivers. Tiny interface, enormous capability.
- **Shallow** — a unit whose interface is as complex as its body: pass-through methods, getters/setters mirroring fields, a wrapper that only forwards. Cost (interface to learn) ≥ benefit (complexity hidden). An anti-pattern even when "cleanly factored."

## How to deepen

- **Hide information.** Keep design decisions (data formats, algorithms, dependencies) inside; don't leak them into the signature.
- **Kill pass-throughs.** If a method only forwards to another with the same signature, the layer earns nothing — collapse it.
- **Generalize the interface.** Make it serve several callers; special-case logic belongs inside, not pushed onto every caller.
- **Pull complexity downward.** The author pays it once so no caller has to.

## Why TDD cares

- A small, stable interface is a small, stable **test surface**: tests target the contract, not the internals, so refactoring the implementation doesn't break them.
- Shallow modules force tests to know internals (or fan out across a wide interface) — brittle and noisy.
- When a unit is painful to test, suspect a shallow module or a leaked dependency before reaching for mocks — see [interface design](interface-design.md).

*Reference: John Ousterhout, A Philosophy of Software Design.*
