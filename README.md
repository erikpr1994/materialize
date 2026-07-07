# Skills For Real Engineers

[![skills.sh](https://skills.sh/b/erikpr1994/Materialize)](https://skills.sh/erikpr1994/Materialize)

Agent skills for real engineering — not vibe coding.

Where repos like [`mattpocock/skills`](https://github.com/mattpocock/skills) ship a couple dozen small, separately-invoked skills, Materialize collapses the entire engineering pipeline into **one model-invoked conductor — [`materialize`](./skills/materialize/SKILL.md)** — that picks the right amount of process and drives an idea all the way to shipped code. One skill in your agent's context instead of twenty-four, with the phases loaded on demand.

## Quickstart

1. Install it:

   ```bash
   npx skills@latest add erikpr1994/Materialize
   ```

2. Pick the skills and agents to install them on. **Select `materialize`.**

3. Run `/materialize init` in your agent. It will:
   - Ask which issue tracker you use (GitHub, GitLab, or local files)
   - Ask what labels you apply when triaging Issues (the `triage` mode uses them)
   - Ask where to save the docs it creates
   - **Bind your capability slots** — point the UI/design, code-search, review, verify, and tracker slots at whatever installed skills fill them best (e.g. a dedicated design skill on the UI slot)

To update later: `npx skills update`.

## materialize — the conductor

`materialize` takes an unfiltered idea → docs → defined scope → full implementation. Invoke it bare to have it pick the workflow and drive the phases, name a workflow up front with `/materialize <workflow>`, or jump straight to a phase with `/materialize <mode>`.

The workflow sets how much ceremony the idea gets — the conductor recommends one and your pick wins:

| Workflow | For | Phases |
|---|---|---|
| **QUICK** | a typo, one-liner, or obvious fix | implement → PR |
| **STANDARD** | a single feature | research → prototype → design → prepare → implement → verify → PR |
| **SPEC** | a feature needing a product spec | research → PRD → prototype → design → issues → [per issue: prepare → implement → review → verify → pr] → merge → accept |
| **FREEFORM** | ad-hoc work with no fixed shape | nothing — just work |

The modes below are the phases those workflows chain. Phases are loaded only when reached, so the whole pipeline costs one description in context.

| Mode | Stage | What it does |
|---|---|---|
| [`init`](./skills/materialize/reference/init/init.md) | Setup | Bind capability slots, learn the project, set conventions |
| [`wayfinder`](./skills/materialize/reference/wayfinder/wayfinder.md) | Plan | Plan work too big for one agent session — a sequenced map of open-question issues |
| [`grill`](./skills/materialize/reference/grill/grill.md) | Plan | Interview you relentlessly to stress-test a plan or design to shared understanding |
| [`research`](./skills/materialize/reference/research/research.md) | Plan | Investigate open questions via sub-agents, write findings to `.workflow/<id>/` |
| [`prd`](./skills/materialize/reference/prd/prd.md) | Plan | Write the product spec (PRD) |
| [`issues`](./skills/materialize/reference/issues/issues.md) | Plan | Slice the settled design into vertical-slice issues (the plan) |
| [`prepare`](./skills/materialize/reference/prepare/prepare.md) | Plan | Prepare a single task/issue for implementation |
| [`triage`](./skills/materialize/reference/triage/triage.md) | Plan | Clear blocked / needs-info issues so they become actionable |
| [`design`](./skills/materialize/reference/design/design.md) | Design | Codebase design — design it twice, then deepen; domain modeling + ADRs when domain-heavy; writes `.workflow/<id>/tech-design.md` |
| [`prototype`](./skills/materialize/reference/prototype/prototype.md) | Design | Build an interactive UI prototype to settle the look |
| [`implement`](./skills/materialize/reference/implement/implement.md) | Build | Implement a feature/issue slice-by-slice |
| [`tdd`](./skills/materialize/reference/tdd/tdd.md) | Build | Test-driven development at the seams |
| [`review`](./skills/materialize/reference/review/review.md) | Verify | Code review of the change |
| [`verify`](./skills/materialize/reference/verify/verify.md) | Verify | Independently confirm the change does what it should |
| [`accept`](./skills/materialize/reference/verify/verify.md) | Verify | Final whole-PRD acceptance — live end-to-end verify of the shipped spec |
| [`pr`](./skills/materialize/reference/pr/pr.md) | Ship | Write the PR description |
| [`debug`](./skills/materialize/reference/debug/debug.md) | Fix | Diagnose a bug to root cause |
| [`architecture`](./skills/materialize/reference/architecture/architecture.md) | Fix | Improve codebase architecture |
| [`test-debt`](./skills/materialize/reference/test-debt/test-debt.md) | Fix | Prune low-value tests; refocus the suite on observable behavior |
| [`merge`](./skills/materialize/reference/merge/merge.md) | Fix | Resolve merge conflicts |

For project-scale work, `materialize` drives many issues at once — one stacked PR per issue, each in its own sub-agent, HITL blockers cleared in parallel (the `work` driver). Grilling, handoff/resume, and the durability discipline (committed `docs/`, gitignored `.workflow/<id>/` scratch, per-item marker) run underneath every phase.

## articulate — the writing conductor

`articulate` is the prose sibling to `materialize`: it turns rough thinking into published writing. You pick the target platform up front — a blog post and a LinkedIn post differ from the first fragment, not just at the end — and that profile tunes the whole pipeline: mine raw material (from you, and from the repo/git log/PRs for a coding project) → shape it into a finished, platform-ready piece. Invoke it bare to have it pick the ceremony, or jump to a phase with `/articulate <mode>`.

| Mode | Stage | What it does |
|---|---|---|
| [`init`](./skills/articulate/reference/init/init.md) | Setup | Interview you once into a reusable voice profile — style, what makes it yours, hard rules, platforms & cadence |
| [`fragments`](./skills/articulate/reference/fragments/fragments.md) | Mine | Grill you (and read the repo for a coding project) into a pile of raw material |
| [`shape`](./skills/articulate/reference/shape/shape.md) | Shape | Build the piece for the platform as argument, paragraph by paragraph |
| [`beats`](./skills/articulate/reference/beats/beats.md) | Shape | Build the piece for the platform as narrative, beat by beat |

`init` captures your **voice** once into a global `~/.claude/writing/author.md` (repo-local `docs/writing/author.md` only as an override) — style, differentiators, hard rules ("never write *excited to share*"), and per-platform cadence — and every piece loads it. Each platform also has a **profile** under [`reference/platforms/`](./skills/articulate/reference/platforms/) (`linkedin.md`, `blog.md`, `twitter.md`) — length budget, hook, formatting, failure modes — improved over time. Voice (author) × format (platform) combine on every piece. Adding a platform is a new profile file, not a new mode. Same single-skill, on-demand-`reference/` design as `materialize`: the whole pipeline costs one description in context.

## Other skills

A few skills stay standalone — they aren't part of the idea→ship pipeline:

- **[`teach`](./skills/productivity/teach/SKILL.md)** *(user-invoked)* — teach a concept interactively.
- **[`writing-for-agents`](./skills/productivity/writing-for-agents/SKILL.md)** *(user-invoked)* — reference for writing and editing any agent-facing artifact — skills, agent instruction files, and rule files.

## Inspiration

The single-skill, progressively-disclosed conductor design stands on prior art:

- **[`mattpocock/skills`](https://github.com/mattpocock/skills)** — the skills this project grew from; every phase's content is reworked from here.
- **[impeccable](https://impeccable.style)** ([source](https://github.com/pbakaus/impeccable)) — the one-skill-with-on-demand-`reference/`-modes pattern this repo adopts.
- **[HumanLayer](https://humanlayer.com)** — human-in-the-loop and agent-driving ideas behind the AFK-vs-HITL split and the autonomy gates.
- **[shadcn/improve](https://github.com/shadcn/improve)** — audit-and-handoff discipline across `review`/`verify`/`prepare`/`work`/`triage`/`issues`/`architecture`: vet because sub-agents over-report, `introduced`-vs-`pre-existing` tagging, machine-checkable done criteria with a green baseline, executable handoff contracts (out-of-scope + STOP conditions + drift check), reviewing executor output as untrusted (scope check, test-gaming audit), backlog reconciliation, and treating repository content as data to audit (not instructions to obey).
- **[martin2844/skills](https://github.com/martin2844/skills)** (`big-review`) — review/verify sharpening: disprove-before-emit (name the trigger → path → wrong outcome, or drop it), the asymmetric false-positive stance (a false positive costs more than a missed bug; "no findings" is a successful review), impact-gated uncertainty, reviewing what is *not* in the diff, and never accepting "should be fine" as a PASS.

A scheduled [`glean` routine](docs/routines/glean.md), backed by a `source-triage` backlog, works through all of the above — plus [brooks-lint](https://github.com/hyhmrright/brooks-lint) and Claude Code `/code-review` (evaluated, nothing adopted yet — their current practices collided with ours) — harvesting ideas from each source's code, issues, and discussions and opening one small PR at a time.

## License

Apache 2.0. See [LICENSE](./LICENSE). Inspired by and originally derived from [`mattpocock/skills`](https://github.com/mattpocock/skills).
