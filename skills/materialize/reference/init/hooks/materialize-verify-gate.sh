#!/usr/bin/env bash
# materialize — PreToolUse verify gate (OPTIONAL, Claude Code).
#
# Deterministic floor for the Verify gate: blocks shipping a STANDARD/SPEC code
# change before a verify verdict exists. It checks only that a verdict file is
# present — it cannot prove the verifier was independent or that the verdict
# covers THIS issue; that stays the conductor's job. The floor it does enforce:
# you cannot open a PR / push a code change with zero verify artifact.
#
# Install via init: copy to .claude/hooks/, register under hooks.PreToolUse
# (matcher "Bash") in .claude/settings.json.
#
# Exit 0 = allow; exit 2 = block (stderr is shown to the model).
# Override a false positive with MATERIALIZE_SKIP_VERIFY_GATE=1.
set -euo pipefail

[[ "${MATERIALIZE_SKIP_VERIFY_GATE:-}" == "1" ]] && exit 0

payload="$(cat)"   # PreToolUse JSON on stdin
cmd="$(printf '%s' "$payload" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"

# Gate only the ship boundary.
printf '%s' "$cmd" | grep -Eq 'gh +pr +create|git +push' || exit 0

root="${CLAUDE_PROJECT_DIR:-$PWD}"
marker="$(ls -t "$root"/.workflow/*/marker.md 2>/dev/null | head -1 || true)"
[[ -z "$marker" ]] && exit 0                                   # not a materialize run
grep -Eqi '^workflow:.*(STANDARD|SPEC)' "$marker" || exit 0   # QUICK/FREEFORM: no gate

# Did the change touch code, not just docs/scratch?
# ponytail: base = main; if your default branch differs, that's the one knob to tune.
changed="$(git -C "$root" diff --name-only main...HEAD 2>/dev/null || true)"
printf '%s' "$changed" | grep -Evq '\.(md|mdx|txt)$|^\.workflow/|^docs/' || exit 0

# Require a recorded verify verdict.
# ponytail: matches ANY verify verdict under .workflow; for per-issue precision on a
# multi-issue run, scope the glob to the current issue id.
if ! ls "$root"/.workflow/*/*verify*.md >/dev/null 2>&1; then
  {
    echo "BLOCKED by materialize verify gate: STANDARD/SPEC code change with no recorded verify verdict."
    echo "Run the verify slot as a FRESH sub-agent (not the implementer); it writes .workflow/<id>/NN-verify-*.md and you set 'verified:' in $marker — then ship."
    echo "Override a false positive: MATERIALIZE_SKIP_VERIFY_GATE=1"
  } >&2
  exit 2
fi
exit 0
