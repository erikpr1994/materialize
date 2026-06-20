#!/bin/bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# Git's global options sit *between* `git` and the subcommand
# (e.g. `git -C /repo push`, `git -c user.name=x reset --hard`,
# `git --no-pager clean -fd`). Left in place they break the adjacency the
# patterns below rely on, silently bypassing the guard. Normalize first:
# collapse whitespace, then strip those global options (and any value argument
# they carry) until stable, so `git -C /r push` reduces to `git push`.
NORMALIZED=$(echo "$COMMAND" | tr -s '[:space:]' ' ')
while :; do
  PREV="$NORMALIZED"
  # global options that consume a following argument
  NORMALIZED=$(echo "$NORMALIZED" | sed -E 's/ (-C|-c|--git-dir|--work-tree|--namespace|--super-prefix|--exec-path|--config-env|--attr-source) +[^ ]+//g')
  # the same options written as --opt=value
  NORMALIZED=$(echo "$NORMALIZED" | sed -E 's/ (--git-dir|--work-tree|--namespace|--super-prefix|--exec-path|--config-env|--attr-source)=[^ ]+//g')
  # value-less global flags
  NORMALIZED=$(echo "$NORMALIZED" | sed -E 's/ (-p|-P|--paginate|--no-pager|--bare|--no-replace-objects|--literal-pathspecs|--glob-pathspecs|--noglob-pathspecs|--icase-pathspecs|--no-optional-locks|--html-path|--man-path|--info-path)( |$)/ /g')
  [ "$NORMALIZED" = "$PREV" ] && break
done

DANGEROUS_PATTERNS=(
  "git push"
  "git reset --hard"
  "git clean -fd"
  "git clean -f"
  "git branch -D"
  "git checkout \."
  "git restore \."
  "push --force"
  "reset --hard"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$NORMALIZED" | grep -qE "$pattern"; then
    echo "BLOCKED: '$COMMAND' matches dangerous pattern '$pattern'. The user has prevented you from doing this." >&2
    exit 2
  fi
done

exit 0
