#!/usr/bin/env bash
# lint-skills.sh — layout invariants for the two conductors + skill registration.
#
# Checks:
#   a. Conductor sync: every Modes-table/prose reference link in each conductor's
#      SKILL.md resolves, and every reference/<mode>/ folder is mentioned in SKILL.md.
#   b. Every relative markdown link inside skills/**/*.md resolves to an existing path.
#   c. Registration: conductors + productivity skills appear in README.md and
#      .claude-plugin/plugin.json; in-progress leaks into neither.
#   d. Banned-synonym greps over skills/materialize/**/*.md.
#
# Plain bash + grep/sed/awk, substring matching — tighten only on a real false positive.
set -uo pipefail
cd "$(dirname "$0")/.."

# --- banned synonyms (check d) — extend these lists as terms get canonicalized ---
# Whole-word, case-insensitive ERE patterns. Canonical term for "ticket" is Issue.
BANNED_WORDS=("tickets?")
# Fixed-string, case-insensitive literals. Modes-table stage column header must be "Stage".
BANNED_LITERALS=("| Category |")

CONDUCTORS=("skills/materialize" "skills/articulate")
# reference/ dirs that are data folders linked as a folder, not modes — exempt from
# the per-mode mention check.
MENTION_EXEMPT=("skills/articulate/reference/platforms")

fail=0
err() { echo "FAIL: $1"; fail=1; }

# --- a. conductor Modes table / reference folder sync ---------------------------
for skill in "${CONDUCTORS[@]}"; do
  skill_md="$skill/SKILL.md"
  if [ ! -f "$skill_md" ]; then
    err "$skill_md missing"
    continue
  fi

  # Every reference/... link in SKILL.md (Modes table rows and base prose) must resolve.
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    [ -e "$skill/$ref" ] || err "$skill_md links $ref but $skill/$ref does not exist"
  done < <(grep -oE '\]\(reference/[^)#]+' "$skill_md" | sed 's/^](//' | sort -u)

  # Every reference/<mode>/ folder must be mentioned somewhere in SKILL.md.
  for d in "$skill"/reference/*/; do
    [ -d "$d" ] || continue
    mode_dir="${d%/}"
    exempt=0
    for ex in "${MENTION_EXEMPT[@]}"; do
      [ "$mode_dir" = "$ex" ] && exempt=1
    done
    [ "$exempt" -eq 1 ] && continue
    mode=$(basename "$mode_dir")
    grep -q "reference/$mode/" "$skill_md" || err "$mode_dir/ has no mention in $skill_md (orphan mode folder)"
  done
done

# --- b. relative markdown links resolve ------------------------------------------
# Fenced code blocks (```) are stripped via awk to avoid example-link false positives.
# Remaining known false-positive sources (none currently present): inline-code spans
# containing ](...), and link targets containing spaces or ')'.
while IFS= read -r -d '' md; do
  dir=$(dirname "$md")
  while IFS= read -r target; do
    [ -n "$target" ] || continue
    case "$target" in
      http://*|https://*|mailto:*|\#*|/*) continue ;;
    esac
    target="${target%%#*}"          # strip anchor
    [ -n "$target" ] || continue
    [ -e "$dir/$target" ] || err "$md links $target which does not exist"
  done < <(awk '/^[[:space:]]*```/{fence=!fence;next} !fence' "$md" \
             | grep -oE '\]\([^)]+\)' | sed 's/^](//; s/)$//')
done < <(find skills -name '*.md' -not -path '*/node_modules/*' -print0)

# --- c. registration ---------------------------------------------------------------
# Registered skills: the two conductors + everything under skills/productivity/*/.
registered=("skills/materialize" "skills/articulate")
for d in skills/productivity/*/; do
  [ -f "${d}SKILL.md" ] && registered+=("${d%/}")
done

for rel in "${registered[@]}"; do
  grep -q "\"./$rel\"" .claude-plugin/plugin.json || err "$rel absent from .claude-plugin/plugin.json"
  grep -q "$rel" README.md                        || err "$rel does not appear in top-level README.md"
done

# productivity bucket README must link each of its skills' SKILL.md.
for d in skills/productivity/*/; do
  [ -f "${d}SKILL.md" ] || continue
  name=$(basename "$d")
  grep -q "/$name/SKILL.md)" skills/productivity/README.md \
    || err "$name not linked in skills/productivity/README.md"
done

# in-progress must not leak into plugin.json or the top-level README.
for d in skills/in-progress/*/; do
  [ -d "$d" ] || continue
  name=$(basename "$d")
  grep -q "skills/in-progress/$name" .claude-plugin/plugin.json && err "in-progress/$name leaked into plugin.json"
  grep -q "skills/in-progress/$name" README.md                  && err "in-progress/$name leaked into top-level README.md"
done

# --- d. banned synonyms over skills/materialize/**/*.md ---------------------------
for pat in "${BANNED_WORDS[@]}"; do
  hits=$(grep -rniwE --include='*.md' "$pat" skills/materialize || true)
  if [ -n "$hits" ]; then
    echo "$hits" | sed 's/^/BANNED-WORD: /'
    err "banned word /$pat/ found in skills/materialize (canonical term: Issue)"
  fi
done
for lit in "${BANNED_LITERALS[@]}"; do
  hits=$(grep -rniF --include='*.md' "$lit" skills/materialize || true)
  if [ -n "$hits" ]; then
    echo "$hits" | sed 's/^/BANNED-LITERAL: /'
    err "banned literal '$lit' found in skills/materialize (table header must be Stage)"
  fi
done

if [ "$fail" -eq 0 ]; then echo "skills lint OK"; fi
exit "$fail"
