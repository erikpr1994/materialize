#!/usr/bin/env python3
# materialize-mode-injector.py — SessionStart context injector (OPTIONAL, Claude Code).
#
# For an EXECUTOR context only (a sub-agent session or an agent worktree), finds the active work
# item and its current phase from the marker at `.workflow/<id>/marker.md` (matched by worktree or
# branch, else the latest-modified marker) and injects the phase's reference files into the starting
# context via SessionStart's additionalContext. The main-session conductor is a pure router that
# delegates each phase to a sub-agent, so it is exempt — injecting phase procedure into it would
# defeat progressive disclosure.
#
# The phase→file map is derived: the default file is `<phase>/<phase>.md` under the skill reference
# root; exceptions and supplementary files live in the shared materialize-phases.json beside this
# hook. The skill reference root is resolved from MATERIALIZE_SKILL_ROOT, then the standard install
# locations; if none exists this hook legitimately no-ops.
#
# Install via init: copy to .claude/hooks/ (with materialize-phases.json), register under
# hooks.SessionStart in .claude/settings.json.
import os
import sys
import json
import glob

try:
    payload = json.load(sys.stdin)
except Exception:
    payload = {}

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
    # Injection applies only to executor contexts; the main-session conductor is exempt.
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


def phase_files(ref_root, phase):
    # Default file is <phase>/<phase>.md; exceptions/supplementary come from the shared JSON.
    data = {}
    here = os.path.dirname(os.path.abspath(__file__))
    try:
        with open(os.path.join(here, "materialize-phases.json")) as f:
            data = json.load(f)
    except Exception:
        pass
    primary = (data.get("exceptions") or {}).get(phase) or "{0}/{0}.md".format(phase)
    rels = [primary] + list((data.get("supplementary") or {}).get(phase, []))
    return [os.path.join(ref_root, r) for r in rels], rels


def noop():
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart"}}))
    sys.exit(0)


if not is_executor():
    noop()

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

# Locate the marker.
marker = None
if issue_id:
    specific_marker = os.path.join(project_root, ".workflow", issue_id, "marker.md")
    if os.path.isfile(specific_marker):
        marker = specific_marker
if not marker:
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
    noop()

ref_root = find_ref_root(project_root)
if not ref_root:
    noop()

full_paths, rels = phase_files(ref_root, phase)
notes = []
for full_path, rel in zip(full_paths, rels):
    if os.path.isfile(full_path):
        try:
            with open(full_path, "r", errors="ignore") as f:
                content = f.read()
            notes.append(f"--- START REFERENCE: {rel} ---\n{content}\n--- END REFERENCE: {rel} ---")
        except Exception:
            pass

if notes:
    combined = (
        f"[MATERIALIZE ACTIVE MODE: {phase}]\nYou are executing the '{phase}' phase. "
        "Please follow the instructions in the following reference files:\n\n" + "\n\n".join(notes)
    )
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": combined}}))
else:
    noop()
sys.exit(0)
