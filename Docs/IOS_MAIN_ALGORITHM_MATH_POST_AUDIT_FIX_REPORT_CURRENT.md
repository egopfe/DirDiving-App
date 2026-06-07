# iOS MAIN algorithm math post-audit fix report (current)

**Source audit:** [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md)  
**Audit baseline:** `32f8d3e` (remediation) · audit re-run @ `af31937`  
**Branch:** `main`  
**Date:** 2026-06-07  
**Scope:** Non-physical gaps only — tests, docs, localization, labeling. No Bühlmann/CNS/OTU formula changes.

---

## Executive summary

Remaining **non-physical** items from the post-remediation audit were addressed: documentation baseline drift, dedicated automated tests (Briefing PDF, manual dive logic, Ratio Deco MOD violation, Watch depth alarm, reminder aggregation, photo pipeline), Watch localization hardening (semantic alarm keys + static sweep tests), logbook tissue simulation labeling, QA/release doc updates, and Briefing PDF pagination fix for Ratio Deco sections.

**Physical/external/App Store gates remain PENDING.** DIR DIVING remains **non-certified/reference-only**. **Bühlmann remains primary.** **Ratio Deco remains comparative heuristic only.**

---

## Issues / gaps addressed

| Area | Fix |
|------|-----|
| Documentation baseline | README/INDEX/RELEASE_CHECKLIST/MAIN_* updated to `af31937` audit re-run; post-audit report linked |
| Briefing PDF tests | `BriefingPDFBuilderTests` — profile, ascent, disclaimer, Ratio Deco payload delta |
| Briefing PDF layout | `BriefingPDFBuilder.ensureSpace(160)` before Ratio Deco block (multi-page when needed) |
| Manual dive logic | `ManualDiveEditorValidation` + `ManualDiveEditorLogicTests` |
| Ratio Deco MOD test | `IOSMainAlgorithmPostAuditTests.testRatioDecoMODViolationMarksIncompatibleAndDoesNotAlterBuhlmann` |
| Watch depth alarm | Integration tests with UserDefaults + recreated `DiveManager`; test hooks on `DiveManager` |
| Reminder hiddenCount | `testThreeSimultaneousRemindersExposeHiddenCount` |
| Watch photo pipeline | `WatchPhotoTransferPipelineTests` + WCSession E2E limitation documented |
| Watch localization | Semantic keys `watch.alarm.*`; `WatchLocalizationStaticSweepTests`; `log.share.csv.button` in log export |
| Logbook tissue labeling | `tissue_analytics.logbook.entry.subtitle`; DiveDetailView uses simulated copy |
| Future work doc | [`LOGBOOK_TISSUE_REPLAY_FUTURE_WORK.md`](LOGBOOK_TISSUE_REPLAY_FUTURE_WORK.md) |
| Subsurface consolidation | **Not attempted** — documented divergence retained (low risk) |

---

## Files changed

### iOS app
- `iOSApp/Utils/ManualDiveEditorValidation.swift` *(new)* — validation + synthetic session builder + `ManualDiveSampleBuilder`
- `iOSApp/Views/ManualDiveEditorView.swift` — uses validation helper
- `iOSApp/Services/PDF/BriefingPDFBuilder.swift` — page break before Ratio Deco
- `iOSApp/Views/DiveDetailView.swift` — logbook tissue subtitle key
- `iOSApp/Resources/en.lproj/Localizable.strings` — manual dive invalid depth, logbook tissue subtitle
- `iOSApp/Resources/it.lproj/Localizable.strings` — same

### Watch
- `Services/DiveManager.swift` — semantic alarm keys; test hooks
- `Views/DiveLogListView.swift` — `log.share.csv.button`
- `Resources/en.lproj/Localizable.strings` — `watch.alarm.*`
- `Resources/it.lproj/Localizable.strings` — `watch.alarm.*`

### Tests
- `Tests/iOSAlgorithmTests/BriefingPDFBuilderTests.swift` *(new)*
- `Tests/iOSAlgorithmTests/ManualDiveEditorLogicTests.swift` *(new)*
- `Tests/iOSAlgorithmTests/IOSMainAlgorithmPostAuditTests.swift` *(new)*
- `Tests/WatchAlgorithmTests/DiveManagerAlgorithmIntegrationTests.swift`
- `Tests/WatchAlgorithmTests/DiveReminderEngineTests.swift`
- `Tests/WatchAlgorithmTests/WatchLocalizationStaticSweepTests.swift` *(new)*
- `Tests/WatchAlgorithmTests/WatchPhotoTransferPipelineTests.swift` *(new)*
- `Tests/WatchAlgorithmTests/WatchMainUILocalizationTests.swift`

### Documentation
- `Docs/README.md`, `Docs/INDEX.md`, `Docs/RELEASE_CHECKLIST.md`
- `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md`, `Docs/MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`
- `Docs/LOGBOOK_TISSUE_REPLAY_FUTURE_WORK.md` *(new)*
- `Docs/IOS_MAIN_ALGORITHM_MATH_POST_AUDIT_FIX_REPORT_CURRENT.md` *(this file)*

### Build
- `project.yml` — `ManualDiveEditorValidation.swift`; iOS test bundle includes `iOSApp/Resources`

---

## Tests added / modified

**New iOS (13 tests):** `BriefingPDFBuilderTests` (3), `ManualDiveEditorLogicTests` (8), `IOSMainAlgorithmPostAuditTests` (2)

**New Watch (6 tests):** `WatchLocalizationStaticSweepTests` (4), `WatchPhotoTransferPipelineTests` (2)

**Modified Watch:** depth alarm (2), reminder hiddenCount (1), localization keys (1 class)

---

## Validation (2026-06-07)

### Pre-flight @ `af31937`

```
git branch --show-current  → main
git status -sb             → clean except this pass
git rev-parse --short HEAD → af31937 (before uncommitted post-audit changes)
xcodegen generate          → OK
```

### Post-fix commands

| Command | Destination | Result |
|---------|-------------|--------|
| `xcodegen generate` | — | **PASS** |
| `DIRDiving iOS` build | generic iOS Simulator | **PASS** |
| `DIRDiving iOS Algorithm Tests` | iPhone 17 Pro | **PASS** — **456 passed**, 13 skipped, 0 failures |
| `DIRDiving Watch App` build | generic watchOS Simulator | **PASS** |
| `DIRDiving Watch Algorithm Tests` | Apple Watch Ultra 3 (49mm) | **PASS** — **171 passed**, 13 skipped, 0 failures |

**Simulator substitution:** none — iPhone 17 Pro and Apple Watch Ultra 3 (49mm) used as specified.

---

## Static checks

| Check | Result |
|-------|--------|
| No new `try!` / `as!` in modified code | OK |
| No experimental files added to MAIN targets | OK |
| No App Store / certification overclaims in docs | OK |
| No Ratio Deco decompression-algorithm wording added | OK |
| Bühlmann ZHL-16C math unchanged | OK |
| CNS/OTU formulas unchanged | OK |
| Physical QA not marked complete | OK |

---

## Confirmations

- **Bühlmann math:** unchanged (only validation/tests/docs/labeling)
- **Ratio Deco:** heuristic/comparative only
- **DIR DIVING:** non-certified/reference-only
- **App Store readiness:** **not claimed**

---

## Remaining manual tasks (PENDING)

| Task | Status |
|------|--------|
| Apple Watch Ultra underwater / depth sensor QA | **PENDING** |
| Real underwater haptic QA | **PENDING** |
| Real GPS entry/exit lifecycle QA | **PENDING** |
| Paired iPhone + Apple Watch QA | **PENDING** |
| iCloud two-device QA | **PENDING** |
| External Bühlmann validation campaign | **PENDING** |
| Subsurface external import/export validation | **PENDING** |
| Accessibility Dynamic Type / VoiceOver manual matrix | **PENDING** |
| Legal review | **PENDING** |
| App Store review | **PENDING** |

---

## Readiness statement

| Gate | Status |
|------|--------|
| Code / automated tests / non-physical docs | **Complete** (this pass, pending commit @ current HEAD) |
| Internal TestFlight (engineering) | **Conditional PASS** — builds + 627 automated tests green |
| External TestFlight / App Store | **NOT ready** — physical/external gates pending |
