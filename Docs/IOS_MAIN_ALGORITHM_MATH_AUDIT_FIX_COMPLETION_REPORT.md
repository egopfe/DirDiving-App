# iOS MAIN Algorithm Math Audit — Fix Completion Report

**Original audit:** [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) @ `f8820b7`  
**Implementation date:** 2026-06-07  
**Scope:** `DIRDiving iOS` (Companion MAIN) only  
**Simulator:** iPhone 17 (macOS)

---

## Build / test results

| Step | Result |
|---|---|
| `xcodegen generate` | OK |
| `DIRDiving iOS` build | **BUILD SUCCEEDED** |
| `DIRDiving iOS Algorithm Tests` | **382 passed**, 5 skipped, 0 failures |

---

## P1 fixes

| ID | Action |
|---|---|
| IOS-MAIN-P1-001 | Added [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md) |
| IOS-MAIN-P1-002 | Extended `PlannerFixture` metadata + `BuhlmannExternalValidationMetadataTests.swift`; updated [`DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`](DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md) |

No certified equivalence claims introduced.

---

## P2 fixes

| ID | Action |
|---|---|
| IOS-MAIN-P2-001 | Documented `DiveSessionMergePolicy`; logging on divergent profile merge; tests in `CloudSessionMergeTests` |
| IOS-MAIN-P2-002 | Weekly OTU tile + warning in `PlannerView.swift`; EN/IT strings |
| IOS-MAIN-P2-003 | Granular `PlannerResultState` cases + `GasPlanningService.exposurePlannerStates` mapping |
| IOS-MAIN-P2-004 | Logbook tissue analytics limitation in [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) |
| IOS-MAIN-P2-005 | Option A briefing order: UI footnote + docs + `PlannerAscentTableTests` |
| IOS-MAIN-P2-006 | `CloudSyncStoreLoadTests.swift` + `CloudSyncStore.prefersCloudPayload` |
| IOS-MAIN-P2-007 | `WatchSyncServiceIntegrationTests.swift` |

---

## P3 fixes

| ID | Action |
|---|---|
| IOS-MAIN-P3-001 | Updated `README.md`, `Docs/README.md` baseline pointers |
| IOS-MAIN-P3-002 | Updated [`IOS_PLANNER_CHART_TRUTHFULNESS.md`](IOS_PLANNER_CHART_TRUTHFULNESS.md) |
| IOS-MAIN-P3-003 | Created [`DIR_DIVING_IOS_CNS_PLANNER_IMPLEMENTATION_AUDIT.md`](DIR_DIVING_IOS_CNS_PLANNER_IMPLEMENTATION_AUDIT.md) |
| IOS-MAIN-P3-005 | Superseded notice on [`DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md`](DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md) |

---

## P4 plans

| ID | Action |
|---|---|
| IOS-MAIN-P4-* | [`DIR_DIVING_IOS_EXTERNAL_VALIDATION_AND_QA_PLAN.md`](DIR_DIVING_IOS_EXTERNAL_VALIDATION_AND_QA_PLAN.md), [`DIR_DIVING_IOS_TESTFLIGHT_READINESS_CHECKLIST.md`](DIR_DIVING_IOS_TESTFLIGHT_READINESS_CHECKLIST.md) |

---

## Files modified (iOS + tests + docs)

**Swift:** `PlannerResultState.swift`, `GasPlanningService.swift`, `GasPlan.swift`, `DiveSessionMerge.swift`, `CloudSyncStore.swift`, `PlannerView.swift`, `en.lproj/Localizable.strings`, `it.lproj/Localizable.strings`, `BuhlmannGoldenFixtureTests.swift` (PlannerFixture metadata)

**Tests created:** `BuhlmannExternalValidationMetadataTests.swift`, `CloudSyncStoreLoadTests.swift`, `PlannerOxygenWarningGranularityTests.swift`, `WatchSyncServiceIntegrationTests.swift`

**Tests updated:** `CloudSessionMergeTests.swift`, `PlannerAscentTableTests.swift`, `PlannerCNSCopyTests.swift`

**Docs created/updated:** see P1–P4 sections above + [`DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md)

---

## Confirmations

| Check | Status |
|---|---|
| Watch runtime modified | **No** |
| Experimental files modified | **No** |
| Bühlmann math changed | **No** |
| CNS/OTU equations changed | **No** |
| Legal/safety wording weakened | **No** |

---

## Remaining limitations

- External Bühlmann comparison campaign not executed (planned)
- Physical device / VoiceOver QA pending
- Logbook tissue analytics still simulated (GF 0.85)
- Cloud KVS full integration paths partially depend on `NSUbiquitousKeyValueStore` in device QA

---

## Final verdict

**READY FOR INTERNAL VALIDATION** — stronger internal-TestFlight readiness; external TestFlight and App Store still require QA plans EV-* / SYNC-* / A11Y-*.
