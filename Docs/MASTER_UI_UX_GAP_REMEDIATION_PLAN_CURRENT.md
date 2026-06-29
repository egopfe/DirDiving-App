# Master UI/UX Gap Remediation Plan — Current

**Audit:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.2.md`  
**Date:** 2026-06-29  
**Commit:** `15c8068` on `main`

---

## Status summary

All **software-actionable** P0–P3 findings from the V2.2 UI/UX audit are **closed** at `15c8068`, including consolidated remediation items **CONS-019**, **CONS-006/007**, and **CONS-002** verified @ `5d757cc`. Remaining work is **physical QA, paired-device QA, manual accessibility, pixel-diff execution, PDF render validation, and external validation** — tracked as evidence gates, not code defects.

---

## Closed software remediations (verified @ `15c8068`)

| ID | Remediation | Evidence |
|----|-------------|----------|
| **CONS-019** | Depth gate on WAO/FC `resolveAutomaticStep` | `DIRStartupSelectionPolicy.swift` L99–107; WAO-018 |
| **CONS-006** | Shallow dev toggles default OFF | `DeveloperSettings.resolvedShallowTestingFlag` |
| **CONS-007** | Compile-time depth entitlement authority | `DepthCapabilityEntitlementProbe.runtimeAuthorityTier` |
| **CONS-002** | GF preset iOS↔Watch parity | `DivePlanPackageBuilder.gradientFactorPreset`; GF interop matrix |
| P1-WAO-001 | Cold launch submersion probe + routing | `WatchSubmersionLaunchProbe`, `WatchLaunchRoutingPolicy` |
| P1-WAO-002 | Cold-launch limitation Settings copy | `settings.water_auto_open.cold_launch_limitation` EN/IT |
| P1-AB-001 | Legacy intent session safety | `WatchIntentSafetyPolicy` |
| P2-UX-001..003 | Underwater help + toast copy | Localizable.strings, `SettingsView` |
| P2-TEST-001..003 | Water/clamp test debt | Watch algorithm tests |

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
| CONS-043 | GF preset external Bühlmann spot-check | `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL` |

---

## P4 — Optional polish

| ID | Work |
|----|------|
| MUIUX-P4-001 | Mission Mode discoverability |
| MUIUX-P4-002 | Reminder suppression copy |

---

## Execution order

1. Physical Watch underwater packs (Water Lock, Action Button, WAO end-to-end) — **CONS-021/022**
2. Paired sync UI QA — **CONS-011**
3. Manual accessibility — **CONS-012**
4. Pixel-diff baselines — **CONS-032**
5. PDF render QA — **CONS-013**
6. External validation templates — **CONS-009/043**

---

## Rerun triggers

Any change to Full Computer runtime, water auto-open routing, Crown/Action Button policy, or GF import contract requires rerun of:

- Watch Full Computer forensic audit (01)
- This master UI/UX audit (03)

**No code changes in this audit rerun.**
