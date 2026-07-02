#!/usr/bin/env bash
# materialize — SessionStart setup-version check (OPTIONAL, Claude Code).
#
# Deterministic: compares this repo's docs/agents/.init-version against the
# skill's shipped .skill-version. On a missing or differing marker it injects a
# one-line note (via SessionStart additionalContext) telling the model to run
# the init mode. No judgment — just a number compare.
#
# Install via init: copy to .claude/hooks/, register under hooks.SessionStart in
# .claude/settings.json. The skill's .skill-version is resolved from the standard
# install locations (or MATERIALIZE_SKILL_ROOT); set SKILL_VERSION_FILE only to
# override. Stays silent when the shipped version can't be found.
set -euo pipefail
cat >/dev/null   # drain the SessionStart payload; we only need two files

root="${CLAUDE_PROJECT_DIR:-$PWD}"
have="$(cat "$root/docs/agents/.init-version" 2>/dev/null || true)"

# Resolve the shipped skill's .skill-version: SKILL_VERSION_FILE, then MATERIALIZE_SKILL_ROOT's parent
# (that env var points at the reference dir), then the standard install locations.
want=""
for vf in "${SKILL_VERSION_FILE:-}" \
          "${MATERIALIZE_SKILL_ROOT:+$MATERIALIZE_SKILL_ROOT/../.skill-version}" \
          "$root/.claude/skills/materialize/.skill-version" \
          "$root/skills/materialize/.skill-version"; do
  [[ -n "$vf" && -f "$vf" ]] || continue
  want="$(cat "$vf" 2>/dev/null || true)"
  [[ -n "$want" ]] && break
done

# Can't find the shipped skill version → nothing to compare against; stay silent (no false nag).
[[ -z "$want" ]] && exit 0

# Up to date → say nothing.
[[ "$have" == "$want" ]] && exit 0

if [[ -z "$have" ]]; then
  note="materialize is not set up here (no docs/agents/.init-version) — run the init mode before materialize work."
else
  note="materialize setup is stale (.init-version=$have, skill=$want) — re-run the init mode to reconcile."
fi
esc="$(printf '%s' "$note" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$esc"
