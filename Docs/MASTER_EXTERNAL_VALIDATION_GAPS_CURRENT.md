# DIR DIVING — Master External Validation Gaps (Current)

**Command:** 05 — Master Release / QA / Evidence / Compliance Audit V1.0  
**Date:** 2026-06-22  
**Branch:** `main` @ `1f62235`  
**Merged sources:** Command 12 (`TEST_QA_EVIDENCE_AUDIT_CURRENT.md`) + Command 13 (`RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md`)

**Policy:** External validation and physical QA remain **NOT PASSED** until signed artifacts exist in `Docs/QA_EVIDENCE/`. Simulator and automated tests do **not** close these gaps.

---

## Gap summary

| Category | Open gaps | Software substitute allowed? |
|----------|----------:|------------------------------|
| Physical Watch (incl. CMAltimeter) | 31 | **No** |
| Physical iPhone | 16 | **No** |
| Paired-device | 8 | **No** |
| Underwater / entitlement depth | 1 | **No** |
| External algorithm reference | 4 | **No** |
| App Store / legal / marketing | 2 | **No** |
| **Total NOT PASSED** | **62** | — |

---

## Bühlmann external validation

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-BM-01 | Third-party golden profile comparison vs independent oracle | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Algorithm marketing / external TF |
| MEXT-BM-02 | Repetitive-dive reference cases cross-checked externally | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Planner trust |
| MEXT-BM-03 | Multilevel decompression reference cases | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Full Computer positioning |

**Software status:** Internal fixtures, Audit-15 oracle, and 1519 iOS + Watch algorithm tests **PASS** on `1f62235`. **External campaign NOT EXECUTED.**

---

## Schreiner external validation

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-SCHR-01 | Schreiner analytic parity external golden set | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Bundled with Bühlmann campaign |
| MEXT-SCHR-02 | Schreiner multilevel segment validation | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Full Computer marketing |

**Software status:** `SchreinerAnalyticParityTests`, `BuhlmannSchreinerEquationTests` **PASS**. **External reference PENDING_EXTERNAL_VALIDATION.**

---

## Subsurface comparison

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-SS-01 | CSV export opened/imported in Subsurface externally | `QA_EVIDENCE/SUBSURFACE_EXTERNAL/` | Import compatibility claim |
| MEXT-SS-02 | Round-trip metadata preservation | `QA_EVIDENCE/SUBSURFACE_CSV/` | Export UX |

**Software status:** `SubsurfaceExportService` unit tests and CSV metadata round-trip tests **PASS**. **External tool validation NOT EXECUTED.**

---

## CCR external validation

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-CCR-01 | Rebreather bailout heuristic external review | `QA_EVIDENCE/CCR_EXTERNAL/` | CCR marketing |
| MEXT-CCR-02 | Loop PPO₂ reference-only posture field review | `QA_EVIDENCE/CCR_EXTERNAL/` | Safety copy |

**Software status:** `CCRMathRemediationTests` **PASS**; product documented **reference-only, not live loop controller**. **External campaign PENDING.**

---

## Ratio Deco validation

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-RD-01 | External reference cases for ratio deco heuristic | `QA_EVIDENCE/RATIO_DECO_EXTERNAL/` | Optional planner mode marketing |

**Software status:** `RatioDecoPlannerTests` **PASS**. External reference **optional / PENDING.**

---

## Rock Bottom / Gas ledger reference cases

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-RB-01 | Rock Bottom estimate reference workbook | Internal fixtures only | Non-blocking if copy stays estimate |
| MEXT-GL-01 | Gas ledger cylinder bar reference cases | Internal fixtures only | Non-blocking if copy stays estimate |

**Software status:** Formatter and planner tests **PASS**. External golden workbooks **not required for internal TF** if estimate wording maintained.

---

## Repetitive-dive validation

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-REP-01 | External repetitive-dive surface interval cases | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Planner external TF |

Bundled with Bühlmann external campaign.

---

## PDF / export validation

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-PDF-01 | Manual PDF render/share on device | `QA_EVIDENCE/PDF_RENDER/` | App Store UX |
| MEXT-PDF-02 | Export disclaimer legal review | `QA_EVIDENCE/LEGAL_REVIEW/` | App Store |

**Software status:** `PDFExportServiceTests` **PASS**. Manual render **PENDING_PHYSICAL.**

---

## Privacy / legal review

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-LEG-01 | External counsel App Store copy sign-off | `QA_EVIDENCE/LEGAL_REVIEW/` | App Store |
| MEXT-LEG-02 | Marketing prohibited-claims final screenshot review | `QA_EVIDENCE/APP_STORE_MARKETING/` | App Store |

**Software status:** Automated prohibited-claims scan, privacy manifests, legal onboarding tests **PASS**. **PENDING_LEGAL_REVIEW** and **PENDING_MARKETING_SIGN_OFF.**

---

## Certification strategy

| Gap ID | Description | Status |
|--------|-------------|--------|
| MEXT-CERT-01 | EN13319 / ISO 6425 certification | **Out of scope** — explicitly denied in product docs |
| MEXT-CERT-02 | Apple Watch certified dive computer | **Not claimed** — companion/reference posture |
| MEXT-CERT-03 | Medical device / CCR controller certification | **Not claimed** — reference-only |

No false certification gaps identified in production strings at `1f62235`.

---

## Accessibility manual review

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-A11Y-01 | VoiceOver legal + activity journeys | `QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/` | App Store |
| MEXT-A11Y-02 | Dynamic Type XL planner visual QA | `QA_EVIDENCE/IOS_ACCESSIBILITY/` | App Store UX |

**Software status:** Identifier contract tests and localization audit **PASS**. Manual device QA **NOT EXECUTED.**

---

## App Store review readiness

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-ASC-01 | App Store Connect privacy nutrition preview | App Store Connect | App Store |
| MEXT-ASC-02 | Final metadata + screenshots pack | `QA_EVIDENCE/APP_STORE_MARKETING/` | App Store |
| MEXT-ASC-03 | Apple review outcome | App Store Connect | App Store |

**Status:** **PENDING_APP_STORE_REVIEW** — not fabricated.

---

## Watch Full Computer CMAltimeter physical gate (mandatory)

| Gap ID | Description | Evidence folder | Blocking |
|--------|-------------|-----------------|----------|
| MEXT-CMA-01 | Physical CoreMotion absolute altitude sample before FC start | `QA_EVIDENCE/WATCH_CMALTIMETER_PHYSICAL/` | External TF / depth claims |
| MEXT-CMA-02 | Stable vs unstable proposal on wrist hardware | `QA_EVIDENCE/WATCH_CMALTIMETER_PHYSICAL/` | FC environment gate |
| MEXT-CMA-03 | Accept/reject preserving iPhone Plan / manual Watch setting | `QA_EVIDENCE/WATCH_CMALTIMETER_PHYSICAL/` | Authority preservation |

**Software status:** WCMA-001…011 **remediated** per `WATCH_CMALTIMETER_FULL_COMPUTER_REMEDIATION_REPORT_CURRENT.md`; `WatchCMAltimeterRemediationTests` **PASS**. **Physical gate: PENDING_PHYSICAL** — simulator-only evidence is insufficient.

---

## What software gates already cover (not gaps)

- Command 7 activity architecture / settings / logbook isolation
- Command 8 sync schema / signed ACK / tombstone codec
- Command 9 security / privacy / trust software readiness
- Command 10 performance / concurrency software readiness
- Command 11 localization catalog parity
- Watch Bühlmann/Full Computer simulator oracle tests (Audit 15, timing faults)
- Snorkeling/Apnea release-hard software validation suites
- iOS Algorithm Tests: **1519 tests, 0 failures** (2026-06-22 audit run)

---

## Closure rule

A gap moves from **NOT PASSED** to **PASS** only when the corresponding `QA_EVIDENCE/<folder>/` contains:

1. Completed README/STATUS template fields (tester, reviewer, device IDs, build/commit `1f62235` or later)
2. Required artifacts (screenshots, logs, videos per procedure)
3. Validator PASS for release mode where applicable

**Do not** mark PASS from simulator test output alone.
