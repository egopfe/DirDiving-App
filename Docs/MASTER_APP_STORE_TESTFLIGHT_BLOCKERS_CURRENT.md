# DIR DIVING — Master App Store & TestFlight Blockers (Current)

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md`  
**Date:** 2026-06-28  
**Branch:** `main` @ `5d757cc`  
**Pre-remediation baseline:** `7dfefe2`  
**Validation:** `validate_consolidated_software_readiness.sh` **PASS**

**Verdict:** **Internal TestFlight — READY (software).** **External TestFlight and App Store — BLOCKED (NOT READY).**

This document lists blockers only. It does **not** grant legal approval or certification.

---

## Blocker summary

| Category | Open blockers | Blocks internal TF | Blocks external TF | Blocks App Store |
|----------|--------------:|:------------------:|:------------------:|:----------------:|
| Software P1 (disclosure/metadata) | **2** | Disclosure | Partial | Yes |
| Legal / marketing sign-off | **2** | No | Yes | Yes |
| Physical Watch (incl. shallow/wet/CMA) | **38** | Disclosure only | Yes | Yes |
| Physical iPhone / a11y | **16** | No | Partial | Yes |
| Paired-device sync | **8** | Partial | Yes | Yes |
| Water auto-open physical | **3** | No | Yes | Yes |
| Hardware controls physical | **4** | No | Yes | Yes |
| External algorithm validation | **4** | No | Yes | Yes |
| App Store marketing assets | **1** | No | No | Yes |
| **Total tracked** | **78** | — | — | — |

**Closed since 7dfefe2:** GF import (MASB-SW-01), sync in-flight (MASB-SW-02), ACK asymmetry (MASB-SW-03), tombstones (MASB-SW-04), WAO depth gate (MASB-SW-05), Watch test drift (MASB-SW-06/07).

---

## P0 — Must not ship with false claims

**P0 blockers: NONE** — prohibited-claims scan PASS; no fake physical/external PASS in MASTER docs.

---

## P1 — Internal TestFlight blockers (software)

| ID | Blocker | Status @ 5d757cc | Exit criteria |
|----|---------|------------------|---------------|
| MASB-SW-01 | GF iOS→Watch import mismatch | **CLOSED** | CONS-002; DivePlanPackageBuilderTests PASS |
| MASB-SW-02 | Sync in-flight stuck | **CLOSED** | CONS-003 |
| MASB-SW-03 | Asymmetric dive import ACK | **CLOSED** | CONS-004 |
| MASB-SW-04 | Legacy unsigned tombstones | **CLOSED** | CONS-005 |
| MASB-SW-05 | WAO depth capability gate | **CLOSED** | CONS-019 |
| MASB-SW-06/07 | Watch startup/import test drift | **CLOSED** | CONS-017/018/038 |
| SDG-008 | Shallow FC TestFlight exposure labeling | **OPEN** | TF review notes + developer toggle disclosure |
| MASTER-DEPTH-002 | Depth tier metadata runtime trust | **OPEN** | SecTask runtime verify CI check |

---

## P1 — Physical / external (unchanged — NOT EXECUTED)

All rows in `MASTER_PHYSICAL_DEVICE_QA_MATRIX`, `MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE`, `MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE`, and external validation templates remain **PENDING**. Do not mark PASS without signed device artifacts.

---

## Internal TestFlight release notes (required disclosure)

- Non-certified experimental dive companion; not EN13319/ISO 6425 certified.
- Shallow-depth signing (~6 m cap) when using default entitlement profile.
- Developer shallow Gauge/FC toggles are internal QA only (default OFF).
- Physical QA and external Bühlmann validation **not complete**.

---

*Post-remediation blocker refresh @ 5d757cc. Software P1 cluster closed; physical/external/legal blockers unchanged.*
