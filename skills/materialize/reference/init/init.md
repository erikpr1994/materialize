# Init

Scaffold the per-repo configuration that the workflow phases assume:

- **Issue tracker** — where issues live
- **Triage labels** — the strings used for the six canonical triage roles
- **Execution states** — the work-lifecycle states (In Progress / In Review / Done) and which transitions the tracker automates (Projects / Linear / Jira often auto-move on PR or merge), so phases don't double-drive them
- **Domain docs** — where `CONTEXT.md` and ADRs live, and the consumer rules for reading them
- **Principles** — the versioned project constitution (dependency rules, conventions) checked pre-`implement`
- **Orchestration** — the host harness's investigated sub-agent / workflow capability
- **Version marker** — `docs/agents/.init-version` (just a number); a later run re-inits when it differs from the skill's `.skill-version`

This is a prompt-driven mode, not a deterministic script. Explore, present what you found, confirm with the user, then write. Re-running is safe: it keeps existing config and only fills in what's missing.

## Process

### 1. Explore

Look at the current repo to understand its starting state. On a re-init, skip sections already configured and only investigate what's missing (e.g. a capability added since last time). Read whatever exists; don't assume:

- `git remote -v` and `.git/config` — is this a GitHub repo? Which one?
- `AGENTS.md` and `CLAUDE.md` at the repo root — does either exist? Is there already an `## Agent skills` section in either?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/` — does init's prior output already exist (e.g. `principles.md`)?
- `.scratch/` — sign that a local-markdown issue tracker convention is already in use
- The **host harness's orchestration capability** — don't assume it, **investigate** it (it drifts with harness versions). Identify which harness is running this, then find its *current* capabilities by the best means available: prefer the harness's own docs/help sub-agent if it has one (e.g. a native documentation agent), else WebSearch/WebFetch its official docs, else probe (try spawning a nested sub-agent) or ask the user. Find out: is there an Agent/Task sub-agent tool, can sub-agents nest and to what max depth, do they run in parallel, is there a workflow/pipeline or background/scheduled primitive, is there a native in-session task/to-do tool, and **how a sub-agent's model and reasoning effort are set** — they inherit the parent session's by default, so a cheaper executor only happens when pinned explicitly, never by omission. (Starting hint only — Claude Code supported nesting to depth 5 as of v2.1.172; verify, don't trust the figure.)

### 2. Present findings and ask

Summarise what's present and what's missing. Then walk the user through the decisions **one at a time** — present a section, get the user's answer, then move to the next. Don't dump them all at once.

Assume the user does not know what these terms mean. Each section starts with a short explainer (what it is, why these skills need it, what changes if they pick differently). Then show the choices and the default.

**Section A — Issue tracker.**

> Explainer: The "issue tracker" is where issues live for this repo. Phases like `issues`, `triage`, and `prd` read from and write to it — they need to know whether to call `gh issue create`, write a markdown file under `.scratch/`, or follow some other workflow you describe. Pick the place you actually track work for this repo.

Default posture: these skills were designed for GitHub. If a `git remote` points at GitHub, propose that. If a `git remote` points at GitLab (`gitlab.com` or a self-hosted host), propose GitLab. Otherwise (or if the user prefers), offer:

- **GitHub** — issues live in the repo's GitHub Issues (uses the `gh` CLI)
- **GitLab** — issues live in the repo's GitLab Issues (uses the [`glab`](https://gitlab.com/gitlab-org/cli) CLI)
- **Local markdown** — issues live as files under `.scratch/<feature>/` in this repo (good for solo projects or repos without a remote)
- **Other** — ask the user to describe the workflow in one paragraph; the skill will record it as freeform prose

If — and only if — the user picked **GitHub** or **GitLab**, ask one follow-up:

> Explainer: Open-source repos often receive feature requests as pull requests, not just issues — a PR is an issue with attached code. If you turn this on, `triage` pulls *external* PRs into the same queue and runs them through the same labels and states as issues (collaborators' in-flight PRs are left alone). Leave it off if PRs aren't a request surface for you.

- **PRs as a request surface** — yes / no (default: no). Record the answer in `docs/agents/issue-tracker.md`. For local-markdown and other trackers, skip this question — there are no PRs.

**Section B — Triage label vocabulary.**

> Explainer: When the `triage` mode processes an incoming issue, it moves it through a state machine — needs evaluation, waiting on reporter, ready for an AFK agent to pick up, ready for a human, paused on a blocker, or won't fix. To do that, it needs to apply labels (or the equivalent in your issue tracker) that match strings *you've actually configured*. If your repo already uses different label names (e.g. `bug:triage` instead of `needs-triage`), map them here so the mode applies the right ones instead of creating duplicates.

The six canonical roles and their meanings live in the [`triage-labels.md`](./triage-labels.md) seed template (init writes it to `docs/agents/triage-labels.md`). Show the user that table and ask whether they want to override any label string. Default: each role's string equals its name — if their issue tracker has no existing labels, the defaults are fine.

**Section C — Domain docs.**

> Explainer: Some phases (`architecture`, `debug`, `tdd`) read a `CONTEXT.md` file to learn the project's domain language, and accepted ADRs in `docs/adr/` for in-force architectural decisions. They need to know whether the repo has one global context or multiple (e.g. a monorepo with separate frontend/backend contexts) so they look in the right place.

Confirm the layout:

- **Single-context** — one `CONTEXT.md` + `docs/adr/` at the repo root. Most repos are this.
- **Multi-context** — `CONTEXT-MAP.md` at the root pointing to per-context `CONTEXT.md` files (typically a monorepo).

**Section D — Principles (the project constitution).**

> Explainer: Principles are the repo's standing rules — dependency rules (what's allowed to import what), naming and layout conventions, banned patterns, anything an implementation must not violate. They live in a versioned `docs/agents/principles.md` (a "constitution"), bumped when a rule changes. The `implement` phase reads them as a pre-flight check, so a slice that breaks a rule is caught before code lands.

Seed from what the repo already states — existing `CLAUDE.md` / `AGENTS.md` rules, lint/CI config, ADRs — and confirm with the user. Don't invent rules; record the ones the project actually holds. If there are none yet, write a minimal stub with a `version:` header the user can grow.

**Sections E–H — capability slots.** Each slot is *resolved*, not just defaulted. Don't ask per slot — run the resolve procedure below and only surface a question on a collision.

> Explainer: Some phases swap in a per-repo skill for a step. Each step is a capability slot. Rather than ask you to name one, init scans the skills already installed in this repo and binds by capability.

Resolve each slot before drafting. Bind each under its **exact canonical key** — `code-search`, `UI/design`, `review`, `verify`, `browser`, `tracker` — so the key init writes equals the one the phases look up:

1. **Detect candidates.** Scan installed skills/tools — list the skills install dir, read skill manifests, check for MCP servers — and match by the slot's *capability*, not by name:
   - **UI/design** — skills for building/polishing UI prototypes or mockups. Built-in default: `prototype`.
   - **review** — skills that critique code or PRs. Built-in default: `review`.
   - **code-search** — semantic- or code-search tools / MCP servers. Built-in default: Explore + Grep/Glob/Read.
   - **verify** — skills that independently verify behavior against acceptance criteria. Built-in default: `verify`.
   - **browser** — browser/app-automation skills that drive a live running app, used by `accept`. Built-in default: manual run.
   - **tracker** — the tracker CLI/MCP present (resolved in Section A above).
2. **Auto-bind when unambiguous.** Exactly one candidate (typically the built-in default) → bind it silently, no question.
3. **Reconcile collisions.** Two or more candidates for one slot — built-in default, a separately-installed skill that overlaps the slot's capability, or a workflow skill a prior run provisioned — collide. If one is a clear winner (e.g. the repo's own installed skill over the built-in default), auto-bind it; otherwise list the colliding candidates and ask which to bind. This is the only slot question that should ever appear. Note which existing skills were detected and how each slot resolved in the written block.
4. **Fall back to default.** No candidate beyond the built-in default → use the default.

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to whichever of `CLAUDE.md` / `AGENTS.md` is being edited (see step 4 for selection rules)
- The contents of `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`, `docs/agents/principles.md`

Let them edit before writing.

### 4. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create — don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa) — always edit the one that's already there.

**Re-running is safe.** If an `## Agent skills` block already exists in the chosen file, update it in-place — never append a second block. Reconcile each subsection and slot line to the current resolved values, drop slot lines that fell back to default, add ones that now bind, and migrate stale entries from an older layout (e.g. an earlier flat list) into the current subsection structure. Don't overwrite user edits to the surrounding sections.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked, plus whether external PRs are a triage surface]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout — "single-context" or "multi-context"]. See `docs/agents/domain.md`.

### Principles

[one-line summary of the project constitution — dependency rules, conventions]. Checked pre-`implement`. See `docs/agents/principles.md`.

### Capability slots

- code-search: [bound tool, or built-in Explore + Grep/Glob/Read (default)]
- UI/design: [bound skill, or `prototype` (default)]
- review: [bound skill, or `review` (default)]
- verify: [bound skill, or `verify` (default)]
- browser: [bound skill, or manual run (default)]
```

Bind each slot line under its exact canonical key — `code-search`, `UI/design`, `review`, `verify`, `browser` (the `tracker` slot is the Issue tracker section above). Only include a slot line if a non-default candidate was resolved (auto-bound or chosen on collision); otherwise omit it and the phase falls back to the default. Skip the whole `### Capability slots` heading if nothing non-default bound.

Then write the docs files using the seed templates in this mode folder as a starting point:

- [issue-tracker-github.md](./issue-tracker-github.md) — GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) — GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md) — local-markdown issue tracker
- [triage-labels.md](./triage-labels.md) — label mapping
- [execution-states.md](./execution-states.md) — work-lifecycle state mapping + which transitions the tracker automates
- [domain.md](./domain.md) — domain doc consumer rules + layout
- `docs/agents/principles.md` — the project constitution (see Section D)
- `docs/agents/orchestration.md` — the host harness's orchestration capability (see below)
- `docs/agents/.init-version` — the version stamp (the skill's current `.skill-version` number)

There is no seed template for `docs/agents/principles.md` — write it from the rules confirmed in Section D, under a `version:` header (start at `version: 1`, bump it whenever a rule changes). `implement` reads this file as a pre-flight check.

There is no seed template for `docs/agents/orchestration.md` either — write it from what the investigation found: sub-agent support (none / single-level / nested) and **max depth**, whether sub-agents run in parallel, any workflow/pipeline or background/scheduled primitive, any native in-session task/to-do tool (the conductor and sub-agents mirror `pipeline:` into it; the marker stays the source of truth), **the syntax to pin a sub-agent's model/effort** (so the cost knob below is actually reachable — they inherit the parent's otherwise), and a **working depth** to use by default (≤ max; lower it for cost or a weaker executor model). Record the **source and date checked** for each capability (harness docs URL, native-agent answer, or "probed") — these drift, so a stale entry is a signal to re-investigate, not to trust. The conductor and `work` read it to decide how to fan out; absent the file they assume single-level sub-agents, no nesting.

Write `docs/agents/.init-version` last — just the current version number, copied from the skill's `.skill-version`. The conductor and the hook compare the two to decide whether a re-init is due. (Bump `.skill-version` whenever you change what `init` produces — that's what makes existing repos re-init.)

**Optional — install the version hook (Claude Code).** Install [hooks/materialize-setup-check.sh](./hooks/materialize-setup-check.sh) into `.claude/hooks/` and register it under `hooks.SessionStart` in `.claude/settings.json`, with `SKILL_VERSION_FILE` pointed at the installed skill's `.skill-version`. It compares `.init-version` against `.skill-version` once per session and tells the model to re-run `init` on a mismatch. Harnesses without hooks rely on the conductor's inline check.

**Optional — install the pipeline-gate hook (Claude Code).** Install [hooks/materialize-pipeline-gate.sh](./hooks/materialize-pipeline-gate.sh) into `.claude/hooks/` and register it under `hooks.PreToolUse` (matcher `Bash`) in `.claude/settings.json`. On a STANDARD/SPEC run it blocks `gh pr create` / `git push` of a code change unless every phase the workflow type prescribes is accounted for in the marker (done or logged `skipped: <reason>`) and verify left a verdict under `.workflow/`, enforcing the **Pipeline gate** deterministically. It checks that phases were *declared* and that verify produced an artifact — whether each ran *well*, verify's independence, and `accept` stay the conductor's job. Override a false positive with `MATERIALIZE_SKIP_GATE=1`. Harnesses without hooks rely on the gate prose.

For "other" issue trackers, write `docs/agents/issue-tracker.md` from scratch using the user's description.

Also add `.workflow/` and `.worktrees/` to the repo's `.gitignore` (the marker/scratch dir the workflow skills write, and the workspace-local home for `work`'s per-executor worktrees). Create `.gitignore` if it's missing; skip any glob already present.

### 5. Done

Tell the user the setup is complete and which phases will now read from these files. Mention they can edit `docs/agents/*.md` directly later (bumping `principles.md`'s `version:` when they change a rule) — re-running init by hand is only necessary to switch issue trackers or restart from scratch, since the conductor (and the `SessionStart` hook on Claude Code) re-prompts `init` whenever `.init-version` falls behind the skill's `.skill-version`.
