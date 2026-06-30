# DIR DIVING — Master App Store & TestFlight Blockers (Current)

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.2.md`  
**Date:** 2026-06-30  
**Branch:** `main` @ `451f8fb`  
**Upstream audits:** 01–04, 06 @ `451f8fb`

**Verdict:** **Internal TestFlight — CONDITIONAL (software).** **External TestFlight and App Store — BLOCKED (NOT READY).**

This document lists blockers only. It does **not** grant legal approval or certification.

---

## Blocker summary

| Category | Open blockers | Blocks internal TF | Blocks external TF | Blocks App Store |
|----------|--------------:|:------------------:|:------------------:|:----------------:|
| Software P1 (compile/script) | **2** | Yes | Yes | Yes |
| Software P1 (disclosure/metadata) | **2** | Disclosure | Partial | Yes |
| Snorkeling field QA (CONS-048) | **12** | Disclosure | Yes | Yes |
| Legal / marketing sign-off | **2** | No | Yes | Yes |
| Physical Watch (incl. shallow/wet/CMA) | **38** | Disclosure only | Yes | Yes |
| Physical iPhone / a11y | **16** | No | Partial | Yes |
| Paired-device sync | **8** | Partial | Yes | Yes |
| Water auto-open physical | **3** | No | Yes | Yes |
| Hardware controls physical | **4** | No | Yes | Yes |
| External algorithm validation | **4** | No | Yes | Yes |
| App Store marketing assets | **1** | No | No | Yes |
| **Total tracked** | **92** | — | — | — |

---

## P0 — Must not ship with false claims

**P0 blockers: NONE** — no fake physical/external PASS in MASTER docs; prohibited-claims posture intact @ 451f8fb.

---

## P1 — Internal TestFlight blockers (software)

| ID | Blocker | Status @ 451f8fb | Exit criteria |
|----|---------|------------------|---------------|
| IOS-P1-001 | iOS Algorithm Tests compile failure | **OPEN** | Snorkeling test compile fixed; full suite green |
| CONS-046 | Command integrity script drift | **OPEN** | `validate_commands_for_cursor_integrity.sh` PASS vs V2.2/V1.2 paths |
| MASB-SW-01 | GF iOS→Watch import mismatch | **CLOSED** | CONS-002 @ 451f8fb |
| MASB-SW-02..05 | Sync/ACK/tombstone/WAO gates | **CLOSED** | CONS-003..005, CONS-019 |
| SDG-008 | Shallow FC TestFlight exposure labeling | **OPEN** | TF review notes + developer toggle disclosure |
| MASTER-DEPTH-002 | Depth tier metadata runtime trust | **OPEN** | SecTask runtime verify CI check |
| CONS-048 | Snorkeling 12 QA templates | **OPEN** | 12/12 signed field artifacts |

---

## P1 — Physical / external (NOT EXECUTED)

All rows in `MASTER_PHYSICAL_DEVICE_QA_MATRIX`, `MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE`, `MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE`, and external validation templates remain **PENDING**. Do not mark PASS without signed device artifacts.

---

## External TestFlight blockers

- 0% physical QA (Watch, iPhone, paired, underwater)  
- 0% external Bühlmann/Schreiner/Subsurface/CCR validation  
- 12/12 Snorkeling field templates open (CONS-048)  
- IOS-P1-001 unresolved  
- Legal/marketing sign-off pending  

---

## App Store blockers

All external TF blockers plus:

- ASC metadata and screenshots incomplete  
- Full-depth entitlement not field-validated  
- Accessibility manual QA not executed  
- Incident/rollback drill not executed  

---

**Status:** OPEN @ `451f8fb` · 2026-06-30
