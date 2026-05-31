# Documentation Update Report — 2026-05-31

**Baseline:** `main` @ `dae29b8` (`origin/main`)  
**Scope:** Align all product documentation with comprehensive NOAA CNS/OTU implementation and Bühlmann readiness P1–P4  
**Type:** Documentation-only pass (runtime already committed @ `dae29b8`)

---

## A. Trigger

Commit `dae29b8` implemented:

- Bühlmann comprehensive readiness fixes (environment, repetitive semantics, GF cache, calculate progress, bailout hint)
- Comprehensive NOAA CNS/OTU model (single + daily limits, 90 min recovery, REPEX OTU, air-break, snapshot v2 carryover)
- **119/119** `DIRDiving iOS Algorithm Tests` on iPhone 17 sim

Prior documentation still referenced simplified CNS/OTU, 104 tests, and baseline `3237262` as latest algorithm state.

---

## B. Files Updated

| File | Change |
|------|--------|
| `README.md` | Baseline `dae29b8`; algorithm + CNS/OTU pass in status table |
| `CHANGELOG.md` | Unreleased entry for `dae29b8` |
| `Docs/INDEX.md` | New §2026-05-31; test count 119 |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | New rows: comprehensive CNS/OTU, carryover v2, air-break note; updated test/doc rows |
| `Docs/PRODUCT_FEATURES_IT.md` | Planner Bühlmann + CNS/OTU section; baseline `dae29b8` |
| `Docs/GLOSSARY.md` | CNS/OTU definitions expanded |
| `Docs/ROADMAP.md` | Released items for CNS/OTU + readiness @ `dae29b8` |
| `Docs/RELEASE_CHECKLIST.md` | CNS/OTU QA items (daily summary, air-break, repetitive carryover) |
| `Docs/DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md` | P2-5 SOLVED; 119 tests; files + QA |
| `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md` | Comprehensive CNS/OTU UX/engine copy |
| `Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md` | §2026-05-31 CNS/OTU model table |
| `Docs/DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md` | Phase 4 marked implemented |
| `Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md` | Implementation note; P2-5 + oxygen row updated |
| `Docs/DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md` | P2-6 references comprehensive model |

Already current from prior commit (verified, no change required unless noted):

- `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md` §11

---

## C. Feature Comparison Matrix (CSV)

New or updated rows (Area = Algorithm / UX / Documentation):

1. **Comprehensive NOAA CNS/OTU reference model** — `OxygenExposureModels.swift`
2. **Repetitive oxygen carryover snapshot v2** — `TissueSnapshot` + `PlannerService`
3. **Air-break CNS recovery note** — plan result UI
4. **CNS/OTU disclaimers** — daily CNS / OTU 24h summary on input + result
5. **Documentation update 2026-05-31** — this report

Test count references updated from 104 → **119** where applicable.

---

## D. Branch / PR Status

| Branch | State |
|--------|--------|
| `main` | @ `dae29b8`, synced with `origin/main` |
| `main-iOS` | Historical divergent worktree — not release baseline |
| `codex/experimental-features` | Experimental — unchanged |
| `codex/ios-experimental-features` | Experimental — unchanged |

PR #8 / #9: unchanged — not safe-to-merge automatically (see `PR_STATUS_20260527.md`).

---

## E. Remaining Documentation Gaps

| Gap | Owner |
|-----|--------|
| Root `DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md` — pre-comprehensive CNS/OTU formulas | Historical reference; limitations + math verification are authoritative |
| External Bühlmann validation campaign execution | Manual — `DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` |
| Physical VoiceOver / Dynamic Type QA | Manual — `DIR_DIVING_IOS_PHYSICAL_ACCESSIBILITY_QA.md` |

---

## F. Confirmations

| Check | Result |
|-------|--------|
| No runtime code changed in this pass | ✅ |
| CSV row count additive (no deletions of historical rows) | ✅ |
| Safety positioning preserved (reference-only, non-certified) | ✅ |
| Watch / experimental docs untouched | ✅ |

---

## G. Suggested Next Documentation Pass

1. Execute external validation and append results to completion report
2. Run physical a11y QA and check off `RELEASE_CHECKLIST.md`
3. Refresh `DIR_DIVING_FINAL_IMPLEMENTATION_AND_READINESS_REPORT.md` HEAD to `1d69d88` when Phase 16 sign-off is requested

---

## Part 2 — iOS MAIN readiness 100% documentation pass (@ `dce89e7` / `1d69d88`)

**Trigger:** Runtime remediation committed @ `dce89e7`; CI fix @ `1d69d88`. Prior Part 1 covered CNS/OTU @ `dae29b8`.

### Files created

| File | Purpose |
|------|---------|
| `Docs/IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md` | Final readiness report (already in repo from runtime commit) |
| `Docs/SUBSURFACE_CSV_ROUNDTRIP.md` | CSV metadata round-trip spec + QA |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260531.md` | Branch + PR sync state |
| `Docs/PR_STATUS_20260531.md` | Open PR #8/#9/#10 status |

### Files updated (this pass)

| File | Change |
|------|--------|
| `README.md` | Baseline `1d69d88`; readiness 100% row; 154 tests |
| `CHANGELOG.md` | Unreleased entries for `dce89e7`, `1d69d88` |
| `Docs/INDEX.md` | § readiness 100% @ `dce89e7` |
| `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md` | Pressure, planning depth, cloud, CSV, incomplete calc, OTU progressive recovery |
| `Docs/iOS/SUBSURFACE_EXPORT.md` | `# session_meta` block |
| `Docs/BUILD_VALIDATION.md` | Local validation @ `1d69d88`, 154 tests |
| `Docs/TESTFLIGHT_REVIEW_NOTES.md` | Baseline + QA items for new behaviours |
| `Docs/ROADMAP.md` | Released row readiness 100% |
| `Docs/PRODUCT_FEATURES_IT.md` | Baseline + planner features |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | New rows B2–B5 fixes |
| `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` | Post-remediation status note |

### Test count

| Before | After |
|--------|-------|
| 119 iOS algorithm XCTest | **154** executed, **1 skipped**, **0 failures** (local iPhone 17 sim) |

### Branch sync

All active branches merged/pushed through `1d69d88`: `main`, `main-iOS`, `codex/experimental-features`, `codex/ios-experimental-features`, `codex/watch-main-algorithm-audit-current`.

---

## Part 3 — Watch MAIN readiness 100% documentation pass (2026-05-31)

**Trigger:** Runtime remediation WMATH-HIGH-001 → INFO-014 + companion iOS sync/UI; XCTest Watch + iOS **PASS**.

### Files created

| File | Purpose |
|------|---------|
| `Docs/WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md` | Final Watch readiness report |
| `Docs/WATCH_MANUAL_NODEPTH_SYNC_POLICY.md` | Manual/no-depth sync Policy A |

### Files updated

| File | Change |
|------|--------|
| `README.md` | Watch readiness 100% row; baseline note |
| `CHANGELOG.md` | Unreleased Watch readiness entry |
| `Docs/INDEX.md` | § Watch readiness 100%; audit refs updated from ~82% |
| `Docs/WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` | Post-remediation note + resolved blockers |
| `Docs/ROADMAP.md` | Released Watch readiness 100%; P1 XCTest marked pass |
| `Docs/BUILD_VALIDATION.md` | Watch build + algorithm tests PASS |
| `Docs/TESTFLIGHT_REVIEW_NOTES.md` | Watch QA checklist items 2026-05-31 |
| `Docs/PR_STATUS_20260531.md` | PR #10 superseded by main merge |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260531.md` | Branch sync note |

### Test count (Watch)

| Suite | Result |
|-------|--------|
| `DIRDiving Watch Algorithm Tests` | **PASS** (Ultra 3 sim; incl. `WatchReadinessAlgorithmTests`) |
| `DIRDiving iOS Algorithm Tests` | **PASS** (+ `WatchManualNoDepthSyncTests`) |

### Branch sync (2026-05-31, post Watch readiness)

All active branches merged/pushed through `e952b55`:

| Branch | Commit |
|--------|--------|
| `main` | `ac47480` |
| `main-iOS` | `dd8edae` |
| `codex/experimental-features` | `8e1a6ff` |
| `codex/ios-experimental-features` | `b02a658` |
| `codex/watch-main-algorithm-audit-current` | `82a4cb3` |

---

## Part 4 — MAIN UI/UX readiness 100% documentation pass (@ `c8f91f6`)

**Trigger:** Runtime remediation P0–P2 @ `d796bfd` + P3 @ `c8f91f6`. Builds + algorithm tests **PASS** (Watch Ultra 3 + iPhone 17 sim).

### Files created (runtime pass, prior commits)

| File | Purpose |
|------|---------|
| `Docs/MAIN_UI_UX_READINESS_AUDIT_CURRENT.md` | Read-only pre-fix audit (83/86/81%) |
| `Docs/MAIN_UI_UX_READINESS_AUDIT_LONG_PRE_FIX.md` | Issue inventory pre-fix |
| `Docs/MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md` | Post-fix verdict 100% (codice) |
| `Docs/MAIN_UI_UX_READINESS_QA_ANALYSIS.md` | Build/test QA synthesis |

### Files updated (this pass)

| File | Change |
|------|--------|
| `README.md` | Baseline `c8f91f6`; UI/UX readiness row |
| `CHANGELOG.md` | Unreleased UI/UX entries @ `d796bfd` / `c8f91f6` |
| `Docs/INDEX.md` | § MAIN UI/UX readiness @ `c8f91f6` |
| `Docs/ROADMAP.md` | Released UI/UX 100% row |
| `Docs/BUILD_VALIDATION.md` | UI/UX baseline note |
| `Docs/TESTFLIGHT_REVIEW_NOTES.md` | UI/UX post-fix doc ref |
| `Docs/PR_STATUS_20260531.md` | Baseline + QA § I |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260531.md` | Branch sync @ `c8f91f6` |
| `Docs/MAIN_UI_UX_READINESS_AUDIT_CURRENT.md` | Supersession note → post-fix report |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Row 68 fixed; +12 UI/UX/doc rows |

### CSV highlights

- Row **68** (iOS logbook destructive confirmations): TODO → **Implemented** @ `c8f91f6`
- New rows: Live scroll, legal i18n, Crown hint, Policy A edit, DEMO badge, iCloud conflicts, expanded search, CSVImportPanel, mode selection docs, UI/UX audit docs

### Branch sync (2026-05-31, post UI/UX docs)

All active branches merged/pushed through `c8f3bd5`:

| Branch | Commit |
|--------|--------|
| `main` | `c8f3bd5` |
| `main-iOS` | `0b9a7d4` |
| `codex/experimental-features` | `7f4779f` |
| `codex/ios-experimental-features` | `a39a073` |
| `codex/watch-main-algorithm-audit-current` | `962ceb1` |
