# Design Workflow

## Problem

Without a stable design reference, frontend agents tend to invent visual decisions while coding. That causes repeated UI/UX rewrites and inconsistent components.

## Design pipeline

```text
requirement
 ↓
design exploration
 ↓
design contract
 ↓
Figma / design artifact
 ↓
component system
 ↓
builder
 ↓
visual verification
```

## Design contract

Store the decisions that must remain stable:

```yaml
design:
  direction:
    mood: [technical, calm, precise]
  layout:
    density: medium
  components:
    required: [navigation, table, card, chart]
  states: [loading, empty, error, success]
  constraints:
    - reuse existing components
    - avoid one-off styling
```

## Source-of-truth boundary

- Figma: visual design and interaction intent.
- Storybook/component library: implemented component vocabulary.
- Codebase: production behavior.
- Playwright: browser verification.

The agent should not silently redesign when implementation disagrees with the contract. It should propose a design change first.

## Non-UI visual work

Character and environment work should preserve a small “design DNA” artifact instead of only images:

```text
.clae/design/
└── <asset-id>/
    ├── dna.yaml
    ├── references/
    └── decisions.md
```

This allows future assets to reuse visual constraints without replaying the original prompts.
