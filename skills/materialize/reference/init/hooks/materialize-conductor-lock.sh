#!/usr/bin/env python3
# materialize-conductor-lock.sh — PreToolUse lock: the main conductor session may not Write/Edit; only sub-agents may. Install via init under hooks.PreToolUse (matcher "Write|Edit").
import os
import sys
import json

try:
    payload = json.load(sys.stdin)
except Exception:
    sys.exit(0)

root = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())


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


if payload.get("tool_name", "") in ["Write", "Edit"] and not is_subagent():
    sys.stderr.write("BLOCKED by materialize conductor lock: The main session is a pure conductor.\n")
    sys.stderr.write("You are not allowed to edit or write files directly in this session. You must delegate all implementation and phase tasks to sub-agents.\n")
    sys.exit(2)

sys.exit(0)
