# Output Style Format Samples

Pick one format. Every section answers the same two questions.

Sample data below is invented. It is not verified against this repo.

- **Scenario 1 (one fact)** — "Does the hook block `git reset --hard`?"
- **Scenario 2 (many rows)** — "Which files touch `settings.json`?"

Labels used: `Reason:` why it is true. `Risk:` what breaks, and when. `Next:` the action to take.

---

## A — `--help` shape

Fixed left column. Aligned values. No sentences unless needed.

### Scenario 1

```
ANSWER  Yes. The hook blocks it.
FILE    hooks/block-dangerous-git.sh:12
REASON  The pattern on line 12 matches the command.
NEXT    Nothing.
```

### Scenario 2

```
FOUND   3 files touch settings.json

  scripts/sync-settings.sh:40      write   permissions.ask
  hooks/block-dangerous-git.sh:88  read    permissions.ask
  skills/handoff/SKILL.md:12       doc     names the key

NEXT    Read scripts/sync-settings.sh first. It is the only writer.
```

---

## B — BLUF + figure

One bold answer line. Then a table when there are rows.

### Scenario 1

**Yes — the hook blocks it.**

Reason: the pattern on `hooks/block-dangerous-git.sh:12` matches the command.

### Scenario 2

**3 files touch `settings.json`. Only one writes.**

| File | Line | Access | Key |
|---|---|---|---|
| scripts/sync-settings.sh | 40 | write | permissions.ask |
| hooks/block-dangerous-git.sh | 88 | read | permissions.ask |
| skills/handoff/SKILL.md | 12 | doc | permissions.ask |

Next: read `scripts/sync-settings.sh` first.

---

## C — Slot card

The same four labels every time, even when a slot is empty.

### Scenario 1

```
WHAT   The hook blocks `git reset --hard`.
WHERE  hooks/block-dangerous-git.sh:12
RISK   None.
NEXT   Nothing.
```

### Scenario 2

```
WHAT   3 files touch settings.json. One writes, one reads, one documents.
WHERE  scripts/sync-settings.sh:40, hooks/block-dangerous-git.sh:88,
       skills/handoff/SKILL.md:12
RISK   If sync-settings.sh runs twice, then permissions.ask gets duplicates.
NEXT   Read scripts/sync-settings.sh first.
```

---

## D — Mixed (A for one fact, B for rows)

### Scenario 1

```
ANSWER  Yes. The hook blocks it.
FILE    hooks/block-dangerous-git.sh:12
NEXT    Nothing.
```

### Scenario 2

**3 files touch `settings.json`. Only one writes.**

| File | Line | Access |
|---|---|---|
| scripts/sync-settings.sh | 40 | write |
| hooks/block-dangerous-git.sh | 88 | read |
| skills/handoff/SKILL.md | 12 | doc |

Next: read `scripts/sync-settings.sh` first.

---

## E — Error triad

Three slots, shaped for problems. Weak for plain questions.

### Scenario 1

```
RESULT  ✅ Blocked.
CAUSE   Line 12 matches the command.
ACTION  None needed.
```

### Scenario 2

```
RESULT  ⚠️ 3 files touch settings.json.
CAUSE   scripts/sync-settings.sh:40 is the only writer.
ACTION  Read that file first.
```

---

## F — SBAR

From nursing handover. Four slots. Longest of the six.

### Scenario 1

```
SITUATION       You asked if the hook blocks `git reset --hard`.
BACKGROUND      The hook reads a pattern list at the top of the file.
ASSESSMENT      Line 12 matches. The command is blocked.
RECOMMENDATION  No change needed.
```

### Scenario 2

```
SITUATION       You asked which files touch settings.json.
BACKGROUND      Three files name the file. Access differs.
ASSESSMENT      Only scripts/sync-settings.sh:40 writes to it.
RECOMMENDATION  Read that file first.
```

---

## Compare

| Format | Lines, S1 | Lines, S2 | One fact | Many rows | Label cost |
|---|---|---|---|---|---|
| A `--help` | 4 | 8 | Good | Good | Low |
| B BLUF | 3 | 9 | Good | Best | None |
| C slot card | 4 | 7 | Padded | Good | High |
| D mixed | 3 | 9 | Good | Best | Low |
| E error triad | 3 | 3 | Good | Poor | Low |
| F SBAR | 4 | 4 | Padded | Poor | High |

## How to choose

1. If you want one shape for everything, pick **A** or **C**.
2. If you accept two shapes, pick **D**.
3. If you want the fewest words, pick **B**.
4. **E** and **F** lose the row comparison. Pick them only if you never need tables.

Risk: if you pick a fixed-slot format (C, E, F), then a one-word answer still costs four lines.
