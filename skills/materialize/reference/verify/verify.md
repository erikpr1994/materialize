# Verify

Independent confirmation that a change **meets its spec**. The verifier is a **fresh sub-agent that
did NOT write the code** — never the implementer self-checking. Distinct from `review`: review
critiques code quality; verify confirms behavior matches what was asked.

The default for materialize's **verify** slot. If the repo binds another verify skill, use that;
else run this.

## At PRD scope (accept)

Invoked as **`accept`** (the final SPEC phase): same procedure, at whole-PRD scope — every behavior
across all issues, driven live through the **browser** slot (no browser skill bound → exercise the
flows by hand) against the running app, not a single diff. Never mark a UI predicate PASS without
observing it live. Unresolved FAILs become new Issues, per the pipeline gate. The verdict sets
`accepted:` in the marker.

## 1. Pin the predicates

**EARS** (Easy Approach to Requirements Syntax) writes each requirement as "When \<trigger\>, the
\<system\> shall \<response\>" — giving every verdict a checkable predicate.

Collect what the change is supposed to do, in order:

1. **EARS predicates** from the research doc (`.workflow/<id>/NN-research-*.md`) or PRD —
   `WHEN <trigger> THE SYSTEM SHALL <behavior>`.
2. **Acceptance criteria** from the Issue / spec.
3. If none are written, derive a short **context-grounded rubric** from the Issue and the changed
   code — one checkable line per intended behavior.

Write each predicate as an **observable check** — a command (or interaction) plus its expected result — never vague prose like "works correctly." A predicate you can't turn into a check is itself a finding.

**Establish a baseline first.** Capture and run the project's verification commands (build, test, lint, typecheck). Nothing runnable is the first **FAIL** — there's nothing to verify against. If it's red, separate a regression from inherited debt: reproduce on the unchanged tree (stash, or check out the base). Red the change **introduced** (green→red, or a new failure) is its FAIL; red already failing on the base and unrelated to the change isn't — note it, verify against the rest, and don't block the verdict on debt the change merely inherited.

## 2. Consistency pass

Before the per-predicate checks, cross-check the spec artifacts against each other and the diff —
PRD ↔ Issues / acceptance criteria ↔ tech design (`docs/<id>-tech-design.md`) / ADRs ↔ the actual change. Flag any:

- **requirement with no implementing change** — stated behavior that nothing in the diff delivers;
- **change with no requirement** — code that no predicate or criterion asked for;
- **contradiction** — artifacts that disagree (an ADR vs. the PRD, an acceptance criterion vs. the
  diff).

Report each mismatch alongside the predicate verdicts; an empty list is itself a result.

## 3. Spawn a fresh verifier

One sub-agent that has **not** seen the implementation reasoning. Its contract:

- **role** — an independent fresh-context check of one predicate-set; never the implementer
  self-checking. Hand it the predicates / rubric and the diff or changed files.
- **depth** — nest its own sub-agents up to the working depth when one predicate-set splits into independent
  checks.
- **built-ins first** — bound **code-search** slot if the repo records one, else built-in
  **Explore**/`general-purpose`.
- **file contract** — verifier **WRITES** verdicts and evidence to a file (`.workflow/<id>/` scratch,
  `docs/` durable); orchestrator **READS** it — never a prompt relay.

The brief —

> For each predicate, determine PASS or FAIL by *observing actual behavior*: run the command, read
> the file, exercise the path — for UI/product behavior, **drive the running app** via the `browser`
> slot. Quote concrete evidence for every verdict. Do not assume; if you
> can't observe it, mark **UNVERIFIED** and say why. No code-quality critique — that's `review`.

## 4. Report per predicate

One row per predicate — verdict plus the evidence that earned it:

| Predicate | Verdict | Evidence |
|---|---|---|
| WHEN … SHALL … | PASS / FAIL / UNVERIFIED | command run · file:line · observed behavior |

Evidence must be concrete: the command and its output, the `file:line` checked, or the behavior seen
when the path was exercised. A PASS with no evidence is a FAIL.

End with a one-line roll-up: counts per verdict, and the single most important FAIL (if any).

## 5. Route the FAILs

Fix trivial FAILs in-session. For the rest — and every UNVERIFIED — **propose** a tracker issue per
finding (title, the predicate, the observed evidence), and file them via the `issues` mode / `tracker`
slot **only after the user confirms**. Each issue links back to its predicate. Don't block the
roll-up on filing; an unconfirmed list is a valid end state — **except** per-issue verify, where open
FAILs block that issue's PR (see *At PRD scope (accept)* above for the `accept` variant).

## Rules

| Rule | Detail |
|---|---|
| Independence | Verifier never wrote the code; fresh context |
| Evidence | Every verdict cites a command / file / observed behavior |
| Scope | Confirm behavior vs spec — not code quality (use `review`) |
| Honesty | Can't observe it → **UNVERIFIED**, never an assumed PASS |
| No reassurance | An unsettleable correctness claim stays **UNVERIFIED** until a named test or empirical observation settles it — never accept "should be fine" as a PASS |
