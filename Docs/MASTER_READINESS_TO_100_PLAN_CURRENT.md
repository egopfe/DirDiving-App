# DIR DIVING — Master Readiness to 100% Plan (Current)

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md`  
**Date:** 2026-06-28  
**Branch:** `main` @ `7dfefe2`  
**Current overall release readiness:** **71%**  
**Target:** **100% evidence + compliance readiness** (physical, external, legal, ASC)

---

## Readiness layers

| Layer | Current | Target | Gap | Status class |
|-------|--------:|-------:|----:|--------------|
| Automated unit/integration | **99%** | 100% | 1% | SOFTWARE_READY |
| Simulator validation scripts | **100%** | 100% | 0% | SOFTWARE_READY |
| Claims / legal software posture | **100%** | 100% | 0% | SOFTWARE_READY |
| Privacy manifest / engineering disclosure | **100%** | 100% | 0% | SOFTWARE_READY |
| Shallow depth software gate | **100%** | 100% | 0% | SOFTWARE_READY |
| Water auto-open software gate | **100%** | 100% | 0% | SOFTWARE_READY |
| Hardware controls software gate | **100%** | 100% | 0% | SOFTWARE_READY |
| GF preset software gate | **93%** | 100% | 7% | SOFTWARE_GAP (F016) |
| Physical Watch evidence | **0%** | 100% | 100% | PENDING_PHYSICAL |
| Physical iPhone evidence | **0%** | 100% | 100% | PENDING_PHYSICAL |
| Paired-device evidence | **0%** | 100% | 100% | PENDING_PHYSICAL |
| CMAltimeter physical gate | **0%** | 100% | 100% | PENDING_PHYSICAL |
| Shallow wet / WAO / HW physical | **0%** | 100% | 100% | PENDING_PHYSICAL |
| External reference validation | **0%** | 100% | 100% | PENDING_EXTERNAL_VALIDATION |
| App Store / legal sign-off | **35%** | 100% | 65% | PENDING_LEGAL_REVIEW |

Software-only readiness is **~99%** on `7dfefe2` (1526 iOS PASS; 1089/1091 Watch PASS). Path to **100% overall** is dominated by **field evidence packs, June 2026 shallow/WAO/HW gates, and external/legal gates** — not new unit tests alone.

---

## P0 — Before any safety-critical TestFlight (must be zero)

| ID | Work item | Status @ 7dfefe2 | Action |
|----|-----------|------------------|--------|
| P0-01 | Unsupported certification claims in copy | **CLEAR** | Maintain prohibited-claims scan in CI |
| P0-02 | Missing legal onboarding gate | **PASS** | Keep LegalAcceptanceGateTests green |
| P0-03 | Missing privacy manifest | **PASS** | Keep PrivacyInfo Watch + iOS wired |
| P0-04 | Safety-critical path with zero automated test | **PASS** | 79-row traceability matrix; software PASS |
| P0-05 | Missing entitlement for required feature | **PASS** | Shallow depth + iCloud configured |
| P0-06 | False physical/external QA claim | **CLEAR** | All matrices PENDING until artifacts |

**P0 open items: 0**

---

## P1 — Before internal TestFlight (CONDITIONAL met with disclosure)

| ID | Work item | Status | Action |
|----|-----------|--------|--------|
| P1-01 | Full automated test suites green | **CONDITIONAL** | iOS 1526/1526 PASS; Watch 1089/1091 (2 failures) |
| P1-02 | Fix GF iOS→Watch preset mismatch | **OPEN** | IOS-MASTER-F016 remediation |
| P1-03 | MAIN sync P1 findings | **OPEN** | in-flight stuck, ACK asymmetry, tombstones |
| P1-04 | Shallow FC TF labeling | **OPEN** | SDG-008 disclosure in TF notes |
| P1-05 | Depth tier metadata CI check | **OPEN** | MASTER-DEPTH-002 |
| P1-06 | Basic physical install smoke | **PENDING_PHYSICAL** | Ultra + iPhone install log |
| P1-07 | Paired sync smoke | **PENDING_PHYSICAL** | One row of WATCH_IOS_SYNC matrix |
| P1-08 | Watch FC CMAltimeter software path | **PASS** | WatchCMAltimeterRemediationTests |
| P1-09 | TestFlight metadata wording | **PASS** | TESTFLIGHT_REVIEW_NOTES.md + shallow addendum |

---

## P2 — Before external TestFlight

| ID | Work item | Status | Action |
|----|-----------|--------|--------|
| P2-01 | Full physical Watch matrix (38 rows) | **PENDING_PHYSICAL** | MASTER_PHYSICAL_DEVICE_QA_MATRIX |
| P2-02 | Full physical iPhone matrix (16 rows) | **PENDING_PHYSICAL** | IOS_ACCESSIBILITY + PDF_RENDER |
| P2-03 | CMAltimeter physical gate | **PENDING_PHYSICAL** | WATCH_CMALTIMETER_PHYSICAL |
| P2-04 | Shallow wet Gauge + dev FC | **PENDING_PHYSICAL** | SDG-010, SDG-011 |
| P2-05 | Water auto-open physical (3 gates) | **PENDING_PHYSICAL** | MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE |
| P2-06 | Hardware controls physical (4 gates) | **PENDING_PHYSICAL** | MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE |
| P2-07 | WAO depth policy parity | **OPEN** | MASTER-WAO-001 |
| P2-08 | Instruments profiling | **PENDING_PHYSICAL** | iPhone memory/CPU session |
| P2-09 | External Bühlmann/Schreiner campaign | **PENDING_EXTERNAL** | BUHLMANN_EXTERNAL |
| P2-10 | External CCR campaign | **PENDING_EXTERNAL** | CCR_EXTERNAL |
| P2-11 | Subsurface external round-trip | **PENDING_EXTERNAL** | SUBSURFACE_EXTERNAL |
| P2-12 | App Store screenshots | **PENDING** | APP_STORE_MARKETING |

---

## P3 — Before App Store

| ID | Work item | Status | Action |
|----|-----------|--------|--------|
| P3-01 | Final legal counsel review | **PENDING** | LEGAL_REVIEW sign-off |
| P3-02 | Accessibility manual QA complete | **PENDING_PHYSICAL** | VoiceOver + Dynamic Type packs |
| P3-03 | Localization manual QA | **PENDING** | EN/IT spot check on device |
| P3-04 | Final release notes | **PENDING** | ASC release notes |
| P3-05 | Incident/rollback drill | **PENDING** | INCIDENT_RESPONSE drill |
| P3-06 | Watch startup flow test update | **OPEN** | DIRModesAndStartupFlowTests drift |
| P3-07 | Import checksum test expectation | **OPEN** | MWFC-P3-004 validation order |

---

## P4 — Polish (non-blocking)

| ID | Work item | Status |
|----|-----------|--------|
| P4-01 | Mission Mode discoverability | Open |
| P4-02 | Reminder suppression copy | Open |
| P4-03 | Positive shallow signing documentation | PASS |
| P4-04 | GF preset catalog documentation | PASS |

---

## June 2026 gate file index

| File | Purpose |
|------|---------|
| `MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv` | Entitlement + plist + developer shallow gates |
| `MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE_CURRENT.csv` | Submerged auto-launch physical QA |
| `MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE_CURRENT.csv` | Crown / Action Button / Water Lock |
| `MASTER_GF_PRESET_RELEASE_EVIDENCE_MATRIX_CURRENT.csv` | GF automated + physical evidence |
| `MASTER_TESTFLIGHT_SHALLOW_DEPTH_RISK_ASSESSMENT_CURRENT.md` | TF shallow-depth risk posture |

---

## 7 / 14 / 30 day suggested sequence

**Days 1–7:** Close software P1 (F016, sync); update Watch startup tests; internal TF with shallow disclosure; paired sync smoke + CMAltimeter physical template start.

**Days 8–14:** Shallow wet Gauge; WAO physical pack; hardware controls Water Lock session; external Bühlmann campaign kickoff.

**Days 15–30:** Full physical matrices; external validation reports; legal/marketing sign-off; App Store assets; incident drill.

**Rule:** Never mark PENDING_PHYSICAL or PENDING_EXTERNAL_VALIDATION as PASS without signed artifacts.
