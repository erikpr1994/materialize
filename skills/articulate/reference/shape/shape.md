This mode takes the raw-material pile and shapes it into a finished piece *as argument*, through a conversational session. The target platform is already chosen — keep its profile (`../platforms/<target>.md`) in context and shape to its length budget, hook, and formatting throughout. Hold the author's voice profile (loaded in setup) too, so it reads as theirs and obeys their hard rules. Read the pile end-to-end before doing anything else. Do not edit the pile — it is read-only here. Write the article to a separate file (ask once for the path, then remember it; re-read it before every write to preserve the user's edits).

## The loop

1. **Read the pile.** In full. Form a sense of what's in it.
2. **Draft 2–3 candidate openings.** Each implies a different thesis or angle. Show all of them; force the user to pick or compose a hybrid. The chosen opening defines what the rest must do.
3. **Grow paragraph by paragraph.** After the opening lands, ask "given this opening, what does the reader need next?" Pull material from the pile to answer. Argue about whether the next beat is a paragraph, list, table, callout, quote, or code block — each choice deliberate and defensible.
4. **Append to the article file as you go.** Don't batch. Write each agreed block immediately so the article takes shape in front of the user.
5. **Loop step 3 until done.** The user decides when it's done.

## Moves to keep using

- "What does this paragraph do for the reader that the previous one didn't?"
- "If I cut this, what breaks?"
- "Is this prose, or should it be a list? Why prose?"
- "This sentence is doing two jobs — split it or pick one."
- "The opening promised X. We've drifted to Y. Re-thread it or change the opening."

## Pulling from the pile

The pile is a quarry, not a script. Pull a fragment, rework it to fit the surrounding paragraph, place it. A fragment may be split, merged, or paraphrased. The pile's job is to be mined; the article's job is to read as one voice. If the pile lacks something the article needs, name the gap: "We need an example here and the pile doesn't have one — give me one now or we cut this section."

## Format arguments to actually have

- **Prose vs. list.** Prose carries argument; lists carry parallel items. Items not truly parallel → prose.
- **Inline vs. callout.** Asides go in callouts (`> [!TIP]`, `> [!NOTE]`) only if they'd genuinely derail the main argument inline.
- **Table vs. repeated structure.** Same shape repeating 3+ times with the same fields → table. Otherwise prose with bold leads.
- **Quote vs. paraphrase.** Quote when the wording is the point; paraphrase when only the idea matters.
- **Code block vs. inline code.** Multi-line, runnable, or illustrative → block. Single token → inline.

## Out of scope

Mining new fragments not in the pile (name the gap instead) and editing the pile. Platform formatting is *not* out of scope — the piece must come out platform-ready per the loaded profile; that's why the platform is chosen before this mode runs.
