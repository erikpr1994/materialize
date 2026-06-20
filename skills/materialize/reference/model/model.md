# Domain Modeling

Actively build and sharpen the project's domain model as you design. This is the *active* discipline — challenging terms, inventing edge-case scenarios, and writing the glossary and decisions down the moment they crystallise. Merely reading `CONTEXT.md` for vocabulary is not this mode — `model` is for changing the model, not consuming it.

## File structure

Most repos have a single context:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Create files lazily — only when you have something to write. If no `CONTEXT.md` exists, create one when the first term is resolved. If no `docs/adr/` exists, create it when the first ADR is needed.

## Design awareness

If the work touches UI, the visual system has its own glossary: `DESIGN.md`. It is to design what `CONTEXT.md` is to the domain — the settled conventions (color, type, spacing, component inventory, layout patterns), not the reasoning behind them. Read it if present and challenge the plan against it the same way you do `CONTEXT.md`.

Create `DESIGN.md` lazily — only when the first visual convention is settled. If the repo already keeps a design-system doc, update that instead of inventing your own. Use the format in [DESIGN-FORMAT.md](../grilling/DESIGN-FORMAT.md). Keep it to settled conventions — the *why* behind a hard visual decision goes in an ADR, not here.

Root `DESIGN.md` is reserved for the design-system spec — never write architecture there. Per-feature technical/architecture design lives in `docs/<id>-tech-design.md` (committed, per-id), with diagrams as Mermaid in the doc per materialize's artifact convention.

## Roadmap awareness

When the work is one slice of a larger ambition, the plan above it lives in `ROADMAP.md`: the higher goal and the areas still ahead, each a future PRD. Read it if present and challenge the plan against it the way you do `CONTEXT.md`. As a broad scope narrows to the slice you're building, record the branches you're deferring there so they aren't lost — they seed the next PRDs.

When a grill reshapes the higher goal — a new area, a reprioritisation, a slice that's turned out wrong — revise `ROADMAP.md` inline, the same way you update a term whose meaning shifted. If the change moves the product or vision itself, push it up into the `PRODUCT.md`/`VISION.md` it defers to, not just the roadmap.

Create `ROADMAP.md` lazily — only when the scope is clearly bigger than one PRD. If the repo already keeps a product or vision doc (`PRODUCT.md`, `VISION.md`), update that instead of inventing your own. Use the format in [ROADMAP-FORMAT.md](./ROADMAP-FORMAT.md).

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Don't batch these up — capture them as they happen. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

`CONTEXT.md` should be totally devoid of implementation details. Do not treat `CONTEXT.md` as a spec, a scratch pad, or a repository for implementation decisions. It is a glossary and nothing else.

### Record resolved decisions inline

When a question resolves into an implementation-relevant answer — a constraint, negative requirement, edge case, numeric default, or ordering decision — append it to the feature's decision ledger right then, the same way you capture terms in `CONTEXT.md`. This is the durable record `prd` and `issues` check against, so the precise answer survives downstream instead of being softened into "persist sessions" or "support retry". Use the format in [DECISIONS-FORMAT.md](../grilling/DECISIONS-FORMAT.md).

The ledger is not the glossary, a design convention, or an ADR — it captures what the feature must *do*, verbatim. It is a deliverable: commit it.

### Completeness gate

`model` produces the tech-design, so it is a spec-producing phase. Mark every unresolved branch in `docs/<id>-tech-design.md` (or the ledger) with a literal `[NEEDS CLARIFICATION: …]` token, and don't exit `model` while any remain — resolve each by grilling the user.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).

New ADRs created during planning should usually be `proposed`, not `accepted` — promote them only after the implementing work lands. If you're recording a decision the current codebase already reflects, mark it `accepted`.
