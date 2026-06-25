#!/usr/bin/env python3
# materialize-conductor-lock.sh — PreToolUse lock: the main conductor session may not write source files; only sub-agents may.
# Blocks Write/Edit outright, and Bash commands that write into the repo source tree — closing the heredoc/tee/redirect/sed hole
# (a conductor could otherwise sidestep the Write/Edit block with `cat >file`, `tee`, `sed -i`, …). Writes to the conductor's
# OWN state (.workflow/, agent worktrees) and to paths outside the repo (memory, /tmp, scratch) stay allowed — those are
# conductor bookkeeping, not source. Best-effort string inspection: a guardrail, not a sandbox. Override a false positive with
# MATERIALIZE_SKIP_LOCK=1. Install via init under hooks.PreToolUse with matcher "Write|Edit|Bash".
import os
import re
import sys
import json

try:
    payload = json.load(sys.stdin)
except Exception:
    sys.exit(0)

if os.environ.get("MATERIALIZE_SKIP_LOCK") == "1":
    sys.exit(0)

root = os.path.abspath(os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd()))
base = payload.get("cwd") or root


def in_worktree(p):
    # True if p is inside an agent worktree (.claude/worktrees/agent-* or legacy .worktrees/).
    if not p:
        return False
    parts = os.path.normpath(p).split(os.sep)
    if ".worktrees" in parts:
        return True
    return any(parts[i] == ".claude" and parts[i + 1] == "worktrees" for i in range(len(parts) - 1))


def is_subagent():
    # Primary signal: payload carries a non-empty agent_id only in a sub-agent context.
    if payload.get("agent_id"):
        return True
    # Fallback: the edit target or session cwd lives inside a worktree (root points at the MAIN repo even for worktree sub-agents).
    tool_input = payload.get("tool_input") or {}
    file_path = tool_input.get("file_path") or tool_input.get("filePath") or ""
    if in_worktree(file_path) or in_worktree(payload.get("cwd", "")) or in_worktree(root):
        return True
    # Last resort: an ancestor process carries '--agent' (out-of-process sub-agents).
    import subprocess
    pid = os.getpid()
    while pid > 1:
        try:
            output = subprocess.check_output(
                ["ps", "-o", "ppid=,args=", "-p", str(pid)],
                stderr=subprocess.DEVNULL
            ).decode().strip()
            if not output:
                break
            ppid_str, args = output.split(None, 1)
            if "--agent" in args.lower():
                return True
            pid = int(ppid_str)
        except Exception:
            break
    return False


def writes_source(p):
    # A write is blocked only when it lands INSIDE the repo source tree but outside the conductor's
    # own state dirs (.workflow/, agent worktrees). Writes outside the repo — memory, /tmp, scratch,
    # home config — are conductor bookkeeping, not source, and stay allowed.
    if not p:
        return False
    target = os.path.abspath(os.path.join(base, os.path.expanduser(p)))
    try:
        inside_repo = os.path.commonpath([target, root]) == root
    except ValueError:
        inside_repo = False
    if not inside_repo:
        return False
    parts = target.split(os.sep)
    if in_worktree(target) or ".workflow" in parts:
        return False
    return True


_SAFE_SINK = {"/dev/null", "/dev/stdout", "/dev/stderr", "/dev/tty"}


def write_targets(command):
    # Best-effort extraction of files a shell command would write — a guardrail, not a sandbox.
    # Covers the common write idioms a conductor could reach for: redirection, tee, dd, sed/perl -i, cp/mv/install/rsync.
    targets = []
    for seg in re.split(r'\|\||&&|[;|\n&]', command):
        # Blank quoted spans first so prose with a literal > / "tee" (e.g. a `gh pr --body` string) isn't read as a
        # redirect. Cost: a deliberately *quoted* write target slips through — that's the obfuscation the override covers.
        seg = re.sub(r'"[^"]*"|\'[^\']*\'', ' ', seg)
        # output redirection: > file / >> file (skip >&fd dups and the /dev sinks)
        for m in re.finditer(r'(?<![0-9&])>>?\s*([^\s<>()]+)', seg):
            t = m.group(1).strip('"\'')
            if t.startswith('&') or t in _SAFE_SINK:
                continue
            targets.append(t)
        # tee [-flags] file...
        m = re.search(r'\btee\b((?:\s+-\S+)*)((?:\s+[^\s<>()|;]+)+)', seg)
        if m:
            targets += [t.strip('"\'') for t in m.group(2).split()]
        # dd of=file
        for m in re.finditer(r'\bof=([^\s]+)', seg):
            targets.append(m.group(1).strip('"\''))
        # in-place stream edit: sed -i / perl -i,-pi — flag path-like trailing args (else a sentinel that always blocks)
        if re.search(r'\b(sed|perl)\b.*\s-(?:i|pi)\b', seg):
            tail = [t for t in seg.split() if '/' in t or '.' in t.rsplit('/', 1)[-1]]
            targets += [t.strip('"\'') for t in tail] or ['<in-place edit>']
        # cp / mv / install / rsync — destination is the last non-flag token of the segment
        m = re.search(r'\b(cp|mv|install|rsync)\b\s+(.+)', seg)
        if m:
            toks = [t for t in m.group(2).split() if not t.startswith('-')]
            if toks:
                targets.append(toks[-1].strip('"\''))
    return targets


name = payload.get("tool_name", "")

if name in ["Write", "Edit"] and not is_subagent():
    sys.stderr.write("BLOCKED by materialize conductor lock: The main session is a pure conductor.\n")
    sys.stderr.write("You are not allowed to edit or write files directly in this session. You must delegate all implementation and phase tasks to sub-agents.\n")
    sys.exit(2)

if name == "Bash" and not is_subagent():
    command = (payload.get("tool_input") or {}).get("command", "")
    bad = sorted({t for t in write_targets(command) if writes_source(t)})
    if bad:
        sys.stderr.write("BLOCKED by materialize conductor lock: this Bash command writes into the repo source tree.\n")
        sys.stderr.write("Offending target(s): " + ", ".join(bad) + "\n")
        sys.stderr.write("The main session is a pure conductor — delegate file writes to a sub-agent. It may write only its own state under .workflow/ (or agent worktrees), or paths outside the repo. Override a false positive with MATERIALIZE_SKIP_LOCK=1.\n")
        sys.exit(2)

sys.exit(0)
