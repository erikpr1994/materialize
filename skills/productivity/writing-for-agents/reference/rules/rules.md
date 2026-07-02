`rules` mode — the mechanics of a rule file: an always-on or scoped standard the agent applies while it works, not a procedure it runs. The universal principles (leading words, pruning, co-location, single source of truth, relevance, the failure modes) live in the base; this file holds only what is specific to rules.

## Scoping — load a rule only where it bears

A rule file's **scope** decides which requests pay its context load. Four scopes, widening cost:

- **Always-on** — loaded every request. Reserve for genuinely project-wide standards (commit format, repo layout). Each line here is the most expensive line you write; prune it hardest.
- **Glob/path-scoped** — loads only when a matching file is in play. The default home for language- and domain-specific rules: a standard scoped to `*.ts` costs nothing on a request that never touches one.
- **Agent-requested** — carries a description and stays out of context until the model pulls it in by that description. Same trade as a model-invoked skill — a sharp trigger description is the whole mechanism.
- **Manual** — loads only when you invoke it by name. Zero context load; you are the index that remembers it exists.

Prefer the narrowest scope that still fires when needed; reach for always-on last. A rule that bears on some files but loads on every request is a relevance failure paid every turn.

## Specificity — name the exact thing

The single highest-leverage move: name the concrete tool, format, or pattern, not the abstract goal. "Optimize images to WebP" gets followed; "write performant code" gets ignored — the agent can act on the first and only nods at the second. Push every rule down the abstraction ladder until it names something checkable.

## Positive framing — command the replacement

Affirmative instructions land more reliably than prohibitions; negation is a standing weakness of these models, so a bare "don't" is the least reliable shape a rule takes. Default to "prefer X". When you must rule out an anti-pattern, **pair it with the replacement** — "avoid enums; use a const object instead", not "never use enums". Reserve bare prohibitions for the irreversible or unsafe, where there is no replacement to name.

## Keep each rule small

One rule, one concern. Split a bloated file rather than grow it — caps people cite run a few hundred lines or about two pages per file, past which rules get silently dropped and the middle goes unread. There is no magic count, but density dilutes attention: every rule you add taxes the ones already there.

Prefer overriding or sharpening default behaviour; a rule the agent already follows is a no-op carried at always-on cost.

## Inline examples

Show structure, don't describe it: three to five concrete examples (`isLoading`, `hasError`; a good diff beside a bad one) pin a rule that prose only gestures at. An example is information, not bloat.

## Emphasis markers

`IMPORTANT` / `YOU MUST` work only by scarcity — spend them on the few most-violated or non-negotiable rules. Mark everything and you mark nothing; the weight averages out and the markers stop steering.

## Failure modes

Beyond the base set:

- **Contradiction** — two rules that pull opposite ways. The top failure of a rule file: the agent can't satisfy both, so it picks unpredictably. A rule set must be internally consistent before it can be anything else.
- **Vagueness** — an abstract rule with nothing checkable to act on (see Specificity).
- **Perfectionism** — withholding the file until it's complete. Rules tilt a probabilistic system; they don't guarantee. Prefer shipping an imperfect file and refining it from the failures you observe — an imperfect file beats none.
