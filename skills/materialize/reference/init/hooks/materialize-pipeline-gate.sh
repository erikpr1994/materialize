#!/usr/bin/env bash
# materialize — PreToolUse pipeline gate (OPTIONAL, Claude Code).
#
# Deterministic floor for the Pipeline gate: blocks shipping a STANDARD/SPEC
# code change unless every phase the workflow type prescribes is accounted for
# in the marker (done or logged skipped), verify left a verdict file, and the
# marker's docs: living-docs row is resolved (synced / nothing-to-sync). It
# enforces that phases were DECLARED and that verify produced an artifact — it
# cannot judge whether a phase was done WELL, nor that verify was independent;
# that stays the conductor's job. (accept has no clean per-PR boundary; it is
# gated by the prose rule, not here.)
#
# Install via init: copy to .claude/hooks/, register under hooks.PreToolUse
# (matcher "Bash") in .claude/settings.json.
#
# Exit 0 = allow; exit 2 = block (stderr is shown to the model).
# Override a false positive by prefixing the command with MATERIALIZE_SKIP_GATE=1.
set -euo pipefail

[[ "${MATERIALIZE_SKIP_GATE:-}" == "1" ]] && exit 0

payload="$(cat)"   # PreToolUse JSON on stdin
cmd="$(printf '%s' "$payload" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"

# The hook runs BEFORE the command, so an env prefix in the command string never
# reaches this process's env — honor the override from the string itself.
printf '%s' "$cmd" | grep -q 'MATERIALIZE_SKIP_GATE=1' && exit 0

# Gate only the ship boundary (allow global flags like -C <path> between git and push).
printf '%s' "$cmd" | grep -Eq 'gh +pr +create|git +((-C|--git-dir|--work-tree) +[^ ]+ +)*push' || exit 0

root="${CLAUDE_PROJECT_DIR:-$PWD}"

# The tree the push runs from: an explicit `git -C <path>` in the command, else the
# payload's cwd — the hook's own PWD is the main checkout even when the command runs
# in a worktree.
src="$(printf '%s' "$cmd" | sed -nE "s/.*git +-C +['\"]?([^ '\"]+).*/\1/p" | head -1 || true)"
[[ -n "$src" && -d "$src" ]] || src="$(printf '%s' "$payload" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null || true)"
[[ -n "$src" && -d "$src" ]] || src="$PWD"

# Candidate ids for THIS work item: the agent-worktree dir name, then the branch of the
# pushed tree. Matched case-insensitively against .workflow/ marker dirs — tracker branch
# names are lowercase while marker dirs keep the ticket id's case.
cands=""
case "$src" in
  *"/.worktrees/"*)         c="${src##*/.worktrees/}";         cands="${c%%/*}" ;;
  *"/.claude/worktrees/"*)  c="${src##*/.claude/worktrees/}";  cands="${c%%/*}" ;;
esac
branch="$(git -C "$src" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
[[ -n "$branch" ]] && cands="$cands $branch"

issue_id=""
for cand in $cands; do
  lcand="$(printf '%s' "$cand" | tr '[:upper:]' '[:lower:]')"
  for d in "$root"/.workflow/*/; do
    [[ -f "$d/marker.md" ]] || continue
    name="$(basename "$d")"
    lname="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')"
    case "$lcand" in *"$lname"*) issue_id="$name"; break 2 ;; esac
  done
done

# No matching marker → this push is not a tracked materialize work item; allow rather
# than gate it against a sibling session's marker.
[[ -n "$issue_id" ]] || exit 0
marker="$root/.workflow/$issue_id/marker.md"
mdir="$(dirname "$marker")"

# Phases the workflow type prescribes (the pipeline contract).
wf="$(grep -Ei '^workflow:' "$marker" | head -1 || true)"
case "$wf" in
  *STANDARD*) wftype=STANDARD; required="research grill prototype design prepare implement verify" ;;
  *SPEC*)     wftype=SPEC;     required="prepare implement verify review" ;;     # per-issue only; upfront wayfinder/research/prototype/design + accept are conductor/leverage-checkpoint-enforced (this PR may see a per-issue executor marker, so an upfront phase here would false-block)
  *)          exit 0 ;;                                         # QUICK/FREEFORM: no gate
esac

# Docs-only change? skip. Diff the pushed tree, not the main checkout. Derive the default
# branch (master/develop repos don't fail open on a hardcoded main); fall back to main
# when origin/HEAD isn't set.
base="$(git -C "$src" symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's#^refs/remotes/origin/##' || true)"
[[ -z "$base" ]] && base=main
changed="$(git -C "$src" diff --name-only "$base...HEAD" 2>/dev/null || true)"
printf '%s' "$changed" | grep -Evq '\.(md|mdx|txt)$|^\.workflow/|^docs/' || exit 0

# Every prescribed phase must be accounted for in the marker (done or skipped);
# verify additionally must have left a verdict file, not just a ledger mention.
# A word-match in the marker is a floor — it proves the phase was declared, not that it ran well.
missing=""
for ph in $required; do
  if [[ "$ph" == "verify" ]]; then
    ls "$mdir"/*verify*.md >/dev/null 2>&1 || missing="$missing verify(no-verdict-file)"
  else
    grep -qiw "$ph" "$marker" || missing="$missing $ph"
  fi
done

# Living-docs sync: the docs: row must be resolved — synced (with paths) or
# nothing-to-sync: <reason> — before shipping. Absent or pending blocks.
docs_row="$(grep -Ei '^docs:' "$marker" | head -1 || true)"
printf '%s' "$docs_row" | grep -Eqi 'synced|nothing-to-sync' || missing="$missing docs(living-docs-row-unresolved)"

if [[ -n "$missing" ]]; then
  {
    echo "BLOCKED by materialize pipeline gate: $wftype change is missing prescribed phase(s):$missing"
    echo "Account for each in $marker (run it, or log 'skipped: <reason>'); verify must run as a FRESH sub-agent and leave .workflow/<id>/NN-verify-*.md."
    echo "docs: must read 'synced (paths)' or 'nothing-to-sync: <reason>' — route settled terms/conventions/decisions into CONTEXT.md / DESIGN.md / ADRs / docs/decisions/ first."
    echo "Override a false positive by prefixing the command with MATERIALIZE_SKIP_GATE=1"
  } >&2
  exit 2
fi
exit 0
