# DIR DIVING — TestFlight Shallow Depth Risk Assessment (Current)

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.2.md` §2A.3  
**Date:** 2026-06-30  
**Branch:** `main`  
**Commit:** `451f8fb`  
**Upstream audits:** 01–04, 06 @ `451f8fb`

**Not claimed:** Full-depth entitlement validated, shallow wet QA passed, certified decompression on shallow builds, Apple system auto-launch listing verified, App Store approval.

---

## Executive summary

At `451f8fb`, shallow-depth signing remains default. **Production Full Computer is fail-closed** unless full-depth entitlement or developer shallow FC toggle (default OFF). Post-remediation: GF import parity closed (CONS-002), sync/depth/WAO software gates closed. **All shallow wet and system-listing evidence is PENDING_PHYSICAL.** **New regressions:** IOS-P1-001 (iOS test compile), CONS-046 (integrity script FAIL).

| Risk tier | Count | Release impact |
|-----------|------:|----------------|
| P0 (false claim / safety bypass) | **0** | None identified |
| P1 (internal TestFlight) | **4** | IOS-P1-001, CONS-046, shallow FC exposure labeling, metadata trust |
| P2 (external TestFlight) | **6** | Wet QA, system listing, WAO physical, hardware controls, Snorkeling field |
| P3 | **1** | Modal sequencing partial sim evidence |
| P4 | **4** | Documentation / positive controls |

**Internal TestFlight shallow-depth posture:** **CONDITIONAL** — allowed with truthful TestFlight notes, developer toggles default OFF, fix IOS-P1-001, no public marketing of shallow FC as certified guidance.

**External TestFlight / App Store:** **NOT READY** until physical shallow-depth and full-depth entitlement evidence exists.

---

## Capability posture @ 451f8fb

| Item | Software status | Physical status |
|------|-----------------|-----------------|
| Shallow-depth entitlement signed | **SOFTWARE_READY** | PENDING_PHYSICAL |
| Full-depth entitlement (alternate) | Documented archive path | PENDING_PHYSICAL |
| `WKSupportsAutomaticDepthLaunch` | **true** in Info.plist | System listing NOT_EXECUTED |
| Production FC without dev toggle | **Blocked** on shallow-only | N/A |
| Developer shallow toggles | **Default OFF**; TestFlight gated | PENDING_PHYSICAL |
| Developer shallow hidden from App Store | **PASS** (software) | N/A |
| No certified-deco shallow claim in copy | **PASS** | N/A |
| Shallow wet Gauge QA | NOT_EXECUTED | PENDING (SDG-010) |
| Shallow wet FC internal QA | NOT_EXECUTED | PENDING (SDG-011) |
| WAO respects depth capability | **PASS** (CONS-019) | PENDING_PHYSICAL |

---

## TestFlight disclosure requirements

Internal TestFlight review notes must include:

- Shallow-depth ~6 m limitation on default signing  
- Full Computer is experimental / non-certified  
- Developer shallow toggles are internal QA only  
- Physical validation pending for depth sensor, CMAltimeter, WAO, hardware controls  
- Snorkeling navigation not field-verified (CONS-048)  

---

## Risk matrix reference

- [`MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv`](MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv)  
- [`MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE_CURRENT.csv`](MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE_CURRENT.csv)  
- [`MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE_CURRENT.csv`](MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE_CURRENT.csv)  

---

**Status:** OPEN @ `451f8fb` · 2026-06-30
