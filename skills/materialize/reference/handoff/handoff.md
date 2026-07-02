Compact the current conversation into a handoff document for another agent to pick up. To resume from a handoff, see the resume step (`resume.md`).

A handoff is a contract between two sessions. The next session treats it as ground truth and acts on it **without re-checking** — so one unverified claim ("X is done", "feature Y isn't built", "table Z is dead") becomes wrong work it can't trace back. Confident phrasing is not verification.

## 1. Capture state by running commands, not from memory

Before writing prose, capture real state by probing, not recalling. If the work lives in a git repo, run these and paste the output — this is the anchor the reader checks for drift, plus the in-flight state that's easy to forget. Otherwise capture the equivalent (what's deployed, what's running, what's open) the same way:

```sh
echo "anchor: $(git branch --show-current) @ $(git rev-parse --short HEAD) · $(date -u +%FT%TZ)"
git status --short            # uncommitted work the next session must not clobber
git worktree list             # work possibly in flight in another tree
gh pr list --state open       # PRs that may already contain the "remaining" work
```

## 2. Tag every load-bearing claim

A load-bearing claim asserts something is **done / not done / exists / missing / passing / broken** — anything the next session would act on. Tag each one:

- `[verified: <probe>]` — checked this session, with the probe: `[verified: grep — route exists in router]`, `[verified: SELECT count=0]`, `[verified: tests 52/52]`.
- `[UNVERIFIED: <source>]` — carried from memory, a prior handoff, an issue, or a code comment/label and not re-checked. A label is a claim to falsify, not a fact to forward — repeating it doesn't make it true.

No probe? Either run the one-liner now and mark it `[verified: …]`, or mark it `[UNVERIFIED]`. Never write a done/not-built/dead claim as a bare fact.

## 3. Record reasoning, not just conclusions

- **Dead ends** — what you tried and rejected, so the next session doesn't repeat it.
- **Riskiest assumptions** — the claims most likely to be wrong, flagged so the reader attacks those first.
- **Source of truth** — name the canonical artifact (PRD / design doc / issue) and say "read it first, don't re-derive."
- **Next steps, each risk-tagged**: `[safe]` · `[irreversible — confirm first]` · `[blocked on <x>]`.

Keep a "Verified state" section visibly separate from "Assumptions / next steps" so the reader can tell checked from conjecture at a glance. Include a short **re-grounding commands** block: the probes the reader can re-run to confirm the verified state still holds (state drifts between write and read).

## 4. Logistics

- A handoff is discardable scratch, not the lasting record — keep it out of `docs/` and out of the workspace per the **Durability** discipline; save under `.workflow/<id>/` (gitignored, discoverable on resume).
- Include a "Suggested skills" section.
- Don't duplicate other artifacts (PRDs, plans, ADRs, issues, commits, diffs) — reference by path/URL.
- Redact secrets and PII. If the user passed arguments, tailor the doc to that focus.

Before saving, re-read every load-bearing claim: `[verified: probe]` or `[UNVERIFIED]` — never bare.
