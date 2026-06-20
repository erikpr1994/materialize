Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.

If a question can be answered by exploring the codebase, explore the codebase instead — prefer a subagent so the exploration doesn't clutter this conversation.

## Track the design tree

Keep a running outline of the branches so a long session doesn't lose its place when context compacts. Maintain a throwaway `.grill-tree.md` at the repo root: one line per branch with its status — resolved (✓) or pending — updated as you settle old branches and discover new ones. It doubles as the progress signal: when the user wonders how far along they are, the outline answers without a fake "question N of M".

`.grill-tree.md` is scratch state, not a deliverable. Add it to `.gitignore`, and delete it when grilling concludes — by then every settled decision already lives in `CONTEXT.md`, `DESIGN.md`, or an ADR, and any high-level branch you deferred rather than resolved has moved to `ROADMAP.md` to seed a future PRD.

A branch stays **pending** until the user explicitly resolves it. Never auto-mark a branch ✓ off your own recommendation or because the user moved on — only the user moves a question to resolved.

## Prototype UI decisions, don't describe them

When a question is spatial — layout, control placement, flow, visual hierarchy, modal-vs-page — text is a poor medium. Generate a minimal throwaway HTML mockup with 2+ variants side by side and let the user react. Delegate the file to a sub-agent so the grilling thread stays focused, then resume with one question: "which variant?" For a richer interactive comparison, hand off to [`prototype`](../prototype/prototype.md).

Capture the choice before deleting the mockup: the **settled convention** goes in `DESIGN.md` ("primary actions live in a sticky bottom bar"), like any resolved term; if the choice was a real trade-off worth an ADR, record the *why* there — and paste a screenshot or the variant markup into it first, so the rejected options survive the mockup's deletion. Then delete the mockup.

## Write decisions down as they settle

Route each resolved decision through [`model`](../model/model.md) as it lands, so the glossary, decision ledger, and ADRs are written live rather than reconstructed afterward.

Grilling a bare idea with no project to write into? Skip the repo deliverables — `CONTEXT.md`, `DESIGN.md`, ADRs, `ROADMAP.md` — and surface conclusions inline, but still keep the `.grill-tree.md` outline so the session survives context compaction.
