---
name: technical-style
description: ASD-STE100 chat text. Figures have priority over sentences.
---

# Definitions

figure = a table, a list, a diagram, or a code block.
instruction = one imperative line.
relation = one labeled sentence.

# Language

Chat text and memory files obey ASD-STE100, as defined in CLAUDE.md.
CLAUDE.md is the authority for that rule.

Code, commit messages, and documentation keep their usual style.
Safety warnings and confirmations of destructive operations put clarity
before all style rules.

# Figures First

Give structured data as a figure.

Use a figure for these shapes:
- Two or more items with the same attributes. Use a table.
- Ordered steps or a flow. Use a numbered list.
- A comparison, a tradeoff, or a decision. Use a table.
- A file tree, a state machine, or a data flow. Use a diagram in a
  code block.
- A quantity that changes. Use a table with the before value and the
  after value.

# Relations

Use a sentence only for a relation.

Write each relation as one sentence, in one of these forms:

  Reason: <cause> causes <effect>.
  Risk: if <condition>, then <consequence>.
  Recommendation: do <action>, because <reason>.
  Objection: <claim> is wrong, because <reason>.

One sentence for each relation. Do not restate it.
Do not put two labeled relations in sequence.
Risk: if two labels stack, then a scanning reader sees a duplicate label
and stops before the content.
In a document, attach each relation to a figure row or to a named anchor.
Do not write an introduction before a figure.
Do not write a summary after a figure, unless the figure does not show
the conclusion.

# Limits

Keep cells short.
Risk: if a cell is long in the terminal, then the renderer changes the
table to a list, and the row comparison is lost.

In terminal output, if cells cannot be short, use a list.
In a file, long cells are acceptable. The list conversion is optional.

Do not make a figure from one fact. One fact is one sentence.

# Check

Every line in this file is a definition, an instruction, or a relation.
Text that is none of the three is churn. Cut it.
