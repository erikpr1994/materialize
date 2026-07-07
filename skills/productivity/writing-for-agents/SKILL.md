---
name: writing-for-agents
description: Reference for writing and editing any agent-facing artifact — the vocabulary and principles that make it predictable. Covers authoring a skill, agent instruction files, and rule files.
disable-model-invocation: true
---

Every agent-facing artifact wrangles determinism out of a stochastic system. **Predictability** — the agent taking the same _process_ every run, not producing the same output — is the root virtue; every principle below serves it. A brainstorming artifact should _predictably_ diverge: its tokens vary, its behaviour doesn't.

The principles are universal. The Modes table at the end points to one artifact kind's mechanics each; everything above it holds wherever you're writing.

## Leading words — recruit pretrained priors

A **leading word** (also _Leitwort_) is a compact concept already in the model's pretraining that the agent thinks with while running the artifact (e.g. _lesson_, _fog of war_, _tracer bullets_). Repeated as a token — never as a sentence — it accumulates a distributed definition and anchors a whole region of behaviour in the fewest tokens, by recruiting priors the model already holds. A strong word may need only one appearance.

It serves predictability twice. In the body it anchors _execution_: the agent reaches for the same behaviour every time the word appears. In a trigger it anchors _invocation_: when the same word lives in your prompts, docs, and code, the agent links that shared language to the artifact and fires it more reliably.

Coining your own works if you define it clearly, but a made-up word recruits no priors — you pay in definition tokens what a pretrained word gives free. Reach for an existing word first.

Hunt for refactors to leading words. A triad spelled out at three sites (**duplication**), a trigger spending a sentence to gesture at one idea — each begs to **collapse** into a single token:

- "fast, deterministic, low-overhead" → _tight_ — one quality restated across a phase, into a single pretrained word (a _tight_ loop).
- "a loop you believe in" → _red_ — a fuzzy gate becomes a binary observable state (the loop goes _red_, or it doesn't).

You win twice: fewer tokens, _and_ a sharper hook for the agent to hang its thinking on. Assume every artifact carries restatements that leading words retire — go find them.

## Pruning — hunt no-ops sentence by sentence

A **no-op** is a line the model already obeys by default, so you pay load to say nothing. The test: does it change behaviour versus the default? A weak leading word (_be thorough_ when the agent is already thorough-ish) is a no-op; the fix is a stronger word (_relentless_), not a different technique — so the no-op test also grades whether a leading word earns its repetitions.

This is model-relative, not reader-relative: two people disputing whether a line is a no-op disagree about the default, and settle it by running the artifact, not by debate.

Hunt no-ops sentence by sentence, not just line by line: run the test on each sentence in isolation, and when one fails, delete the whole sentence rather than trim words. Be aggressive — most prose that fails should go, not be rewritten.

## Co-location — definition, rules, and caveats together

Keep a concept's definition, rules, and caveats under one heading rather than scattered, so reading one part brings its neighbours with it. There is no formula for the right format of a body of reference; the test is that it should read like documentation written for the agent — and grouped material reads that way where scattered material does not.

Distinct from duplication: that repeats one meaning in two places, where scattering fragments one meaning across many.

## Single source of truth

Keep each meaning in exactly one authoritative place, so changing the behaviour is a one-place edit. **Duplication** is its violation: one meaning given more than one home costs maintenance (change one, you must change the rest), costs tokens, and inflates a meaning's prominence past its real rank. Duplication is the accidental inverse of a leading word, which raises attention on purpose by repeating a token, never the meaning.

## Relevance — context load is a cost paid every turn

Anything always-loaded — above all a **trigger** — sits in the window every turn, spending tokens _and_ attention continuously, not once. So prune always-on material hardest, and check every line for **relevance**: does it still bear on what the artifact does?

A line loses relevance two ways: it never bore on the task (mere exposition, or material that should be disclosed behind a pointer), or it went stale as the behaviour or world it describes changed. Shorter artifacts stay relevant more easily — each line is cheaper to check. Relevance asks whether a line bears on the task; no-op asks whether it changes behaviour — a line can be perfectly relevant and still a no-op.

## Failure modes are diagnostics

Use these to diagnose what's going wrong with an artifact:

- **No-op** — a line the model already obeys by default. Fix: delete, or strengthen the leading word.
- **Negation** — a prohibition backfires: naming the unwanted behaviour lifts it into context and makes it _more_ probable, not less (_don't think of an elephant_). Fix: state the **positive** target so the unwanted one is never named; keep a bare "don't" only as a hard guardrail with no positive phrasing, and pair it with what to do instead.
- **Duplication** — the same meaning in more than one place. Fix: pick one source of truth, point the rest at it.
- **Sediment** — stale layers that settle because adding feels safe and removing feels risky. The default fate of any artifact without a pruning discipline; the slow erosion of relevance. Fix: core down and clear.
- **Sprawl** — an artifact simply too long, even when every line is live and unique. Thins attention, costs maintenance and tokens. Distinct from sediment (stale length) and duplication (repeated length) — sprawl is length itself. Fix: disclose reference behind pointers; split so each path carries only what it needs.

## Modes

Per-kind mechanics live behind these pointers; the principles above apply to all three.

| Mode | Artifact | Reference |
|---|---|---|
| `skills` | A model- or user-invoked skill (`SKILL.md` + its reference tree) | [reference/skills/skills.md](reference/skills/skills.md) |
| `instructions` | An agent instruction file loaded for a project or session | [reference/instructions/instructions.md](reference/instructions/instructions.md) |
| `rules` | An always-on or scoped rule file, global or path-scoped | [reference/rules/rules.md](reference/rules/rules.md) |
