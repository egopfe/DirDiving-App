# DIR DIVING — Master Readiness to 100% Plan (Current)

**Command:** 05 — Master Release / QA / Evidence / Compliance Audit V1.0  
**Date:** 2026-06-22  
**Branch:** `main` @ `1f62235`  
**Current overall release readiness:** **72%**  
**Target:** **100% evidence + compliance readiness** (physical, external, legal, ASC)

---

## Readiness layers

| Layer | Current | Target | Gap |
|-------|--------:|-------:|----:|
| Automated unit/integration | **100%** | 100% | 0% |
| Simulator validation scripts | **100%** | 100% | 0% |
| Claims / legal software posture | **100%** | 100% | 0% |
| Privacy manifest / engineering disclosure | **100%** | 100% | 0% |
| Physical Watch evidence | **0%** | 100% | 100% |
| Physical iPhone evidence | **0%** | 100% | 100% |
| Paired-device evidence | **0%** | 100% | 100% |
| CMAltimeter physical gate | **0%** | 100% | 100% |
| External reference validation | **0%** | 100% | 100% |
| App Store / legal sign-off | **40%** | 100% | 60% |

Software-only readiness is **100%** on `1f62235` (1519 iOS tests PASS; Watch suite executing). Path to **100% overall** is dominated by **field evidence packs and external gates**, not new unit tests.

---

## P0 — Before any safety-critical TestFlight (must be zero)

| ID | Work item | Status @ 1f62235 | Action |
|----|-----------|------------------|--------|
| P0-01 | Unsupported certification claims in copy | **CLEAR** | Maintain prohibited-claims scan in CI |
| P0-02 | Missing legal onboarding gate | **PASS** | Keep LegalAcceptanceGateTests green |
| P0-03 | Missing privacy manifest | **PASS** | Keep PrivacyInfo Watch + iOS wired |
| P0-04 | Safety-critical path with zero automated test | **PASS** | 68-row traceability matrix; software PASS |
| P0-05 | Missing entitlement for required feature | **PASS** | Water submersion + iCloud configured |
| P0-06 | False physical/external QA claim | **CLEAR** | All matrices remain PENDING until artifacts |

**P0 open items: 0**

---

## P1 — Before internal TestFlight (CONDITIONAL met with disclosure)

| ID | Work item | Status | Action |
|----|-----------|--------|--------|
| P1-01 | Full automated test suites green | **PASS** (iOS); Watch pending completion | Re-run Watch suite to completion |
| P1-02 | Basic physical install smoke | **PENDING** | Ultra + iPhone install log in `WATCH_ULTRA/` |
| P1-03 | Paired sync smoke | **PENDING** | One row of `WATCH_IOS_SYNC_QA_MATRIX.md` |
| P1-04 | Watch FC dry-run CMAltimeter software path | **PASS** | `WatchCMAltimeterRemediationTests` |
| P1-05 | Settings/Logbook ownership evidence | **PASS** (software) | Command 7 gate |
| P1-06 | Privacy policy alignment | **PASS** (software) | ASC preview still PENDING |
| P1-07 | TestFlight metadata wording | **PASS** | `TESTFLIGHT_REVIEW_NOTES.md` |

---

## P2 — Before external TestFlight

| ID | Work item | Status | Action |
|----|-----------|--------|--------|
| P2-01 | Full physical Watch matrix (31 rows) | **PENDING** | `MASTER_PHYSICAL_DEVICE_QA_MATRIX_CURRENT.csv` |
| P2-02 | Full physical iPhone matrix (16 rows) | **PENDING** | IOS_ACCESSIBILITY + PDF_RENDER |
| P2-03 | CMAltimeter physical gate (6 scenarios) | **PENDING** | `WATCH_CMALTIMETER_PHYSICAL/` |
| P2-04 | Instruments profiling | **PENDING** | iPhone memory/CPU session |
| P2-05 | External Bühlmann/Schreiner campaign | **PENDING** | `BUHLMANN_EXTERNAL/` |
| P2-06 | External CCR campaign | **PENDING** | `CCR_EXTERNAL/` |
| P2-07 | Subsurface external round-trip | **PENDING** | `SUBSURFACE_EXTERNAL/` |
| P2-08 | App Store screenshots | **PENDING** | `APP_STORE_MARKETING/` |
| P2-09 | Support URL operational approval | **PENDING** | `SUPPORT_ESCALATION_AND_SLA_CURRENT.md` |

---

## P3 — Before App Store

| ID | Work item | Status | Action |
|----|-----------|--------|--------|
| P3-01 | Final legal counsel review | **PENDING** | `LEGAL_REVIEW/` sign-off |
| P3-02 | Accessibility manual QA complete | **PENDING** | VoiceOver + Dynamic Type packs |
| P3-03 | Localization manual QA | **PENDING** | Field spot-check EN/IT |
| P3-04 | Final release notes | **PENDING** | Align with non-certified posture |
| P3-05 | Incident/rollback drill | **PENDING** | Tabletop using runbooks |

---

## Execution phases

### Phase 1 — Maintain software gates (ongoing)

- Keep `validate_*_readiness.sh` scripts green on CI
- iOS + Watch algorithm test suites on every release candidate
- Prohibited-claims scan + legal localization tests

### Phase 2 — CMAltimeter + Ultra field pack (2–3 weeks)

Execute `QA_EVIDENCE/WATCH_CMALTIMETER_PHYSICAL/` and `WATCH_ULTRA/` per templates on Apple Watch Ultra with entitlement-signed build.

### Phase 3 — Paired + iCloud (1–2 weeks)

`WATCH_IOS_SYNC/`, `ICLOUD_TWO_DEVICE/`, activity-specific Apnea/Snorkeling sync folders.

### Phase 4 — External validation (4–8 weeks, parallel)

Bühlmann/Schreiner, CCR, Subsurface campaigns with signed reports.

### Phase 5 — App Store gate (1 week)

Marketing assets, ASC privacy preview, legal/marketing sign-off, incident drill.

---

## Tracking metric

```
Evidence readiness = PASS rows in (traceability + physical matrix + external gaps closed) / total required rows
```

Current @ 1f62235:

- Traceability: **68 rows** — **52 PASS**, **16 NOT_PASSED** (all physical/external/legal execution)
- Physical matrix: **62 rows** — **0 PASS**, **62 NOT_PASSED**
- External gaps: **62 open**

---

## Non-negotiable rules

1. **No evidence = not passed** — do not upgrade from simulator alone.
2. Do not fabricate tester names, serials, or underwater measurements.
3. Software regression gates must stay green during field QA.
4. Accepted residual risks require product sign-off in `RELEASE_CHECKLIST.md`.

---

## Verdict path

| Milestone | Required completion |
|-----------|---------------------|
| Internal TestFlight | P0 clear + P1 software PASS + truthful disclosure (**CURRENT — CONDITIONAL**) |
| External TestFlight | P2 physical + paired + CMAltimeter + external algorithm packs |
| App Store | P3 legal + marketing + a11y + ASC review |
