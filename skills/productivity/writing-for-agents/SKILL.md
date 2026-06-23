---
name: writing-for-agents
description: "Guidelines and principles for writing predictable, token-efficient agent-facing skills, rules, and instructions."
disable-model-invocation: true
---

# Writing for Agents

Every agent-facing artifact must prioritize **Predictability** (process determinism) and token efficiency.

## Core Principles

- **Leading Words**: Use pretrained prior concepts (e.g., _lesson_, _red_) to anchor behavior/triggers rather than spelling out complex rules or using coined synonyms.
- **Pruning**: Delete no-op sentences. Test: *Does this sentence change the agent's default behavior?* If not, delete it.
- **Co-location**: Keep a concept's definition, rules, and caveats grouped under a single heading.
- **Single Source of Truth**: Avoid duplication. Keep each instruction in exactly one home and reference/link to it.
- **Relevance**: Keep files short. Prune always-on triggers hardest to minimize active context load.

## Diagnostics (Failure Modes)

- **No-Op**: Instructions the agent obeys by default. (Fix: Delete, or swap for a stronger leading word).
- **Duplication**: The same meaning repeated in multiple places. (Fix: Merge and cross-link).
- **Sediment**: Stale instructions left behind from previous iterations. (Fix: Core down and clear).
- **Sprawl**: Artifacts that are excessively long, even if unique. (Fix: Use progressive disclosure to reference files).

## Modes

Refer to kind-specific reference files for execution mechanics:

| Mode | Artifact | Reference |
|---|---|---|
| `skills` | Model- or user-invoked skill (`SKILL.md`) | [reference/skills/skills.md](reference/skills/skills.md) |
| `instructions` | Project/session instruction files (`CLAUDE.md`) | [reference/instructions/instructions.md](reference/instructions/instructions.md) |
| `rules` | Scoped rule files (`AGENTS.md`) | [reference/rules/rules.md](reference/rules/rules.md) |
