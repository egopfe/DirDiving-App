# Snorkeling Watch P1/P2/P3 Unified Remediation Plan Current

**Date:** 2026-07-02  
**Repository:** egopfe/DirDiving-App  
**Audit baseline:** `1272885`  
**Source audit:** `Docs/SNORKELING_WATCH_P1_P2_P3_DEEP_AUDIT_CURRENT.md`

---

## 1. Executive Remediation Summary

| Phase | Current state | Target state |
|-------|---------------|--------------|
| **P1** | **P1_PARTIAL** — sync protocol complete; UX/E2E gaps | **P1_READY** after R1 fixes + manual QA PASS |
| **P2** | **P2_PARTIAL** — premium features shipped; policy/UI wiring gaps | **P2_READY** after R2 fixes + manual QA PASS |
| **P3** | **P3_PARTIAL** — advanced features coded; QA all PENDING | **P3_READY** after R3 QA + optional analytics polish |

**Recommended sequence:** **R1 → R2 → R3**. Do not treat P3 as release-ready until P1 stabilization items are closed.

**What not to do:**
- Do not implement heatmap in Snorkeling production (policy forbids).
- Do not add Always Location or underwater GPS claims.
- Do not modify Diving, Apnea, Full Computer, or Gauge runtime for Snorkeling fixes.
- Do not claim PRODUCTION_READY until QA evidence folders contain device artifacts.

**Blocking issues:**
1. All 54+ Snorkeling QA evidence folders **PENDING**
2. No WatchConnectivity E2E integration tests
3. iOS route pending send queue not persisted

**Build/test status (audit run):**
- `xcodegen generate` — **PASS**
- Watch + iOS generic simulator build — **PASS**
- Full algorithm test schemes — **FULL_SUITE_NOT_RUN**
- Targeted P1/P2/P3 smoke tests — **PASS**

---

## 2. Non-regression guardrails

- **Activity separation:** Snorkeling-only files; verify with `SnorkelingArchitectureIsolationTests` after each fix.
- **No Diving/Full Computer/Gauge/Apnea changes** unless fixing a proven cross-contamination bug (none found).
- **No algorithm changes** except Snorkeling-specific presentation/sync thresholds.
- **No fake/demo contamination** in production Snorkeling paths.
- **No GPS Always permission** or underwater GPS navigation claims.
- **No cloud/Bluetooth scope creep** beyond existing WatchConnectivity patterns.
- **No production/QA claims** without code + test + UI + docs + build evidence.

---

## 3. Remediation Phase R1 — P1 stabilization

*Complete R1 before starting R2 premium polish or R3 advanced work.*

---

## R1-001 — Enhance route/session sync visibility on iOS

**Priority:** P1  
**Severity:** Medium  
**Status:** REQUIRED  
**Current verdict:** PARTIAL

**Evidence:**
- `iOSApp/Utils/SnorkelingRouteSyncStatusPresentation.swift` — status labels exist
- `iOSApp/Views/Snorkeling/IOSSnorkelingDashboardView.swift` — aggregate sync card
- `iOSApp/Views/Snorkeling/IOSSnorkelingSessionDetailView.swift` — no per-session sync error row

**Problem:** Users may not see failed or stale route/session sync when viewing a specific logbook entry.

**Remediation:** Add optional sync status row on session detail when import failed/pending; surface stale revision message from transfer service on planner with persistent banner until dismissed.

**Files likely involved:**
- `iOSApp/Views/Snorkeling/IOSSnorkelingSessionDetailView.swift`
- `iOSApp/Utils/SnorkelingWatchSyncStatusPresentation.swift`
- `iOSApp/Views/Snorkeling/IOSSnorkelingRoutePlannerView.swift`

**Tests required:**
- Extend `SnorkelingWatchSyncStatusPresentationTests` for detail-level states
- UI contract test for error banner visibility

**Acceptance criteria:**
- Failed session sync shows localized error on dashboard **and** detail when applicable
- Stale route revision shows actionable message on planner

**Non-regression checks:**
- Apnea/FC sync cards unchanged
- `SnorkelingCrossDomainIsolationTests` PASS

---

## R1-003 — Runtime battery wiring test

**Priority:** P1  
**Severity:** Medium  
**Status:** REQUIRED  
**Current verdict:** WIRED_BUT_UNTESTED

**Evidence:**
- `Services/SnorkelingWatchRuntimeStore.swift` — `updateBattery()` reads `WKInterfaceDevice.current().batteryLevel`, sets `lastBatteryFraction`, passes to `buildPresentationInput`
- `Tests/WatchAlgorithmTests/SnorkelingWatchBatteryPresentationTests.swift` — tests presentation with injected fraction only

**Problem:** Regression could reintroduce hardcoded `nil` battery without test failure.

**Remediation:** Add test on `SnorkelingWatchRuntimeStore` (or package-level helper) verifying battery fraction propagation when mock level ≥ 0 and nil/unknown when level < 0.

**Files likely involved:**
- `Services/SnorkelingWatchRuntimeStore.swift`
- `Tests/WatchAlgorithmTests/SnorkelingWatchBatteryPresentationTests.swift` (or new `SnorkelingWatchRuntimeBatteryTests.swift`)

**Tests required:**
- Positive: level 0.75 → presentation input 0.75
- Negative: level -1 → nil fraction, unknown UI text

**Acceptance criteria:**
- Test fails if `batteryFraction` hardcoded nil in `buildPresentationInput`

**Non-regression checks:**
- No change to Apnea battery paths

---

## R1-004 — Pending route activation UX

**Priority:** P1  
**Severity:** Low  
**Status:** OPTIONAL  
**Current verdict:** PARTIAL

**Evidence:**
- `Services/SnorkelingImportedRouteStore.swift` — `pendingPackage`, `activatePendingIfNeeded()`
- `Views/SnorkelingView.swift` — pending banner on ready panel

**Problem:** User may not understand route will activate after current session ends.

**Remediation:** Strengthen copy on Watch ready banner and iOS planner after send-during-session; add accessibility hint.

**Files likely involved:**
- `Resources/en.lproj/Localizable.strings`, `Resources/it.lproj/Localizable.strings`
- `Views/SnorkelingView.swift`
- `Utils/SnorkelingWatchReadyPresentationPolicy.swift`

**Tests required:**
- Update `SnorkelingWatchReadyRoutePresentationTests` for pending copy key

**Acceptance criteria:**
- Pending state shows distinct localized string on Watch and iOS

**Non-regression checks:**
- Localization parity tests PASS

---

## R1-005 — Session sync failure on logbook detail

**Priority:** P1  
**Severity:** High  
**Status:** REQUIRED  
**Current verdict:** PARTIAL

**Evidence:**
- `iOSApp/Services/IOSSnorkelingSessionSyncService.swift` — tracks import state
- Dashboard shows aggregate line; detail does not

**Problem:** Session visible on Watch but missing on iOS appears as data loss.

**Remediation:** Show sync pending/failed badge on session list rows and detail header when session ID in failed/pending set.

**Files likely involved:**
- `iOSApp/Views/Snorkeling/IOSSnorkelingSessionsListView.swift`
- `iOSApp/Views/Snorkeling/IOSSnorkelingSessionDetailView.swift`
- `iOSApp/Utils/SnorkelingWatchSyncStatusPresentation.swift`

**Tests required:**
- Presentation test for failed/pending session row labels

**Acceptance criteria:**
- User can see retry guidance without opening dashboard only

**Non-regression checks:**
- Diving/Apnea logbook lists unchanged

---

## R1-006 — Per-session sync source in logbook

**Priority:** P1  
**Severity:** Medium  
**Status:** REQUIRED  
**Current verdict:** MISSING

**Evidence:**
- `Shared/Models/SnorkelingSession.swift` — `startMode` (.watch, .manual, .imported)
- `IOSSnorkelingSessionDetailView.swift` — no startMode display (grep: no matches)

**Problem:** Support and users cannot distinguish Watch-synced vs manual sessions.

**Remediation:** Add detail row: localized label from `startMode` + optional sync timestamp from import metadata if available.

**Files likely involved:**
- `iOSApp/Views/Snorkeling/IOSSnorkelingSessionDetailView.swift`
- `iOSApp/Utils/SnorkelingLogbookDetailPresentation.swift`
- `iOSApp/Resources/*/Localizable.strings`

**Tests required:**
- Presentation mapper test for each startMode

**Acceptance criteria:**
- Detail shows "Recorded on Watch" / "Manual" / "Imported" appropriately

**Non-regression checks:**
- Unified logbook other activities unaffected

---

## R1-007 — Persist iOS route pending send queue

**Priority:** P1  
**Severity:** Medium  
**Status:** REQUIRED  
**Current verdict:** MISSING

**Evidence:**
- `iOSApp/Services/IOSSnorkelingWatchTransferService.swift` — in-memory `pendingQueue`

**Problem:** iOS relaunch loses unsent route packages.

**Remediation:** Persist pending entries to scoped UserDefaults or small JSON file under Snorkeling namespace; restore on launch.

**Files likely involved:**
- `iOSApp/Services/IOSSnorkelingWatchTransferService.swift`
- `Shared/Utils/SnorkelingRouteSyncTransferSupport.swift`

**Tests required:**
- Persistence round-trip test for pending queue
- Negative: corrupt pending file ignored safely

**Acceptance criteria:**
- Pending send survives iOS process kill and resumes flush

**Non-regression checks:**
- Apnea transfer queue unchanged
- Namespace ≠ `dirdiving_apnea_*`

---

## R1-009 — WatchConnectivity integration test harness

**Priority:** P1  
**Severity:** High  
**Status:** OPTIONAL (recommended before App Store)  
**Current verdict:** MISSING

**Evidence:**
- Codec/ACK unit tests exist; no paired simulator WC test

**Problem:** Field failures in transfer timing not caught in CI.

**Remediation:** Add UI test or integration test using WC test doubles / simulator pair documenting manual preconditions.

**Files likely involved:**
- New `Tests/IntegrationTests/SnorkelingRouteSyncIntegrationTests.swift` (if CI supports)
- Docs/QA_EVIDENCE/SNORKELING_ROUTE_PUSH

**Tests required:**
- Route send → Watch import → ACK → iOS acknowledged state

**Acceptance criteria:**
- Documented test procedure at minimum; automated if CI allows

**Non-regression checks:**
- Apnea route sync tests remain isolated

---

## 4. Remediation Phase R2 — P2 premium runtime/config

*Start R2 only after R1 REQUIRED items R1-001, R1-003, R1-005, R1-006, R1-007 are closed or explicitly waived.*

---

## R2-001 — Wire returnIsPrimaryAction in Watch UI

**Priority:** P2  
**Severity:** Medium  
**Status:** REQUIRED  
**Current verdict:** PARTIAL

**Evidence:**
- `Utils/SnorkelingWatchReturnPrimaryActionPolicy.swift` — `returnIsPrimaryAction`
- `Utils/SnorkelingWatchPresentation.swift` — output field set
- `Views/SnorkelingView.swift` — uses `returnPrimaryActionTitle/Enabled` but not `returnIsPrimaryAction`

**Problem:** Policy flag is dead code; future layout changes may demote return action unintentionally.

**Remediation:** Use `returnIsPrimaryAction` to apply distinct styling (hero height, accent, accessibility priority) or assert in UI contract test that return button remains first when flag true.

**Files likely involved:**
- `Views/SnorkelingView.swift`
- `Tests/WatchAlgorithmTests/SnorkelingWatchReturnPrimaryActionTests.swift`
- `Tests/WatchAlgorithmTests/SnorkelingWatchUIViewContractTests.swift`

**Tests required:**
- Assert `returnIsPrimaryAction == true` implies primary accessibility identifier and visual token

**Acceptance criteria:**
- Removing first-button layout without checking flag fails test

**Non-regression checks:**
- Navigation/marker buttons unchanged when return unavailable

---

## R2-002 — iOS settings apply without full route re-send

**Priority:** P2  
**Severity:** Medium  
**Status:** OPTIONAL  
**Current verdict:** PARTIAL

**Evidence:**
- Settings persist in `SnorkelingCompanionSettings`
- Thresholds embedded only in route package metadata on send
- `SnorkelingWatchRuntimeStore.applyOperationalThresholds` on route import

**Problem:** User changes max distance on iOS but Watch keeps old thresholds until new route sent.

**Remediation:** Option A: lightweight settings-only WC message. Option B: show iOS banner "Re-send route to apply settings on Watch."

**Files likely involved:**
- `iOSApp/Services/IOSSnorkelingWatchTransferService.swift`
- `iOSApp/Views/Snorkeling/IOSSnorkelingSettingsContent.swift`
- `Services/SnorkelingWatchRuntimeStore.swift`

**Tests required:**
- Settings delta apply test or banner presentation test

**Acceptance criteria:**
- User always knows whether Watch thresholds match iOS settings

**Non-regression checks:**
- Route package schema backward compatible

---

## R2-005 — Watch ready panel UI contract for route summary

**Priority:** P2  
**Severity:** Low  
**Status:** OPTIONAL  
**Current verdict:** WIRED_BUT_UNTESTED

**Evidence:**
- `SnorkelingWatchRouteSummaryPresentationTests` — policy only
- `SnorkelingView.readyGrid` — displays `routeCompactSummaryText`

**Remediation:** Add `SnorkelingWatchUIViewContractTests` assertion that ready stage exposes route summary accessibility id.

**Files likely involved:**
- `Tests/WatchAlgorithmTests/SnorkelingWatchUIViewContractTests.swift`

**Tests required:**
- Fixture ready input → output contains non-empty route summary when route present

**Acceptance criteria:**
- Regression catches removal of summary from ready panel

**Non-regression checks:**
- Layout contract tests for other stages PASS

---

## 5. Remediation Phase R3 — P3 advanced navigation/analytics

*Start R3 polish only after R1 REQUIRED closed. P3 code is largely IMPLEMENTED; R3 focuses on QA and optional analytics.*

---

## R3-002 — Route adherence clarity (optional score)

**Priority:** P3  
**Severity:** Low  
**Status:** OPTIONAL  
**Current verdict:** PARTIAL (metrics without composite score)

**Evidence:**
- `SnorkelingSessionRuntimeSummary` — `routeCompletedPercentage`, `maxOffRouteDistanceMeters`, `offRouteEventCount`
- No single `adherenceScore` field

**Problem:** Users may misinterpret progress % as safety validation.

**Remediation:** Either add computed adherence label (Good/Fair/Poor) from existing metrics **or** strengthen copy to "orientation aid / not safety validation."

**Files likely involved:**
- `iOSApp/Utils/SnorkelingPlannedVsActualAnalytics.swift`
- `iOSApp/Views/Snorkeling/IOSSnorkelingSessionDetailView.swift`

**Tests required:**
- Policy test for adherence label buckets

**Acceptance criteria:**
- No safety-critical wording; clear non-validation disclaimer

**Non-regression checks:**
- `SnorkelingReleaseSelfCheck` safety wording scan PASS

---

## R3-001 — Heatmap

**Priority:** P3  
**Severity:** N/A  
**Status:** BLOCKED  
**Current verdict:** NOT_APPLICABLE

**Evidence:**
- `Utils/SnorkelingReleaseSelfCheck.swift` — production scan forbids `heatmap`
- Only experimental/exploration views reference heatmap

**Remediation:** Do not implement. Document in user-facing help that heatmap is not part of Snorkeling.

---

## R3-003 — Execute manual QA evidence program

**Priority:** P1/P2/P3  
**Severity:** Critical  
**Status:** REQUIRED  
**Current verdict:** DOCUMENTED_ONLY

**Evidence:**
- 54 `Docs/QA_EVIDENCE/SNORKELING_*` folders — all **PENDING**
- `SnorkelingQAEvidenceCatalogTests` enforces folder existence

**Problem:** INTERNAL_READY cannot become release-ready without device evidence.

**Remediation:** Execute QA checklists in order: P1 (5) → P2 (6) → P3 (6) → cross-regression (3) → catalog (25) → iOS map (8).

**Files likely involved:**
- `Docs/QA_EVIDENCE/**/README.md` — attach screenshots/logs
- Optional `STATUS.md` PASS entries

**Tests required:**
- Manual only; update catalog when PASS recorded

**Acceptance criteria:**
- P1/P2/P3 blocking folders have PASS with dated evidence
- `SnorkelingQAEvidenceCatalogTests` updated if policy allows PASS

**Non-regression checks:**
- Cross-activity regression folder PASS on physical device

---

## 6. Required tests (summary)

| ID | Test |
|----|------|
| R1-003 | SnorkelingWatchRuntimeStore battery propagation |
| R1-005 | Session sync failure presentation on detail |
| R1-006 | startMode label presentation |
| R1-007 | Pending route queue persistence |
| R1-009 | WC integration (documented minimum) |
| R2-001 | returnIsPrimaryAction UI contract |
| R2-002 | Settings apply or re-send banner |
| R2-005 | Ready panel route summary contract |
| R3-002 | Adherence label or disclaimer test |

Run full suites before release:
```bash
xcodegen generate
xcodebuild test -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test
xcodebuild test -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17' test
```

---

## 7. Required docs

| Doc | Action |
|-----|--------|
| `SNORKELING_WATCH_P1_P2_P3_DEEP_AUDIT_CURRENT.md` | Created (this audit cycle) |
| Feature/risk/test matrices (CSV) | Created |
| This remediation plan | Created |
| Phase reports P1/P2/P3 | Update verdicts after R1/R2/R3 fixes |
| `Docs/INDEX.md` | Update baseline after remediation commits |

---

## 8. Required QA evidence

**Minimum blocking set for internal release candidate:**

1. `SNORKELING_P1_ROUTE_SYNC_STATUS_IOS`
2. `SNORKELING_P1_WATCH_TO_IOS_SYNC_STATUS`
3. `SNORKELING_P1_WATCH_READY_ROUTE_STATUS`
4. `SNORKELING_P1_WATCH_BATTERY_PRESENTATION`
5. `SNORKELING_P2_RETURN_PRIMARY_ACTION`
6. `SNORKELING_P2_OPERATIONAL_SETTINGS_IOS`
7. `SNORKELING_P3_WATCH_MICRO_MAP`
8. `SNORKELING_P3_PLANNED_VS_ACTUAL`
9. `SNORKELING_NO_CROSS_ACTIVITY_REGRESSION`

---

## 9. Build/test commands

```bash
xcodegen generate

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild test -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test

xcodebuild test -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17' test
```

---

## 10. Final acceptance criteria

| Gate | Criteria |
|------|----------|
| **P1_READY** | R1 REQUIRED closed; route+session sync visible; logbook meaningful; tests PASS; no regression |
| **P2_READY** | R2 REQUIRED closed; return primary verified; settings drive Watch; route summary visible |
| **P3_READY** | R3 QA PASS; micro-map/planned-vs-actual/export/analytics verified on device |
| **Release** | All above + full test suites PASS + QA evidence PASS — not before |

**Manual QA remains:** `MANUAL_UI_QA_PENDING` until R3-003 complete.

---

## Fix count summary

| Phase | Required | Optional | Blocked |
|-------|----------|----------|---------|
| R1 | 5 | 2 | 0 |
| R2 | 1 | 2 | 0 |
| R3 | 1 (QA) | 1 | 1 (heatmap) |
| **Total actionable** | **7** | **5** | **1** |

**Critical blockers:** R1-005, R1-007, R3-003 (QA)

---

## Next recommended command

```
Cursor AI: Execute Snorkeling R1 P1 Stabilization Remediation per Docs/SNORKELING_WATCH_P1_P2_P3_UNIFIED_REMEDIATION_PLAN_CURRENT.md — implement R1-001 R1-003 R1-005 R1-006 R1-007 only.
```

---

*End of unified remediation plan. No production code was modified during audit authoring.*
