#!/usr/bin/env bash
# ponytail: name-substring lint over the skill-index invariants in CLAUDE.md.
# Promoted buckets (engineering/productivity/misc) must appear in plugin.json + the top-level
# README + their bucket README; in-progress must not leak into plugin.json or the top-level README.
# Substring matches, not a JSON/markdown parser — tighten only if it throws a false positive.
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
miss() { echo "MISSING: $1"; fail=1; }
leak() { echo "LEAK:    $1"; fail=1; }

for bucket in engineering productivity misc; do
  for d in skills/"$bucket"/*/; do
    [ -f "${d}SKILL.md" ] || continue
    name=$(basename "$d")
    path="./skills/$bucket/$name"
    grep -q "\"$path\"" .claude-plugin/plugin.json    || miss "$path absent from .claude-plugin/plugin.json"
    grep -q "($path/SKILL.md)" README.md              || miss "$path/SKILL.md not linked in top-level README.md"
    grep -q "/$name/SKILL.md)" "skills/$bucket/README.md" || miss "$name not listed in skills/$bucket/README.md"
  done
done

for d in skills/in-progress/*/; do
  [ -f "${d}SKILL.md" ] || continue
  name=$(basename "$d")
  grep -q "\"./skills/in-progress/$name\"" .claude-plugin/plugin.json && leak "in-progress/$name in plugin.json"
  grep -q "(./skills/in-progress/$name/SKILL.md)" README.md           && leak "in-progress/$name linked in top-level README.md"
done

if [ "$fail" -eq 0 ]; then echo "skills index OK"; fi
exit "$fail"
