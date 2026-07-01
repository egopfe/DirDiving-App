# Master UI/UX Gap Remediation Plan — CURRENT

**Audit date:** 2026-07-01  
**Baseline:** `main` @ `2c30412`  
**Command:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.5.md` §47

---

## Overview

Software UI/UX at `2c30412` has **zero open P0 software defects**. **Five P2 software gaps** (WAO test alignment, Apnea UI, surface page policy, GF labels) plus **five P1 evidence/physical gates** remain. Do not implement fixes during audit — this plan records required follow-up only.

---

## P0 — Must Fix Before Any Safety-Critical Use

**None open.** Settings/Logbook activity isolation, FC UI truthfulness (Audit 01: 0 P0 FC), reference-only planner/CCR copy, and mockup non-embedding verified.

---

## P1 — Must Fix Before Internal TestFlight (Evidence / Major UX)

| ID | Item | Root cause | Remediation | Acceptance | Physical QA |
|----|------|------------|-------------|------------|-------------|
| MUIUX-P1-001 | Water auto-open physical QA | No signed wet artifacts | Execute WAO-G-008..015 matrix on Ultra | Signed `QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_*` | Yes |
| MUIUX-P1-002 | Underwater Crown/AB QA | Software only | Water Lock + Crown clamp + AB shortcut tests | Signed underwater HW pack | Yes |
| MUIUX-P1-003 | Accessibility manual QA | Contracts only | Run ACCESSIBILITY_MANUAL_QA_TEMPLATE on device | VoiceOver notes per primary flow | Yes |
| MUIUX-P1-004 | Paired sync UI QA | No two-device run | Execute PAIRED_WATCH_IOS_UI_QA_TEMPLATE | Briefing + tombstone round-trip signed | Yes |
| MUIUX-P1-005 | Shallow wet QA | Dev toggles software OK | Execute shallow depth wet matrix | Shallow vs full separation signed | Yes |

---

## P2 — Must Fix Before External TestFlight

| ID | Item | Remediation | Acceptance |
|----|------|-------------|------------|
| MUIUX-P2-001 | Pixel-diff baselines 0/59 | Run `capture_visual_regression_baselines.sh` on reference simulators | 59/59 baselines in repo or CI artifact |
| MUIUX-P2-002 | CCR external validation UX | Counsel/reference review (copy already reference-only) | Signed reference-only attestation |
| MUIUX-P2-003 | Snorkeling field GPS QA | Execute 12 SNORKELING_* QA folders | 12/12 PASS with device artifacts |
| MUIUX-P2-004 | Cold-launch submersion probe field | Ultra submerged cold launch with WAO enabled | Probe routes correctly or limitation confirmed |
| MUIUX-P2-005 | WAO routing test drift post-Apnea | Align `WatchWaterAutoOpenPolicyTests` expectations with `divingModeSelection` step OR document intentional intermediate step in UX | 1152/1152 Watch tests green; WFC-P2-005 closed |
| MUIUX-P2-006 | Apnea Watch title localization | Replace hardcoded `"Apnea"` in `ApneaView` with localized key | EN/IT VoiceOver reads localized title |
| MUIUX-P2-007 | Apnea alarms/markers editor | Add alarms/markers UI to `IOSApneaProfileEditorView` or update mockup matrix | Profile editor matches model + mockups |
| MUIUX-P2-008 | Non-diving surface page inventory | Restrict Compass/User Images tabs for Apnea/Snorkeling on surface OR document intentional parity | Activity page policy matches product intent |
| MUIUX-P2-009 | GF preset label parity | Align iOS Aggressive vs Watch Moderate label (40/85 preset) | Consistent EN/IT across platforms |

**Rerun after P2-005 if routing changes:** Audit 03, Audit 01 FC if depth policy touched.

---

## P3 — App Store Polish

| ID | Item | Remediation |
|----|------|-------------|
| MUIUX-P3-001 | iOS Diving settings dual binding | Unify MoreView through IOSDivingSettingsStore (CONS-040) |
| MUIUX-P3-002 | FC logbook environment provenance label | Pass frozen session environmentRecord (CONS-036) |
| MUIUX-P3-003 | Diving gear vs Apnea/Snorkeling settings asymmetry | Document intentional (Diving uses More tab) |
| MUIUX-P3-004 | Shared settings layout variance | Future polish across activity settings footers |
| MUIUX-P3-005 | Apnea iCloud backup stub | Full backup feature or keep honest disclosure |

---

## P4 — Optional Enhancements

| ID | Item |
|----|------|
| MUIUX-P4-001 | Mission Mode discoverability on smallest Watch |
| MUIUX-P4-002 | Reminder suppression copy refinement |

---

## Batch Priority (What Must Be Fixed First)

1. **MUIUX-P2-005 / WFC-P2-005** — WAO test alignment (orchestrator gate for Watch test green)
2. **MUIUX-P1-002 + MUIUX-P1-001** — Underwater hardware + water auto-open physical
3. **MUIUX-P1-005** — Shallow wet separation
4. **MUIUX-P1-003 + MUIUX-P1-004** — Accessibility + paired sync
5. **MUIUX-P2-006..009** — Software P2 before external TestFlight

---

## Full Computer Remediation Rule

Any change affecting Full Computer UI, GF presets, or depth capability must rerun Audit 01 and Audit 03.
