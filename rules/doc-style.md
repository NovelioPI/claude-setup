## Documentation

### Scope

These rules cover a document a human reads: `README.md`, a file under
`plans/`, and any doc file the user asks for.

A file an agent reads as instructions follows the `writing-for-agents`
skill instead: `SKILL.md`, `CLAUDE.md`, and a file under `rules/`.

### Shape

Start with a title.
Write one sentence under the title that says what the file is for.
Use free headings. Do not force a fixed section list.
Show two or more items with the same attributes as a table.
Show ordered steps as a numbered list.

### Sentences

Cap a sentence at 20 words.
Cap a paragraph at three sentences.
Use the active voice.
Write the full form. Write "do not", not "don't".

A long explanation is many short sentences. It is not one long sentence.

### Background

Mark a proof or a long background with a `## Background` heading.
Inside that section only, the sentence cap rises to 30 words.

### Words

Use both tables in @rules/plain-words.md.
Do not use a figure of speech.

### Theory

| Need | Tool |
|---|---|
| An equation | Display block, one equation for each line |
| Symbols | Table with Symbol, Meaning, Unit |
| A defined term | Table at the top with Term and Plain meaning |
| A derivation | Numbered list, one step for each line |

Reason: a symbol table removes the clause that would explain each letter
inside the sentence.

### Analogy

Write an analogy on its own line, after the label `Analogy:`.
The label tells the reader the sentence is not literal.

### Markers

Use these emoji only: ✅ pass, ❌ fail, ⚠️ warning, ❓ question, ➡️ next step.
