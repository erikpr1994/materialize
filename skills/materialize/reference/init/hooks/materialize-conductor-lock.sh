#!/usr/bin/env python3
# materialize-conductor-lock.sh — PreToolUse main session editor lock (OPTIONAL, Claude Code).
#
# Disallows the main conductor session from editing or writing files directly,
# enforcing the rule that all code modifications must be delegated to sub-agents.
#
# Install via init: copy to .claude/hooks/, register under hooks.PreToolUse
# (matcher "Write|Edit") in .claude/settings.json.
import os
import sys
import json

# Read payload from stdin
try:
    payload = json.load(sys.stdin)
except Exception:
    sys.exit(0)

root = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())

def in_worktree(p):
    # True if path p lives inside an agent worktree. Covers the Agent tool's
    # `.claude/worktrees/agent-<id>` layout and the legacy `.worktrees/<id>`.
    if not p:
        return False
    parts = os.path.normpath(p).split(os.sep)
    if ".worktrees" in parts:
        return True
    for i in range(len(parts) - 1):
        if parts[i] == ".claude" and parts[i + 1] == "worktrees":
            return True
    return False

def is_subagent():
    # 1. Agent id: the payload carries a non-empty agent_id only inside a
    #    sub-agent context (the main session has just session_id). This is the
    #    primary, layout-independent signal — covers in-process sub-agents too.
    if payload.get("agent_id"):
        return True

    # 2. Path check: the edit target or the session cwd lives inside a worktree.
    #    CLAUDE_PROJECT_DIR points at the MAIN repo even for worktree sub-agents,
    #    so the reliable signals are the payload's file_path and cwd, not root.
    tool_input = payload.get("tool_input") or {}
    file_path = tool_input.get("file_path") or tool_input.get("filePath") or ""
    cwd = payload.get("cwd", "")
    if in_worktree(file_path) or in_worktree(cwd) or in_worktree(root):
        return True

    # 3. Process check: look for '--agent' in the ancestor chain. Catches
    #    out-of-process sub-agents that aren't isolated in a worktree.
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

tool_name = payload.get("tool_name", "")

if tool_name in ["Write", "Edit"]:
    if not is_subagent():
        sys.stderr.write("BLOCKED by materialize conductor lock: The main session is a pure conductor.\n")
        sys.stderr.write("You are not allowed to edit or write files directly in this session. You must delegate all implementation and phase tasks to sub-agents.\n")
        sys.exit(2)

sys.exit(0)
