# DIR DIVING — TestFlight Shallow Depth Risk Assessment (Current)

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md` §2A.3  
**Date:** 2026-06-28  
**Branch:** `main`  
**Commit:** `5d757cc` (`5d757cc0217755f5c6d5429af2f13ce5c4748c5d`)  
**Pre-remediation baseline:** `7dfefe2`  
**Validation:** `validate_consolidated_software_readiness.sh` **PASS** @ 5d757cc

**Not claimed:** Full-depth entitlement validated, shallow wet QA passed, certified decompression on shallow builds, Apple system auto-launch listing verified, App Store approval.

---

## Executive summary

At `5d757cc`, shallow-depth signing remains default. **Production Full Computer is fail-closed** unless full-depth entitlement or developer shallow FC toggle (default OFF). Post-remediation: GF import parity closed (CONS-002), sync/depth/WAO software gates closed, remediation test gates PASS. **All shallow wet and system-listing evidence is PENDING_PHYSICAL.**

| Risk tier | Count | Release impact |
|-----------|------:|----------------|
| P0 (false claim / safety bypass) | **0** | None identified |
| P1 (internal TestFlight) | **2** | Shallow FC exposure labeling; metadata trust |
| P2 (external TestFlight) | **6** | Wet QA, system listing, WAO physical, hardware controls |
| P3 | **1** | Modal sequencing partial sim evidence |
| P4 | **4** | Documentation / positive controls |

**Internal TestFlight shallow-depth posture:** **READY (software)** — allowed with truthful TestFlight notes, developer toggles default OFF, no public marketing of shallow FC as certified guidance.

**External TestFlight / App Store:** **NOT READY** until physical shallow-depth and full-depth entitlement evidence exists.

---

## Capability posture @ 5d757cc

| Item | Software status | Physical status |
|------|-----------------|-----------------|
| Shallow-depth entitlement signed | **SOFTWARE_READY** | PENDING_PHYSICAL |
| Full-depth entitlement (alternate) | Documented archive path | PENDING_PHYSICAL |
| `WKSupportsAutomaticDepthLaunch` | **true** in Info.plist | System listing NOT_EXECUTED |
| Production FC without dev toggle | **Blocked** on shallow-only | N/A |
| Developer shallow toggles | **Default OFF**; TestFlight gated | PENDING_PHYSICAL |
| GF iOS→Watch import | **PASS** (CONS-002) | N/A |
| WAO depth capability gate | **PASS** (CONS-019) | WAO wet NOT_EXECUTED |

---

## Required TestFlight review notes (internal)

1. Experimental non-certified dive companion — not a certified decompression computer.
2. Default signing uses shallow-depth entitlement (~6 m operational cap).
3. Developer shallow Gauge/FC toggles are internal QA only; default OFF for TestFlight builds.
4. Physical depth sensor, CMAltimeter, and paired-device QA **not complete**.
5. External Bühlmann validation **not executed**.

---

## Physical gates still open

| Gate | Template | Status |
|------|----------|--------|
| Shallow wet Gauge | SDG-010 / PDQ-W-032 | NOT_EXECUTED |
| Shallow wet FC (internal) | SDG-011 / PDQ-W-033 | NOT_EXECUTED |
| System auto-launch listing | WAO-PHY-001 | NOT_EXECUTED |
| Water auto-open wet | WAO-PHY-002..003 | NOT_EXECUTED |
| Hardware controls wet | HWC-PHY-001..004 | NOT_EXECUTED |

---

*Post-remediation shallow-depth risk assessment @ 5d757cc. No physical evidence fabricated.*
