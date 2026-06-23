#!/usr/bin/env python3
# materialize-mode-injector.sh — SessionStart context injector (OPTIONAL, Claude Code).
#
# Automatically finds the active work item and its current phase from the
# latest marker at `.workflow/*/marker.md` (or the specific issue's marker
# if running in a concurrent worktree or a branch). If matching phase reference
# files or supplementary files exist, it reads them and injects their contents
# into the session start context via SessionStart's additionalContext.
#
# Install via init: copy to .claude/hooks/, register under hooks.SessionStart in
# .claude/settings.json.
import os
import sys
import json
import glob

# Drain stdin (SessionStart payload is passed here but not needed)
sys.stdin.read()

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

# Locate the correct marker file
marker = None
if issue_id:
    specific_marker = os.path.join(project_root, ".workflow", issue_id, "marker.md")
    if os.path.isfile(specific_marker):
        marker = specific_marker

if not marker:
    # Fallback: find the latest modified marker across all workflows
    markers = glob.glob(os.path.join(project_root, ".workflow/*/marker.md"))
    if markers:
        marker = max(markers, key=os.path.getmtime)

phase = None
if marker:
    try:
        with open(marker, "r") as f:
            for line in f:
                if line.lower().startswith("phase:"):
                    phase = line.split(":", 1)[1].strip()
                    break
    except Exception:
        pass

if not phase:
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart"}}))
    sys.exit(0)

# Full map of phase reference files (covering all SPEC workflow and utility modes)
phase_files = {
    # SPEC / STANDARD workflow phases
    "research": [
        "skills/materialize/reference/research/research.md"
    ],
    "prd": [
        "skills/materialize/reference/prd/prd.md"
    ],
    "design": [
        "skills/materialize/reference/design/design.md",
        "skills/materialize/reference/design/DESIGN-IT-TWICE.md",
        "skills/materialize/reference/design/DEEPENING.md"
    ],
    "issues": [
        "skills/materialize/reference/issues/issues.md"
    ],
    "prepare": [
        "skills/materialize/reference/prepare/prepare.md"
    ],
    "implement": [
        "skills/materialize/reference/implement/implement.md",
        "skills/materialize/reference/tdd/tdd.md"
    ],
    "verify": [
        "skills/materialize/reference/verify/verify.md"
    ],
    "review": [
        "skills/materialize/reference/review/review.md"
    ],
    "pr": [
        "skills/materialize/reference/pr/pr.md"
    ],
    "merge": [
        "skills/materialize/reference/merge/merge.md"
    ],
    "accept": [
        "skills/materialize/reference/verify/verify.md"
    ],
    # Utility / on-demand modes
    "map": [
        "skills/materialize/reference/map/map.md"
    ],
    "grill": [
        "skills/materialize/reference/grilling/grilling.md"
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
    "triage": [
        "skills/materialize/reference/triage/triage.md"
    ],
    "debug": [
        "skills/materialize/reference/debug/debug.md"
    ],
    "architecture": [
        "skills/materialize/reference/architecture/architecture.md"
    ]
}

# Fallback: if not explicitly mapped, default to skills/materialize/reference/<phase>/<phase>.md
files = phase_files.get(phase, [f"skills/materialize/reference/{phase}/{phase}.md"])

notes = []
for rel_path in files:
    full_path = os.path.join(project_root, rel_path)
    if os.path.isfile(full_path):
        try:
            with open(full_path, "r", errors="ignore") as f:
                content = f.read()
            notes.append(f"--- START REFERENCE: {rel_path} ---\n{content}\n--- END REFERENCE: {rel_path} ---")
        except Exception:
            pass

if notes:
    combined_notes = f"[MATERIALIZE ACTIVE MODE: {phase}]\nYou are executing the '{phase}' phase. Please follow the instructions in the following reference files:\n\n" + "\n\n".join(notes)
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": combined_notes}}))
else:
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart"}}))
sys.exit(0)
