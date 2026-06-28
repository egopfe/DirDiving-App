# DIR DIVING — Master External Validation Gaps (Current)

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md`  
**Date:** 2026-06-28  
**Branch:** `main` @ `7dfefe2`  
**Merged sources:** Commands 12 + 13; upstream audits 01–04 @ `7dfefe2`

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
| External algorithm reference | **4** | **No** |
| App Store / legal / marketing | **2** | **No** |
| **Total NOT PASSED** | **76** | — |

**SOFTWARE_READY @ 7dfefe2:** iOS **1526/1526** tests PASS; Watch **1089/1091** PASS (2 test-case failures — test maintenance, not algorithm safety). Audit-15 oracle suites PASS. Internal fixtures and validation scripts PASS.

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

**Software status:** CSV metadata round-trip unit tests **PASS**. **External tool NOT EXECUTED.**

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
| MEXT-RB-01 | Rock Bottom estimate external review | Software PASS; external optional |
| MEXT-GL-01 | Gas ledger bar estimate external review | Software PASS; external optional |

---

## Physical QA gaps (June 2026 scope)

| Gap ID | Gate | Status |
|--------|------|--------|
| MEXT-PHY-SHALLOW-01 | Shallow wet Gauge (SDG-010) | PENDING_PHYSICAL |
| MEXT-PHY-SHALLOW-02 | Developer shallow FC wet (SDG-011) | PENDING_PHYSICAL |
| MEXT-PHY-WAO-01 | End-to-end water auto-open (WAO-PHY-001) | PENDING_PHYSICAL |
| MEXT-PHY-WAO-02 | System Auto-Launch listing (WAO-PHY-002) | PENDING_PHYSICAL |
| MEXT-PHY-HW-01 | Water Lock physical (HWC-PHY-004) | PENDING_PHYSICAL |
| MEXT-PHY-HW-02 | Action Button underwater (HWC-PHY-003) | PENDING_PHYSICAL |
| MEXT-PHY-HW-03 | Crown paging underwater (HWC-PHY-002) | PENDING_PHYSICAL |
| MEXT-PHY-CMA-01 | CMAltimeter CoreMotion samples | PENDING_PHYSICAL |

See: `MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv`, `MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE_CURRENT.csv`, `MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE_CURRENT.csv`.

---

## Legal / App Store / accessibility

| Gap ID | Description | Status |
|--------|-------------|--------|
| MEXT-LEGAL-01 | External legal counsel sign-off | PENDING_LEGAL_REVIEW |
| MEXT-ASC-01 | App Store screenshots + marketing pack | PENDING |
| MEXT-A11Y-01 | Manual VoiceOver + Dynamic Type QA | PENDING_PHYSICAL |
| MEXT-INC-01 | Incident/rollback drill execution | PENDING |

---

## Remediation priority

1. **P0:** Maintain zero false physical/external/certification claims (current posture **CLEAR**).
2. **P1 (software):** Fix IOS-MASTER-F016 GF preset mismatch; address MAIN sync P1 findings before internal TF confidence.
3. **P1 (evidence):** CMAltimeter physical gate + paired sync smoke.
4. **P2:** Execute full physical matrices; external Bühlmann/Schreiner/CCR campaigns; shallow wet QA.
5. **P3:** Legal counsel, accessibility manual QA, App Store assets.

**Do not mark any physical or external gap closed without signed artifacts in `Docs/QA_EVIDENCE/`.**
