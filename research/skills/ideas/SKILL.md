---
name: ideas
description: Turn paper notes into research ideas in notes/ideas.md, each checked against prior work. Use when the user asks for ideas, gaps, or directions.
---

# Write research ideas

Base every idea on notes in `notes/papers/`. Read them first.

## Check each idea

1. Search for the closest prior work with the `research:papers` skill.
2. Name it, or write "none found in <sources searched>".
3. Write the strongest reason the idea could fail.

Say when an idea is weak, and why. Do not invent novelty.

## Entry

Append to `notes/ideas.md`:

    ## I-<n> <short title>
    - Idea: <two sentences at most>
    - Based on: <note IDs>
    - Closest prior work: <paper ID and how this differs, or "none found in ...">
    - Could fail because: <one line>
    - Cost: <API cost, GPU hours, or data work, as a rough size>
    - Status: open

`<n>` counts up across the file. Status is `open`, `planned`, or `dropped`.
A dropped idea keeps its entry and gets a one-line reason.
