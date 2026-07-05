#!/usr/bin/env python3
# materialize-conductor-lock.py — PreToolUse lock: the main conductor session may not write source files; only sub-agents may.
# Blocks Write/Edit outright, and Bash commands that write into the repo source tree — closing the heredoc/tee/redirect/sed hole
# (a conductor could otherwise sidestep the Write/Edit block with `cat >file`, `tee`, `sed -i`, …). Writes to the conductor's
# OWN state (.workflow/, agent worktrees) and to paths outside the repo (memory, /tmp, scratch) stay allowed — those are
# conductor bookkeeping, not source. Scoped to conductor sessions: a session becomes one by writing a .workflow/<id>/marker.md
# (stamped as .conductor-<session_id> beside it); sessions that never ran materialize are not conducted. Best-effort string
# inspection: a guardrail, not a sandbox. Override a false positive by prefixing the Bash command with MATERIALIZE_SKIP_LOCK=1.
# Install via init under hooks.PreToolUse with matcher "Write|Edit|Bash".
import os
import re
import sys
import json
import glob

try:
    payload = json.load(sys.stdin)
except Exception:
    sys.exit(0)

name = payload.get("tool_name", "")
command = (payload.get("tool_input") or {}).get("command", "") if name == "Bash" else ""

# The hook runs BEFORE the command, so an env prefix in the command string never reaches
# this process's env — honor the override from the string itself too.
if os.environ.get("MATERIALIZE_SKIP_LOCK") == "1" or "MATERIALIZE_SKIP_LOCK=1" in command:
    sys.exit(0)

root = os.path.abspath(os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd()))
base = payload.get("cwd") or root


def in_worktree(p):
    # True if p is inside an agent worktree — the mandated .worktrees/ home or Claude Code's native .claude/worktrees/.
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


def stamp_conductor(target):
    # A session that writes a .workflow/<id>/marker.md is conducting that run — stamp its
    # session id beside the marker so the lock can be scoped to it.
    sid = payload.get("session_id") or ""
    if not sid or not target:
        return
    t = os.path.abspath(os.path.join(base, os.path.expanduser(target)))
    if os.path.basename(t) == "marker.md" and ".workflow" in t.split(os.sep):
        try:
            os.makedirs(os.path.dirname(t), exist_ok=True)
            open(os.path.join(os.path.dirname(t), ".conductor-" + sid), "w").close()
        except Exception:
            pass


def is_conductor():
    # The lock applies only to sessions stamped as a run's conductor — a concurrent session
    # that never entered materialize must not inherit a sibling's restriction. Without a
    # session_id the stamp can't be compared; keep the old always-on behavior.
    sid = payload.get("session_id") or ""
    if not sid:
        return True
    return bool(glob.glob(os.path.join(root, ".workflow", "*", ".conductor-" + sid)))


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
    # fd duplications (2>&1, >&2) are not file writes — drop them before the single-& split mangles them.
    command = re.sub(r'\d*>&\d+', ' ', command)
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
        # cp / mv / install / rsync in COMMAND position only — `pnpm install` / `pip install` are not coreutils install.
        m = re.match(r'\s*(?:\w+=\S*\s+)*(?:sudo\s+)?(cp|mv|install|rsync)\s+(.+)', seg)
        if m:
            toks = [t for t in m.group(2).split() if not t.startswith('-')]
            if toks:
                targets.append(toks[-1].strip('"\''))
    # Unparseable scraps (lone line-continuation backslashes, stray quotes) are not real paths — fail open on those.
    return [t for t in targets if t.strip('\\"\' ')]


if name in ["Write", "Edit"]:
    tool_input = payload.get("tool_input") or {}
    target = tool_input.get("file_path") or tool_input.get("filePath") or ""
    stamp_conductor(target)
    if not is_subagent() and is_conductor() and writes_source(target):
        sys.stderr.write("BLOCKED by materialize conductor lock: The main session is a pure conductor.\n")
        sys.stderr.write("You are not allowed to write source files directly in this session — delegate implementation and phase tasks to sub-agents. The conductor may still write its own state under .workflow/ (or agent worktrees) and paths outside the repo. Override a false positive by re-issuing via Bash prefixed with MATERIALIZE_SKIP_LOCK=1.\n")
        sys.exit(2)

if name == "Bash":
    bash_targets = write_targets(command)
    for t in bash_targets:
        stamp_conductor(t)
    if not is_subagent() and is_conductor():
        bad = sorted({t for t in bash_targets if writes_source(t)})
        if bad:
            sys.stderr.write("BLOCKED by materialize conductor lock: this Bash command writes into the repo source tree.\n")
            sys.stderr.write("Offending target(s): " + ", ".join(bad) + "\n")
            sys.stderr.write("The main session is a pure conductor — delegate file writes to a sub-agent. It may write only its own state under .workflow/ (or agent worktrees), or paths outside the repo. Override a false positive by prefixing the command with MATERIALIZE_SKIP_LOCK=1.\n")
            sys.exit(2)

sys.exit(0)
