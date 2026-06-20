#!/usr/bin/env bash
# materialize — SessionStart setup-version check (OPTIONAL, Claude Code).
#
# Deterministic: compares this repo's docs/agents/.init-version against the
# skill's shipped .skill-version. On a missing or differing marker it injects a
# one-line note (via SessionStart additionalContext) telling the model to run
# the init mode. No judgment — just a number compare.
#
# Install via init: copy to .claude/hooks/, register under hooks.SessionStart in
# .claude/settings.json, and set SKILL_VERSION_FILE to the installed skill's
# .skill-version path.
set -euo pipefail
cat >/dev/null   # drain the SessionStart payload; we only need two files

root="${CLAUDE_PROJECT_DIR:-$PWD}"
have="$(cat "$root/docs/agents/.init-version" 2>/dev/null || true)"
want="$(cat "${SKILL_VERSION_FILE:-$root/.skill-version}" 2>/dev/null || true)"

# Up to date (and both known) → say nothing.
[[ -n "$have" && "$have" == "$want" ]] && exit 0

if [[ -z "$have" ]]; then
  note="materialize is not set up here (no docs/agents/.init-version) — run the init mode before materialize work."
else
  note="materialize setup is stale (.init-version=$have, skill=${want:-unknown}) — re-run the init mode to reconcile."
fi
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "${note//\"/\\\"}"
