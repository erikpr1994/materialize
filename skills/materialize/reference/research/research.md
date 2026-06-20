# Research

The named **research phase** of materialize (STANDARD / SPEC only — QUICK / FREEFORM skip it).
Autonomous codebase exploration that produces a concept-first research doc *before* design, so the
planning context stays lean.

**Charter: document what IS, not what SHOULD BE.** No recommendations, no critique, no design. Just
how the relevant code actually works today, with `file:line` citations.

## 1. Frame the questions

Open the research from the Issue / grill notes. Cluster the unknowns into concrete questions.
Non-leakage rule: ask *how does it work* — never *how would we change it*. The design phase decides
the change; research only maps the ground.

## 2. Gate fan-out on complexity

Scale breadth to the task — don't fan out 5 agents for a one-file question:

| Task | Fan-out |
|---|---|
| trivial / single area | **1** Explore agent (or just Grep/Glob/Read inline) |
| a feature | **2–3** agents — locator + analyzer (+ pattern-finder) |
| broad / cross-cutting | **3–6** agents, one per cluster of questions |

Roles (built-in **Explore**):

- **locator** — where does X live? Files, dirs, entry points.
- **analyzer** — how does X work? Trace the flow end to end.
- **pattern-finder** — find similar existing code to copy from.

If the repo binds a **code-search** slot (a semantic-search tool recorded in `docs/agents/`), each
agent uses it; else Grep / Glob / Read.

## 3. Each sub-agent gets a contract

Hand every agent an explicit contract:

- **role** — one read-cluster as locator / analyzer / pattern-finder; objective · output format ·
  scope boundary. No critique, no design — same charter.
- **depth** — nest its own sub-agents up to the working depth where a cluster splits further.
- **built-ins first** — use built-in **Explore** for reads; don't define custom agents.

Require `file:line` citations and a fixed parseable shape.

**Telephone game — the anti-pattern to avoid:** sub-agents **WRITE** their findings to a file
(`.workflow/<issue>/` for scratch, `docs/` for durable); the orchestrator **READS** those files.
Never relay findings through prompts or summaries-of-summaries — each relay hop loses fidelity.

## 4. Synthesize

Read the sub-agent files and write one concept-first doc to
`.workflow/<issue>/02-research-<slug>.md` (gitignored scratch — serves implementation, then
discardable). Organize by concept, not by sub-agent. Cite `file:line` throughout.

Cite the real thing, not a paraphrase:

- BAD — "auth is handled in the middleware."
- GOOD — "`requireSession` rejects unauthenticated requests (`src/mw/auth.ts:42`)."

## 5. Surface open questions as EARS candidates

End the doc with the unknowns research could not settle, phrased as candidate acceptance predicates
the verification phase can check:

```
WHEN <trigger> THE SYSTEM SHALL <observable behavior>
```

These seed `prd` acceptance criteria and `verify`. **Completeness gate:** emit each unresolved open
question as a literal `[NEEDS CLARIFICATION: <question>]` token, and do not exit this phase while any
remain. Mark each as **open** — a later phase resolves it; research never auto-resolves.

## Output

A gitignored `02-research-<slug>.md`: how the relevant code works today (cited), plus the open EARS
candidates with any unresolved questions flagged as `[NEEDS CLARIFICATION: …]`. No design, no
recommendations. Hand it to the design phase.
