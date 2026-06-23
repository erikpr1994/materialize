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

def is_subagent():
    # 1. Path check: if CWD contains .worktrees, it is a sub-agent
    if ".worktrees" in os.path.normpath(root).split(os.sep):
        return True
        
    # 2. Process check: look for '--agent' in the ancestor chain
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
