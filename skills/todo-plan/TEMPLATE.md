# <Project name> — Development Plan

Single source of truth for what is built, what is next, and why.
Update the status cell in the same commit that changes the code.

## What this project is

<One paragraph: what it does, and the idea the layout follows.>

| Component | Folder | Responsibility |
|---|---|---|
| <role name> | `<folder>/` | <what it owns> |
| <role name> | `<folder>/` | <what it owns> |

## Target layout

```
<repo-name>/
├── <package>/
│   ├── <folder>/   <module> · <module> · <module>
│   └── <folder>/   <module> · <module>
├── docs/
├── tests/
├── TODO.md
└── README.md
```

<One line: what the layout commits to, and what it refuses.>

<!-- Delete this section when the code has fewer than two layers. -->
## Import boundary

| Package | May import |
|---|---|
| `<lowest>` | nothing in this project |
| `<next>` | `<lowest>` |

Risk: if <package A> imports <package B>, then <the concrete failure>.

<!-- Delete this section when the project ships no command or service. -->
## Entry points

| Command | Process | Started by |
|---|---|---|
| `<command>` | <what it runs> | <who or what starts it> |

<!-- Delete this section when work is not clock-driven or event-driven. -->
## Operating cycle

| Trigger | Activity | Job | Rows |
|---|---|---|---|
| <time or event> | <what happens> | `<job>` | <IDs> |

## Legend

```
status     done      shipped, covered by a test or verified live
           next      approved and in flight, at most 3 across the file
           plan      agreed direction, not started
           blocked   waiting on an external input
           parked    deliberately not built, reason in the row

value      1         prevents a loss
           2         finds an edge
           3         saves effort

effort     S         under an hour, one file
           M         half a day, one behaviour, one test group
           L         a day or more, split unless it must land atomically
```

## Scoreboard

```
scoreboard              done  next  plan  blocked  parked
  <L>  <area name>         0     0     0        0       0
  <L>  <area name>         0     0     0        0       0
```

---

## <L> — <Area name>

| ID | Feature | Status | Value | Effort | Depends on | Note |
|---|---|---|---|---|---|---|
| <L>1 | <Imperative phrase> | done | 1 | M | — | `<file>`, <n> tests |
| <L>2 | **<Imperative phrase>** | plan | 2 | S | <L>1 | Passes when <acceptance check> |

Reason: <why this area is ordered the way it is>.

**<L>2 blocks <what>.** <One line on why it must land first.>

<!-- A root cause longer than the cell goes here, not in the Note. -->
### <L>1

<The write-up: what was wrong, why, and what proved the fix.>

---

## Invariants

These hold for the life of the project. A change to one is a security review, not
a refactor.

| Invariant | Reason |
|---|---|
| <what must always be true> | <what breaks if it is not> |
