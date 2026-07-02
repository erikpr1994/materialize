# Domain Glossary

The shared language for this repo. Skill prose and reviews are held to these terms; the banned synonyms
under each `_Avoid_` line are grep-enforced by `scripts/lint-skills.sh`.

## Conductor

The main session driving a pipeline run: it picks the next phase, delegates it to a sub-agent, and reads
the verdict back. It never runs phase work itself — a mode owns that.

_Avoid_: router, dispatcher

## Mode

One phase's procedure, at `reference/<mode>/<mode>.md`, loaded on demand rather than kept resident in the
conductor's context.

_Avoid_: sub-skill, command

## Phase

One unit of a pipeline run — `research`, `design`, `implement`, and so on — executed by a mode.

_Avoid_: stage, step

## Stage

The grouping a mode's Modes-table row falls under: Setup, Plan, Design, Build, Verify, Ship, or Fix.

_Avoid_: category

## Workflow

The ceremony level picked per work item: QUICK, STANDARD, SPEC, or FREEFORM. Determines which phases run.

## Pipeline

The prescribed phase sequence a chosen workflow stamps into the marker's `pipeline:` rows when picked.

## Issue

A tracker work item, whatever tracker is bound to the `tracker` capability slot.

_Avoid_: ticket, task

## Work item

The umbrella unit driven end to end — an Issue or a freshly minted slug. Its ID keys the `.workflow/<id>/`
scratch dir, the marker, and dated artifacts.

## Marker

`.workflow/<id>/marker.md` — the durable per-work-item state, written at each phase transition and read on
resume.

## Executor

The sub-agent a conductor delegates one phase to. It returns a one-line verdict plus an artifact path, never
its full working state.

_Avoid_: worker

## Run

One multi-issue `work` execution — many issues driven at once, each its own stacked PR.

_Avoid_: sweep

## Capability slot

A swappable binding (`code-search`, `UI/design`, `review`, `verify`, `browser`, `tracker`) that a consuming
repo wires to an installed skill. Committed files name the slot, never the product behind it.

## HITL / AFK

Human-in-the-loop (HITL): input only a human can supply, where the conductor halts and waits. AFK: work that
proceeds unattended between those halts.

## EARS

Easy Approach to Requirements Syntax — "When `<trigger>`, the `<system>` shall `<response>`." Canonical
in-skill home is `reference/verify/verify.md`.

## `[NEEDS CLARIFICATION]` vs `[NEEDS DECISION]`

`[NEEDS CLARIFICATION: …]` marks an unresolved branch inside a spec-producing artifact (PRD, tech design,
research). `[NEEDS DECISION: … — recommend: …]` is a delegated executor's escalation of a blocked question
back to the conductor. Distinct mechanisms — don't conflate them.

## Grilling

The one-question-at-a-time interview technique used under every phase to reach shared understanding: walk
each branch, ask, recommend an answer, repeat.

---

Skill files must never link back to this repo-root file — skills install standalone, and any definition an
executor needs lives in its own in-skill home instead.
