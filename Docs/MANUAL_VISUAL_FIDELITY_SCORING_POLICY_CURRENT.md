# Manual visual fidelity scoring policy (current)

Human reviewers score **live SwiftUI on device** against mockup **intent** — not embedded PNGs.

## Scale

Each category scored **0–5** (13 categories → max 65, scaled to **0–100**):

| Category | Description |
|----------|-------------|
| Layout | Overall structure vs mockup intent |
| Spacing | Padding, card rhythm, safe areas |
| Typography | Hierarchy, weights, truncation |
| Color | Marine/cyan iOS; dark/neon Watch semantics |
| Iconography | SF Symbols vs mockup intent |
| State fidelity | Correct empty/filled/warning states |
| Information hierarchy | Safety > primary metric > secondary |
| Safety visibility | Disclaimers, warnings, reference-only posture |
| Accessibility | Labels, hints, focus order |
| Localization | EN/IT completeness on device |
| Motion/interaction | Transitions (if in scope) |
| Device fit | Smallest/largest phone or Watch |

## Pass threshold

- **≥ 80/100** per screen for manual pass
- Any **safety visibility ≤ 2** auto-fails regardless of total

## Evidence

`Docs/QA_EVIDENCE/MANUAL_VISUAL_FIDELITY/EVIDENCE_TEMPLATE.md`

**Status:** PENDING_MANUAL_VISUAL_QA until signed rows exist.

## Non-goals

- Mockup PNGs are not runtime assets
- Simulator snapshots are not manual fidelity evidence
