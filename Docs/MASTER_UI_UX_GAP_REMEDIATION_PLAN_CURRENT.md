# Master UI/UX Gap Remediation Plan — Current

**Audit:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.1.md`  
**Date:** 2026-06-28  
**Commit:** `7dfefe2` on `main`

---

## Status summary

All **software-actionable** P0–P3 findings from the V2.1 UI/UX audit are **closed** at `7dfefe2`. Remaining work is **physical QA, paired-device QA, manual accessibility, pixel-diff execution, PDF render validation, and external validation** — tracked as evidence gates, not code defects.

---

## Closed software remediations (verified @ 7dfefe2)

| ID | Remediation | Evidence |
|----|-------------|----------|
| P1-WAO-001 | Cold launch submersion probe + routing | `WatchSubmersionLaunchProbe`, `WatchLaunchRoutingPolicy`, `ContentView` |
| P1-WAO-002 | Cold-launch limitation Settings copy | `settings.water_auto_open.cold_launch_limitation` EN/IT |
| P1-AB-001 | Legacy intent session safety | `WatchIntentSafetyPolicy` |
| P2-UX-001..003 | Underwater help + toast copy | Localizable.strings, `SettingsView` |
| P2-TEST-001..003 | Water/clamp test debt | Watch algorithm tests |
| MUIUX-P3-001..004 | iOS Settings polish | Remediation batch |

---

## P1 — Execute before external TestFlight (physical / evidence)

| ID | Work | Acceptance | Physical QA |
|----|------|------------|-------------|
| MUIUX-P1-001 | Apnea/Snorkeling physical underwater sessions | Fill `Docs/QA_EVIDENCE/WATCH_UNDERWATER_*` | Required |
| MUIUX-P1-002 | Paired Watch↔iOS sync UI | Fill `PAIRED_WATCH_IOS_UI_QA_TEMPLATE` | Paired devices |
| MUIUX-P1-003 | Manual VoiceOver on critical flows | Fill `ACCESSIBILITY_MANUAL_QA_TEMPLATE` | Device |
| MUIUX-P1-004 | Planner/Checklist PDF render on device | Fill `PDF_PHYSICAL_RENDER_QA_TEMPLATE` | Device |
| MVR-P1-002 | Execute pixel-diff capture 59 mockups | `Scripts/capture_visual_regression_baselines.sh` | Device/simulator |

---

## P2 — Before App Store (external / extended physical)

| ID | Work | Acceptance |
|----|------|------------|
| MUIUX-P2-001 | CCR external validation disclosure review | Evidence plan executed |
| MUIUX-P2-002 | Watch FC pixel baselines on device | Physical pixel pack |
| MVR-P2-002 | Manual visual fidelity scoring | Template completed |
| MVR-P2-004 | 41 mm Watch layout physical QA | Smallest device pack |

---

## P4 — Optional polish

| ID | Work |
|----|------|
| MUIUX-P4-001 | Mission Mode discoverability |
| MUIUX-P4-002 | Reminder suppression copy |

---

## Execution order

1. **Water auto-open physical pack** — `WATCH_WATER_AUTO_OPEN_*` + system listing evidence  
2. **Underwater hardware pack** — Water Lock, Action Button, crown paging  
3. **Paired sync UI QA**  
4. **Accessibility manual QA**  
5. **Pixel-diff + PDF render**  
6. **External validation (CCR / FC)**  

Any remediation affecting Full Computer must rerun Watch Full Computer forensic audit and this UI/UX audit.

---

## Rerun triggers

| Change | Rerun |
|--------|-------|
| Full Computer UI/deco presentation | Watch FC forensic + UI/UX audit |
| Water auto-open routing | Water auto-open audit + UI/UX §30 |
| Crown/Action Button policy | Underwater hardware audit |
