# DIR DIVING iOS Physical Accessibility QA

**Date:** 2026-05-29  
**Scope:** iOS Companion MAIN — Planner and Plan Result surfaces  
**Status:** Checklist ready — manual device QA required  
**Related tests:** `BuhlmannUxReadinessTests`, `BuhlmannComprehensiveReadinessFixTests`

---

## Objective

Verify that Bühlmann planner safety messaging, repetitive planning states, warnings, and critical actions remain usable on physical iOS hardware with assistive technologies and constrained layouts.

This is **manual QA** — automated XCTest covers copy presence, not layout or VoiceOver traversal on device.

---

## Test Environment

| Item | Value |
|---|---|
| Devices | ☐ iPhone SE (small) ☐ iPhone standard ☐ iPhone Pro Max |
| iOS version | ☐ |
| VoiceOver | ☐ On ☐ Off per test |
| Dynamic Type | ☐ Default ☐ AX1 ☐ AX5 (largest) |
| Dark mode | ☐ (app is dark-first) |

---

## VoiceOver Checklist

| ID | Area | Expected | Pass? |
|---|---|---|---|
| V1 | Planner safety acknowledgment toggle | Label + hint; cannot calculate without ack | ☐ |
| V2 | Calculate Plan button | Announces disabled state when MOD blocks or ack missing | ☐ |
| V3 | Repetitive planning toggle | Hint explains reference-only tissue seed | ☐ |
| V4 | Snapshot status | Reads source “prior calculated reference plan (not dive log)” | ☐ |
| V5 | Blocking warning boxes | Combined label includes title + corrective hint | ☐ |
| V6 | Result header badge | No-deco / deco-required / repetitive badge readable | ☐ |
| V7 | Gas ledger rows | Per-cylinder consumption announced | ☐ |
| V8 | GF comparison rows | TTS and stop count per preset | ☐ |
| V9 | Bailout hint | Emergency-only schedule disclaimer announced when bailout configured | ☐ |
| V10 | Share plan action | Export accessibility label present | ☐ |

---

## Dynamic Type Checklist

| ID | Area | Expected | Pass? |
|---|---|---|---|
| D1 | Planner input cards | No clipped safety copy at AX3+ | ☐ |
| D2 | Large warning sections | Scrollable; critical text not truncated without scroll | ☐ |
| D3 | Result tabs | Tab labels remain tappable at largest sizes | ☐ |
| D4 | Ascent table | Row content readable; horizontal scroll acceptable | ☐ |
| D5 | CNS/OTU disclaimer | Reference-only copy visible with metric values | ☐ |

---

## Small-Screen Layout

| ID | Area | Expected | Pass? |
|---|---|---|---|
| S1 | Calculate button | Visible without excessive scroll from profile section | ☐ |
| S2 | Repetitive card | Surface interval field usable on SE width | ☐ |
| S3 | Plan result warnings | Blocking warnings visible above fold or with obvious scroll affordance | ☐ |
| S4 | GF comparison card | Readable on Charts tab without overlap | ☐ |

---

## Critical Action Visibility

| ID | Action | Expected | Pass? |
|---|---|---|---|
| C1 | Safety ack | Required before calculate | ☐ |
| C2 | Invalid environment | Blocks plan with `.invalidEnvironment` copy | ☐ |
| C3 | MOD exceeded | Blocks calculate with explicit message | ☐ |
| C4 | Snapshot missing (repetitive) | Fail-closed; no silent clean-dive assumption | ☐ |
| C5 | Surface interval rejected | Typed `.surfaceIntervalRejected` with corrective hint | ☐ |
| C6 | Calculation progress | Progress indicator on Calculate when synchronous work runs | ☐ |

---

## Known Limitations (documented, not QA failures)

- Dense planner cards may require additional scrolling at AX5 — acceptable if all safety text remains reachable.
- GF comparison runs four engine plans; caching reduces repeat cost but first open may brief stall on low-end devices.
- No haptic-specific planner feedback.

---

## Sign-off

| Tester | Device | Date | Overall |
|---|---|---|---|
| ☐ | ☐ | ☐ | ☐ Pass / ☐ Fail with notes |

**Physical accessibility QA is a P2 manual blocker for App Store readiness, not for internal algorithm validation.**
