# DIR DIVING — Master External Validation Gaps (Current)

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.2.md`  
**Date:** 2026-06-30  
**Branch:** `main` @ `451f8fb`  
**Upstream audits:** 01–04, 06 @ `451f8fb`

**Policy:** External validation and physical QA remain **NOT PASSED** until signed artifacts exist in `Docs/QA_EVIDENCE/`. Simulator and automated tests do **not** close these gaps. **Do not upgrade simulator evidence to physical validation.**

---

## Gap summary

| Category | Open gaps | Software substitute allowed? |
|----------|----------:|------------------------------|
| Physical Watch (incl. CMAltimeter + shallow/wet) | **38** | **No** |
| Physical iPhone | **16** | **No** |
| Paired-device | **8** | **No** |
| Underwater / entitlement depth | **1** | **No** |
| Water auto-open physical | **3** | **No** |
| Hardware controls physical | **4** | **No** |
| Snorkeling field QA (CONS-048) | **12** | **No** |
| External algorithm reference | **4** | **No** |
| App Store / legal / marketing | **2** | **No** |
| iOS test compile (IOS-P1-001) | **1** | **No** — blocks automated regression |
| Command integrity (CONS-046) | **1** | **No** — blocks audit preflight |
| **Total NOT PASSED** | **90** | — |

**SOFTWARE_READY @ 451f8fb:** Watch **353/355** tests PASS (audit 01); iOS full suite **BUILD FAILED** (IOS-P1-001). Internal oracle and engine tests SOFTWARE_READY where executed.

---

## Bühlmann external validation

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-BM-01 | Third-party golden profile comparison vs independent oracle | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | External TF / marketing |
| MEXT-BM-02 | Repetitive-dive reference cases cross-checked externally | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Planner trust |
| MEXT-BM-03 | Multilevel decompression reference cases | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Full Computer positioning |

**Software status:** Audit-15 multilevel oracle, Bühlmann engine tests, GF preset runtime **SOFTWARE_READY**. **External campaign NOT EXECUTED.**

---

## Schreiner external validation

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-SCHR-01 | Schreiner analytic parity external golden set | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Bundled with Bühlmann |
| MEXT-SCHR-02 | Schreiner multilevel segment validation | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | FC marketing |

**Software status:** `SchreinerAnalyticParityTests`, `BuhlmannSchreinerEquationTests` **PASS**. **PENDING_EXTERNAL_VALIDATION.**

---

## Subsurface comparison

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-SS-01 | CSV export opened/imported in Subsurface externally | `QA_EVIDENCE/SUBSURFACE_EXTERNAL/` | Import compatibility claim |
| MEXT-SS-02 | Round-trip metadata preservation | `QA_EVIDENCE/SUBSURFACE_CSV/` | Export UX |

**Software status:** CSV metadata round-trip unit tests **PASS** where iOS target compiles. **External tool NOT EXECUTED.**

---

## CCR external validation

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-CCR-01 | Rebreather bailout heuristic external review | `QA_EVIDENCE/CCR_EXTERNAL/` | CCR marketing |
| MEXT-CCR-02 | Loop PPO₂ reference-only posture field review | `QA_EVIDENCE/CCR_EXTERNAL/` | Safety copy |

**Software status:** `CCRMathRemediationTests` **PASS**; reference-only posture documented. **External campaign PENDING.**

---

## Ratio Deco / Rock Bottom / Gas Ledger

| Gap ID | Description | Status |
|--------|-------------|--------|
| MEXT-RD-01 | External ratio deco reference cases | Optional / PENDING |
| MEXT-RB-01 | Rock Bottom external reference | Internal estimate tests PASS |
| MEXT-GL-01 | Gas ledger bar estimate external reference | Internal formatter tests PASS |

---

## Snorkeling field QA (CONS-048)

12 templates under `Docs/QA_EVIDENCE/SNORKELING_*` — all **PENDING_PHYSICAL**:

1. SNORKELING_IOS_ROUTE_SAFETY_CHECK  
2. SNORKELING_IOS_ROUTE_TYPE_ROUND_TRIP  
3. SNORKELING_IOS_ROUTE_DISTANCE_DURATION  
4. SNORKELING_IOS_SEND_TO_WATCH_VALIDATION  
5. SNORKELING_LOGBOOK_GPS_QUALITY  
6. SNORKELING_NO_CROSS_ACTIVITY_REGRESSION  
7. SNORKELING_WATCH_GPS_QUALITY  
8. SNORKELING_WATCH_IMPORTED_ROUTE  
9. SNORKELING_WATCH_NEXT_WAYPOINT  
10. SNORKELING_WATCH_OFF_ROUTE_WARNING  
11. SNORKELING_WATCH_RETURN_ALERT  
12. SNORKELING_WATCH_RETURN_TO_ENTRY_DISTANCE  

**Do not claim Snorkeling navigation verified on hardware.**

---

## Software regression gaps (@ 451f8fb)

| Gap ID | Description | Severity |
|--------|-------------|----------|
| IOS-P1-001 | iOS Algorithm Tests compile failure (Snorkeling) | P1 |
| CONS-046 | `validate_commands_for_cursor_integrity.sh` FAIL | P1 |

---

## Remediation priority

1. Fix IOS-P1-001 test compile  
2. Fix CONS-046 script paths  
3. Execute Snorkeling Batch-8 (12 templates)  
4. Execute legacy physical campaigns (Watch Ultra, CMAltimeter, WAO, HW)  
5. Execute external Bühlmann/Subsurface/CCR campaigns  
6. Legal counsel + ASC metadata review  

---

**Status:** OPEN @ `451f8fb` · 2026-06-30
