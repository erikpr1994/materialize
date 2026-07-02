#!/usr/bin/env bash
# materialize — PreToolUse pipeline gate (OPTIONAL, Claude Code).
#
# Deterministic floor for the Pipeline gate: blocks shipping a STANDARD/SPEC
# code change unless every phase the workflow type prescribes is accounted for
# in the marker (done or logged skipped) and verify left a verdict file. It
# enforces that phases were DECLARED and that verify produced an artifact — it
# cannot judge whether a phase was done WELL, nor that verify was independent;
# that stays the conductor's job. (accept has no clean per-PR boundary; it is
# gated by the prose rule, not here.)
#
# Install via init: copy to .claude/hooks/, register under hooks.PreToolUse
# (matcher "Bash") in .claude/settings.json.
#
# Exit 0 = allow; exit 2 = block (stderr is shown to the model).
# Override a false positive with MATERIALIZE_SKIP_GATE=1.
set -euo pipefail

[[ "${MATERIALIZE_SKIP_GATE:-}" == "1" ]] && exit 0

payload="$(cat)"   # PreToolUse JSON on stdin
cmd="$(printf '%s' "$payload" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"

# Gate only the ship boundary.
printf '%s' "$cmd" | grep -Eq 'gh +pr +create|git +push' || exit 0

root="${CLAUDE_PROJECT_DIR:-$PWD}"

# Select THIS work item's marker: prefer a worktree- or branch-matched id (so concurrent work
# doesn't gate against a sibling's marker); fall back to the newest-modified marker.
issue_id=""
case "$PWD" in
  *"/.worktrees/"*)         issue_id="${PWD##*/.worktrees/}";         issue_id="${issue_id%%/*}" ;;
  *"/.claude/worktrees/"*)  issue_id="${PWD##*/.claude/worktrees/}"; issue_id="${issue_id%%/*}" ;;
esac
if [[ -z "$issue_id" ]]; then
  branch="$(git -C "$root" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [[ -n "$branch" ]]; then
    if [[ -d "$root/.workflow/$branch" ]]; then
      issue_id="$branch"
    else
      for d in "$root"/.workflow/*/; do
        [[ -d "$d" ]] || continue
        name="$(basename "$d")"
        case "$branch" in *"$name"*) issue_id="$name"; break ;; esac
      done
    fi
  fi
fi
if [[ -n "$issue_id" && -f "$root/.workflow/$issue_id/marker.md" ]]; then
  marker="$root/.workflow/$issue_id/marker.md"
else
  marker="$(ls -t "$root"/.workflow/*/marker.md 2>/dev/null | head -1 || true)"
fi
[[ -z "$marker" ]] && exit 0                                   # not a materialize run
mdir="$(dirname "$marker")"

# Phases the workflow type prescribes (the pipeline contract).
wf="$(grep -Ei '^workflow:' "$marker" | head -1 || true)"
case "$wf" in
  *STANDARD*) wftype=STANDARD; required="research prototype design prepare implement verify" ;;
  *SPEC*)     wftype=SPEC;     required="prepare implement verify review" ;;     # per-issue only; upfront research/prototype/design + accept are conductor/leverage-checkpoint-enforced (this PR may see a per-issue executor marker, so an upfront phase here would false-block)
  *)          exit 0 ;;                                         # QUICK/FREEFORM: no gate
esac

# Docs-only change? skip. Derive the default branch (master/develop repos don't fail open on a
# hardcoded main); fall back to main when origin/HEAD isn't set.
base="$(git -C "$root" symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's#^refs/remotes/origin/##' || true)"
[[ -z "$base" ]] && base=main
changed="$(git -C "$root" diff --name-only "$base...HEAD" 2>/dev/null || true)"
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

if [[ -n "$missing" ]]; then
  {
    echo "BLOCKED by materialize pipeline gate: $wftype change is missing prescribed phase(s):$missing"
    echo "Account for each in $marker (run it, or log 'skipped: <reason>'); verify must run as a FRESH sub-agent and leave .workflow/<id>/NN-verify-*.md."
    echo "Override a false positive: MATERIALIZE_SKIP_GATE=1"
  } >&2
  exit 2
fi
exit 0
