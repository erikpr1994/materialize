#!/usr/bin/env python3
# materialize-mode-enforcer.py — PreToolUse mode reader enforcer (OPTIONAL, Claude Code).
#
# In an EXECUTOR context only (a sub-agent session or an agent worktree), forces the executor to
# read the active phase's reference file(s) before it may use any non-Read tool. The main-session
# conductor is a pure router that delegates each phase to a sub-agent, so it is exempt — it never
# executes phase work itself and must not be blocked.
#
# The phase→file map is derived: the default file is `<phase>/<phase>.md` under the skill reference
# root; exceptions and supplementary files live in the shared materialize-phases.json beside this
# hook. The skill reference root is resolved from MATERIALIZE_SKILL_ROOT, then the standard install
# locations; if none exists this hook legitimately no-ops.
#
# Install via init: copy to .claude/hooks/ (with materialize-phases.json), register under
# hooks.PreToolUse (matcher ".*") in .claude/settings.json.
import os
import sys
import json
import glob

try:
    payload = json.load(sys.stdin)
except Exception:
    sys.exit(0)  # If invalid JSON, let it proceed

root = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())
project_root = root


def in_worktree(p):
    # True if p is inside an agent worktree (.claude/worktrees/... or .worktrees/...).
    if not p:
        return False
    parts = os.path.normpath(p).split(os.sep)
    if ".worktrees" in parts:
        return True
    return any(parts[i] == ".claude" and i + 1 < len(parts) and parts[i + 1] == "worktrees" for i in range(len(parts) - 1))


def is_executor():
    # Enforcement applies only to executor contexts; the main-session conductor is exempt.
    if payload.get("agent_id"):
        return True
    if in_worktree(payload.get("cwd", "")) or in_worktree(root):
        return True
    import subprocess
    pid = os.getpid()
    while pid > 1:
        try:
            output = subprocess.check_output(
                ["ps", "-o", "ppid=,args=", "-p", str(pid)],
                stderr=subprocess.DEVNULL,
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


def find_ref_root(base):
    # The skill reference dir: MATERIALIZE_SKILL_ROOT (absolute, or relative to base), then installs.
    cands = []
    env = os.environ.get("MATERIALIZE_SKILL_ROOT")
    if env:
        cands.append(env if os.path.isabs(env) else os.path.join(base, env))
    cands.append(os.path.join(base, ".claude", "skills", "materialize", "reference"))
    cands.append(os.path.join(base, "skills", "materialize", "reference"))
    for c in cands:
        if os.path.isdir(c):
            return c
    return None


def phase_files(phase):
    # Default file is <phase>/<phase>.md; exceptions/supplementary come from the shared JSON.
    data = {}
    here = os.path.dirname(os.path.abspath(__file__))
    try:
        with open(os.path.join(here, "materialize-phases.json")) as f:
            data = json.load(f)
    except Exception:
        pass
    primary = (data.get("exceptions") or {}).get(phase) or "{0}/{0}.md".format(phase)
    return [primary] + list((data.get("supplementary") or {}).get(phase, []))


if not is_executor():
    sys.exit(0)

# Detect an isolated worktree under .worktrees/<issue_id> or .claude/worktrees/<issue_id>.
norm_root = os.path.normpath(root)
parts = norm_root.split(os.sep)
issue_id = None
if ".worktrees" in parts:
    idx = parts.index(".worktrees")
    project_root = os.sep.join(parts[:idx]) or os.sep
    if idx + 1 < len(parts):
        issue_id = parts[idx + 1]
else:
    for i in range(len(parts) - 1):
        if parts[i] == ".claude" and parts[i + 1] == "worktrees":
            project_root = os.sep.join(parts[:i]) or os.sep
            if i + 2 < len(parts):
                issue_id = parts[i + 2]
            break

# Try to detect the issue from the current git branch name.
if not issue_id:
    try:
        import subprocess
        branch = subprocess.check_output(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            cwd=project_root,
            stderr=subprocess.DEVNULL,
        ).decode().strip()
        if branch:
            if os.path.isdir(os.path.join(project_root, ".workflow", branch)):
                issue_id = branch
            else:
                wf_dir = os.path.join(project_root, ".workflow")
                if os.path.isdir(wf_dir):
                    for folder in os.listdir(wf_dir):
                        if folder in branch and os.path.isdir(os.path.join(wf_dir, folder)):
                            issue_id = folder
                            break
    except Exception:
        pass

# Locate the marker and its workflow directory.
marker = None
workflow_dir = None
if issue_id:
    specific_marker = os.path.join(project_root, ".workflow", issue_id, "marker.md")
    if os.path.isfile(specific_marker):
        marker = specific_marker
        workflow_dir = os.path.dirname(specific_marker)
if not marker:
    markers = glob.glob(os.path.join(project_root, ".workflow/*/marker.md"))
    if markers:
        marker = max(markers, key=os.path.getmtime)
        workflow_dir = os.path.dirname(marker)

if not marker or not workflow_dir:
    sys.exit(0)

phase = None
try:
    with open(marker, "r") as f:
        for line in f:
            if line.lower().startswith("phase:"):
                phase = line.split(":", 1)[1].strip()
                break
except Exception:
    pass

if not phase:
    sys.exit(0)

ref_root = find_ref_root(project_root)
if not ref_root:
    sys.exit(0)

# Only enforce files that actually exist under the skill reference root.
required_rel_paths = [p for p in phase_files(phase) if os.path.isfile(os.path.join(ref_root, p))]
if not required_rel_paths:
    sys.exit(0)

tool_name = payload.get("tool_name", "")
tool_input = payload.get("tool_input", {})

# If tool is Read, mark a required file as read when it matches.
if tool_name == "Read":
    file_path = tool_input.get("file_path", tool_input.get("path", ""))
    if file_path:
        norm_file_path = os.path.abspath(file_path)
        for rel_path in required_rel_paths:
            norm_req_path = os.path.abspath(os.path.join(ref_root, rel_path))
            if norm_file_path == norm_req_path:
                slug = os.path.basename(rel_path).replace(".", "_")
                flag_file = os.path.join(workflow_dir, f".read-{phase}-{slug}")
                try:
                    os.makedirs(workflow_dir, exist_ok=True)
                    with open(flag_file, "w") as f:
                        f.write("read")
                except Exception:
                    pass
                sys.exit(0)

# Which required files are still unread?
unread_files = []
for rel_path in required_rel_paths:
    slug = os.path.basename(rel_path).replace(".", "_")
    flag_file = os.path.join(workflow_dir, f".read-{phase}-{slug}")
    if not os.path.isfile(flag_file):
        unread_files.append(rel_path)

if unread_files and tool_name != "Read":
    sys.stderr.write(f"BLOCKED by materialize mode enforcer: You are executing the '{phase}' phase.\n")
    sys.stderr.write("You must first read the following required reference files using the Read tool before you can use other tools:\n")
    for uf in unread_files:
        sys.stderr.write(f" - {uf}\n")
    sys.exit(2)

sys.exit(0)
