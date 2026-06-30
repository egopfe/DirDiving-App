# Master UI/UX Gap Remediation Plan — Current

**Audit date:** 2026-06-30  
**Baseline:** `main` @ `451f8fb`  
**Command:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.3.md` §47

---

## Overview

Software UI/UX at `451f8fb` has **zero open P0–P2 software defects** in audited scope. Remaining work is **evidence acquisition**, **physical QA**, and **polish (P3/P4)**. Do not implement fixes during audit — this plan records required follow-up only.

---

## P0 — Must Fix Before Any Safety-Critical Use

**None open.** Settings/Logbook activity isolation, FC UI truthfulness (software tests), reference-only planner/CCR copy, and mockup non-embedding verified.

---

## P1 — Must Fix Before Internal TestFlight (Evidence / Major UX)

| ID | Item | Root cause | Remediation | Acceptance | Physical QA |
|----|------|------------|-------------|------------|-------------|
| MUIUX-P1-001 | Water auto-open physical QA | No signed wet artifacts | Execute WAO-G-008..015 matrix on Ultra | Signed `QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_*` | Yes |
| MUIUX-P1-002 | Underwater Crown/AB QA | Software only | Water Lock + Crown clamp + AB shortcut tests | Signed underwater HW pack | Yes |
| MUIUX-P1-003 | Accessibility manual QA | Contracts only | Run ACCESSIBILITY_MANUAL_QA_TEMPLATE on device | VoiceOver notes per primary flow | Yes |
| MUIUX-P1-004 | Paired sync UI QA | No two-device run | Execute PAIRED_WATCH_IOS_UI_QA_TEMPLATE | Briefing + tombstone round-trip signed | Yes |
| MUIUX-P1-005 | Shallow wet QA | Dev toggles software OK | Execute shallow depth wet matrix | Shallow vs full separation signed | Yes |

**Rerun after remediation:** Audit 03 (this), Audit 05 release, Watch FC forensic if depth policy changes.

---

## P2 — Must Fix Before External TestFlight

| ID | Item | Remediation | Acceptance |
|----|------|-------------|------------|
| MUIUX-P2-001 | Pixel-diff baselines 0/59 | Run `capture_visual_regression_baselines.sh` on reference simulators | 59/59 baselines in repo or CI artifact |
| MUIUX-P2-002 | CCR external validation UX | Counsel/reference review (copy already reference-only) | Signed reference-only attestation |
| MUIUX-P2-003 | Snorkeling field GPS QA | Execute 12 SNORKELING_* QA folders | 12/12 PASS with device artifacts |
| MUIUX-P2-004 | Cold-launch submersion probe field | Ultra submerged cold launch with WAO enabled | Probe routes correctly or limitation confirmed |

---

## P3 — App Store Polish

| ID | Item | Remediation |
|----|------|-------------|
| MUIUX-P3-001 | iOS Diving settings dual binding | Unify MoreView through IOSDivingSettingsStore (CONS-040) |
| MUIUX-P3-002 | FC logbook environment provenance label | Pass frozen session environmentRecord (CONS-036) |

---

## P4 — Optional Enhancements

| ID | Item |
|----|------|
| MUIUX-P4-001 | Mission Mode discoverability on smallest Watch |
| MUIUX-P4-002 | Reminder suppression copy refinement |

---

## Batch Priority (What Must Be Fixed First)

1. **MUIUX-P1-002 + MUIUX-P1-001** — Underwater hardware + water auto-open physical (safety reachability)
2. **MUIUX-P1-005** — Shallow wet separation (regulatory/process)
3. **MUIUX-P1-003 + MUIUX-P1-004** — Accessibility + paired sync (TestFlight gates)
4. **MUIUX-P2-001** — Visual regression baselines (external TF polish)

---

## Full Computer Remediation Rule

Any change affecting Full Computer UI, GF presets, or depth capability must rerun:

- Watch Full Computer forensic audit (Audit 01/15)
- Master UI/UX audit (Audit 03)
