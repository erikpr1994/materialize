# ROADMAP.md Format

`ROADMAP.md` is the durable high-level plan — the larger goal a grill is one slice of, and the areas still ahead. It is to scope what `CONTEXT.md` is to vocabulary: what's planned, not how. When a grill narrows a broad ambition down to one buildable slice, the branches you chose *not* to explore yet land here instead of dying with the throwaway `.grill-tree.md`, so each can seed a future PRD.

If the repo already keeps a product, vision, or roadmap doc (`PRODUCT.md`, `VISION.md`, a roadmap issue), follow its structure and update that instead. The shape below is a minimal fallback when none exists.

## Structure

```md
# {Project} Roadmap

{One or two sentences on the larger goal this roadmap serves.}

## Now

- **{Slice}** — {one line}. PRD: #123

## Next

- **{Slice}** — {one line on what it covers and why it isn't now}

## Later

- **{Slice}** — {one line}

## Done

- **{Slice}** — {one line}. PRD: #98
```

## Rules

- **Slices, not tasks.** Each entry is a chunk worth its own PRD, not a checklist item.
- **One line each.** The detail belongs in the slice's PRD when it's written, not here.
- **Move, don't delete.** A shipped slice moves to `Done` with its PRD link; a dropped one is removed. The roadmap stays a live picture of what's left.
- **No how.** Constraints, terms, and trade-offs live in the decision ledger, `CONTEXT.md`, and ADRs. The roadmap records *what's planned*, nothing more.
- **Group as it fills out.** Now/Next/Later/Done earn their headings once there's something under them — a short flat list is fine early on.
- **Lives on the trunk, not the slice.** The roadmap spans many PRDs, so it outlives any one feature branch. Keep it on the long-lived branch (`main`) — when a grill on a feature branch defers a branch into the roadmap, land that roadmap edit on the trunk in its own small commit/PR, not buried in the feature's diff. Then abandoning the branch never takes the roadmap with it, and parallel branches don't each carry a drifting copy.
