#!/usr/bin/env python3
# materialize-mode-enforcer.sh — PreToolUse mode reader enforcer (OPTIONAL, Claude Code).
#
# Forces the agent to read the active phase reference file(s)
# (skills/materialize/reference/<phase>/<phase>.md and any supplementary files)
# before it can use any other tools (like Write, Edit, Bash).
#
# Install via init: copy to .claude/hooks/, register under hooks.PreToolUse
# (matcher ".*" or specific tools like "Write|Edit|Bash") in .claude/settings.json.
import os
import sys
import json
import glob

# Read payload from stdin
try:
    payload = json.load(sys.stdin)
except Exception:
    sys.exit(0)  # If invalid JSON, let it proceed

root = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())
project_root = root

# Detect if running in an isolated worktree under .worktrees/<issue_id>
norm_root = os.path.normpath(root)
parts = norm_root.split(os.sep)
issue_id = None
if ".worktrees" in parts:
    idx = parts.index(".worktrees")
    project_root = os.sep.join(parts[:idx])
    if idx + 1 < len(parts):
        issue_id = parts[idx + 1]

# Try to detect from current git branch name (Case A - branch match)
if not issue_id:
    try:
        import subprocess
        branch = subprocess.check_output(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            cwd=project_root,
            stderr=subprocess.DEVNULL
        ).decode().strip()
        
        if branch:
            # Check if the exact branch name matches an issue directory
            if os.path.isdir(os.path.join(project_root, ".workflow", branch)):
                issue_id = branch
            else:
                # Check for substring matches (e.g. branch feature/issue-123 matching folder issue-123)
                wf_dir = os.path.join(project_root, ".workflow")
                if os.path.isdir(wf_dir):
                    for folder in os.listdir(wf_dir):
                        if folder in branch and os.path.isdir(os.path.join(wf_dir, folder)):
                            issue_id = folder
                            break
    except Exception:
        pass

# Locate the correct marker file and workflow directory
marker = None
workflow_dir = None
if issue_id:
    specific_marker = os.path.join(project_root, ".workflow", issue_id, "marker.md")
    if os.path.isfile(specific_marker):
        marker = specific_marker
        workflow_dir = os.path.dirname(specific_marker)

if not marker:
    # Fallback: find the latest modified marker across all workflows
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

# Map phase to its main reference file and any supplementary/dependent files
phase_files = {
    "implement": [
        "skills/materialize/reference/implement/implement.md",
        "skills/materialize/reference/tdd/tdd.md"
    ],
    "design": [
        "skills/materialize/reference/design/design.md",
        "skills/materialize/reference/design/DESIGN-IT-TWICE.md",
        "skills/materialize/reference/design/DEEPENING.md"
    ],
    "prototype": [
        "skills/materialize/reference/prototype/prototype.md",
        "skills/materialize/reference/prototype/UI.md",
        "skills/materialize/reference/prototype/LOGIC.md"
    ],
    "tdd": [
        "skills/materialize/reference/tdd/tdd.md",
        "skills/materialize/reference/tdd/tests.md",
        "skills/materialize/reference/tdd/deep-modules.md"
    ],
    "verify": [
        "skills/materialize/reference/verify/verify.md"
    ],
    "accept": [
        "skills/materialize/reference/verify/verify.md"
    ]
}

# Fallback: if not explicitly mapped, default to skills/materialize/reference/<phase>/<phase>.md
required_rel_paths = phase_files.get(phase, [f"skills/materialize/reference/{phase}/{phase}.md"])
# Only enforce files that actually exist in the skills repo
required_rel_paths = [p for p in required_rel_paths if os.path.isfile(os.path.join(project_root, p))]

if not required_rel_paths:
    sys.exit(0)

tool_name = payload.get("tool_name", "")
tool_input = payload.get("tool_input", {})

# If tool is Read, check if they are reading one of the required files
if tool_name == "Read":
    file_path = tool_input.get("file_path", tool_input.get("path", ""))
    if file_path:
        norm_file_path = os.path.abspath(file_path)
        for rel_path in required_rel_paths:
            norm_req_path = os.path.abspath(os.path.join(project_root, rel_path))
            if norm_file_path == norm_req_path:
                # Mark this specific file as read
                slug = os.path.basename(rel_path).replace(".", "_")
                flag_file = os.path.join(workflow_dir, f".read-{phase}-{slug}")
                try:
                    os.makedirs(workflow_dir, exist_ok=True)
                    with open(flag_file, "w") as f:
                        f.write("read")
                except Exception:
                    pass
                sys.exit(0)

# Check which required files are still unread
unread_files = []
for rel_path in required_rel_paths:
    slug = os.path.basename(rel_path).replace(".", "_")
    flag_file = os.path.join(workflow_dir, f".read-{phase}-{slug}")
    if not os.path.isfile(flag_file):
        unread_files.append(rel_path)

if unread_files:
    # If they are using any tool other than Read (like Bash, Write, Edit), block it!
    if tool_name != "Read":
        sys.stderr.write(f"BLOCKED by materialize mode enforcer: You are executing the '{phase}' phase.\n")
        sys.stderr.write("You must first read the following required reference files using the Read tool before you can use other tools:\n")
        for uf in unread_files:
            sys.stderr.write(f" - {uf}\n")
        sys.exit(2)

sys.exit(0)
