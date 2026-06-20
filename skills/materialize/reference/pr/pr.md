# Describe a PR

Write the PR description for the current branch. This is the PR phase for `work` and materialize: `verify`
confirms the change behaves, `pr` documents it. Don't reimplement either.

## Procedure

1. **Find the PR** — The PR lives on the repo's **VCS host** (GitHub → `gh`, GitLab → `glab`), which
   may differ from the Issue tracker. Detect the PR for the current branch (e.g. `gh pr view`); if none
   exists, create it (e.g. `gh pr create`). No VCS CLI → skip; you'll output the markdown instead.
2. **Read the diff** — The branch diff against its base (e.g. `git diff <base>...HEAD`). Group the
   meaningful changes; note what was deliberately left alone.
3. **Draft the body** — Fill the template below. Pull the *How to verify* steps from the Issue's
   acceptance criteria and any EARS `WHEN … SHALL …` predicates in the research/verify artifacts
   (`.workflow/<issue>/`); if none, derive concrete steps from the diff.
4. **Publish** — Tracker CLI present → update the PR body (e.g. `gh pr edit --body-file`). Else print
   the markdown for the user to paste.

## PR body template

```markdown
## What & why
<the problem, then a one-paragraph summary of the change>

## Key changes
- <meaningful diff, grouped by area>

## Deliberately NOT changed
- <scope boundary held / thing left alone, and why>

## How to verify
1. <concrete step — pull WHEN … SHALL … predicates / acceptance criteria where they exist>

## Links
- Issue: <link> · related artifacts: <links>
```

Optional: deep-link a file in GitHub's "Files changed" tab via its `sha256(file_path)` anchor —
`printf '%s' <path> | shasum -a 256`.
