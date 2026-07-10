# Resume

Safely resume work from a handoff document — check drift, re-probe unverified claims, and read the source of truth before acting. Use this step when picking up a handoff written via `handoff.md`, found under `.workflow/<id>/`.

A handoff is a starting hypothesis, not gospel — re-anchor on it rather than on summarized history. Before acting on it:

1. **Check drift** — compare the handoff's anchor SHA to current `HEAD` (`git log --oneline <anchor>..HEAD`); re-run `gh pr list` / `git worktree list`. "Remaining" work may have merged or be in flight since it was written.
2. **Re-probe every `[UNVERIFIED]` claim** before building on it — especially any "not built / missing / dead": grep the codebase first, so you don't rebuild what exists or delete what's live.
3. **Read the named source of truth** before re-deriving anything.
4. Run the handoff's **re-grounding commands** to confirm the verified state still holds.
5. **Delete the handoff once you've re-grounded from it.** It's spent — its state now lives in this session. Leaving it under `.workflow/<id>/`, where `handoff.md` writes handoffs to be discovered, lets a later session pick up superseded ground truth (and they pile up); a fresh handoff written to continue the work supersedes it either way.

Read the tags the way `handoff.md` writes them: `[verified: <probe>]` is checked-but-possibly-stale — re-grounding may still be worth it; anything bare or `[UNVERIFIED: <source>]` is unchecked — probe it before you act on it.
