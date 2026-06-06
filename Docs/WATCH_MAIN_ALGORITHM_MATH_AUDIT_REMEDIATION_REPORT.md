# Apple Watch MAIN Algorithm / Safety / Runtime Remediation Report

**Remediation date:** 2026-06-06  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch:** `main`  
**Audit baseline commit:** `5415213` (source: [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md))  
**Remediation applied on commit:** `c2f5068` + working-tree changes (uncommitted at report time)  
**Target:** `DIRDiving Watch App` only  
**Scope:** Code, tests, and static documentation — **excluding physical QA**

---

## A. Branch confirmed

`main`

## B. Commit confirmed

- Audit read baseline: `5415213`
- Watch audit doc committed: `c2f5068`
- Remediation edits: working tree on `main` (post-`c2f5068`)

## C. Target confirmed

- **DIRDiving Watch App** (Watch MAIN)
- Watch algorithm test scheme: **DIRDiving Watch Algorithm Tests**
- iOS code touched only where shared export column policy required no model change

## D. Experimental exclusions confirmed

`project.yml` continues to exclude from Watch MAIN:

- `Views/ApneaView.swift`, `SnorkelingView.swift`, `BuddyAssistView.swift`, `ExperimentalConceptsView.swift`
- `Utils/ExperimentalFeatures.swift`
- Buddy / Exploration models and services (`BuddyAssist*`, `Exploration*`, `SecureBuddyStore`, etc.)

No experimental files were modified during remediation.

## E. Files modified

| Area | Files |
|---|---|
| Core runtime | `Services/DiveManager.swift`, `Services/DiveLogStore.swift`, `Services/GPSManager.swift`, `Services/AppleDepthSensorProvider.swift`, `Services/DepthLimitHapticCoordinator.swift`, `Services/SubsurfaceExportService.swift`, `Services/WatchDiveSyncCodec.swift` |
| Validation / utils | `Utils/DepthSampleValidation.swift`, `Utils/DepthSensorSourceResolution.swift` (new) |
| UI | `Views/DiveLiveView.swift`, `Views/SettingsView.swift`, `Views/InfoView.swift` |
| Localization | `Resources/en.lproj/Localizable.strings`, `Resources/it.lproj/Localizable.strings` |
| Project | `project.yml` |
| Tests | `Tests/WatchAlgorithmTests/DiveManagerAlgorithmIntegrationTests.swift`, `WatchMainAlgorithmAuditRemediationTests.swift`, `WatchMainAlgorithmRemediationPhaseTests.swift` (new), `DiveAlgorithmTests.swift`, `WatchReadinessAlgorithmTests.swift`, `WatchSyncCodecAlgorithmTests.swift` |
| Docs | This report, [`WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md`](WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md), [`WATCH_CSV_EXPORT_POLICY.md`](WATCH_CSV_EXPORT_POLICY.md), updates to [`SUBSURFACE_CSV_ROUNDTRIP.md`](SUBSURFACE_CSV_ROUNDTRIP.md), [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) |

## F. Issues fixed by ID

### WATCH-TEST-001 — DiveManager integration test isolation

**Status:** Fixed  
Per-test temp directory for drafts and log storage; `DiveManager.testHook_suppressDepthSensorProvider` stops Mock 1 Hz 0 m timer contamination; tearDown clears hooks and temp dirs.

### WATCH-S2-001 — Mock/simulator frozen-depth false warning at stable 0 m

**Status:** Fixed  
`DepthSampleValidation` accepts `exemptMockSurfaceFrozenSamples`; `DiveManager` passes `isSimulationDepthActive`. Mock/simulation stable surface band during active simulation no longer surfaces user-facing frozen-depth warning. Real active dive frozen detection unchanged.

### WATCH-S2-002 — Automatic Mock fallback visibility

**Status:** Fixed  
`DepthSensorSourceResolution` + `@Published isDepthAutomationMockFallbackActive` on `DiveManager`. Persistent badge in `DiveLiveView`; resolved source in Settings/Info. Localized EN/IT copy per audit spec.

### WATCH-LC-001 — Legacy active draft without phase restores ambiguously

**Status:** Fixed  
`supportedDraftSchemaVersion = 1`; decode requires `schemaVersion`; legacy drafts without version/phase discarded and quarantined — no ambiguous active restore.

### WATCH-LC-002 — Finalizing draft missing endDate discarded silently

**Status:** Fixed  
Finalizing draft without `endDate` quarantined; `@Published draftRecoveryDiagnostic` surfaced in Info; localized diagnostic string. No fake session, no active restore.

### WATCH-GPS-001 — GPS authorization callback restarts updates after dive end

**Status:** Fixed  
`GPSManager.maintainsLocationUpdates`; authorization callback starts updates only when capture or dive-managed GPS is active.

### WATCH-EXP-001 — Watch CSV export parity / policy

**Status:** Fixed (aligned + documented)  
Watch export aligned to iOS hardened column set and first-sample-relative monotonic `time_seconds`. Watch-specific metadata marker `# dirdiving_watch_export: 1`. Policy locked in [`WATCH_CSV_EXPORT_POLICY.md`](WATCH_CSV_EXPORT_POLICY.md).

### WATCH-S2-003 — Depth sample timestamp source

**Status:** Documented + test-locked  
Receipt-time policy documented in `AppleDepthSensorProvider`; staleness relies on callback-silence watchdog. No unsafe CoreMotion timestamp adoption without hardware validation.

### WATCH-UX-001 — Manual end hidden after submersion handoff

**Status:** Fixed (copy)  
`manualStartHandedOffToAutomatic` + localized handoff note in `DiveLiveView`. Auto surface-end semantics preserved; no unconfirmed underwater stop button.

### WATCH-S15-002 — Depth-limit haptic resync on preference toggle

**Status:** Fixed  
`DepthLimitHapticCoordinator.refreshAfterPreferenceChange`; `DiveManager.resyncHapticsAfterPreferenceChange()` calls depth-limit coordinator symmetrically with ascent haptics.

### WATCH-SYNC-001 — Imported companion ID dedup cap

**Status:** Fixed  
Cap raised from 128 → **512** (`WatchDiveSyncCodec.importedCompanionIDRetentionLimit`); deterministic tail retention; test-locked.

### WATCH-S7-001 — 40 m safety/ascent band split (INFO)

**Status:** Protected  
Intentional split preserved. Existing tests in `WatchMainAlgorithmAuditRemediationTests` / `DiveAlgorithmTests` lock 40.0 m exceeded + ascent band policy.

### WATCH-TTV-001 — TTV acronym clarity (INFO)

**Status:** Protected  
Copy remains explicit: TTV = time-weighted average depth × runtime minutes; not NDL/TTS/decompression. No semantic change.

## G. Tests added

| Test file | New / updated coverage |
|---|---|
| `WatchMainAlgorithmRemediationPhaseTests.swift` | Legacy draft discard, finalizing missing endDate diagnostic, mock frozen exemption, GPS flag, dedup 512 cap, haptic preference refresh |
| `DiveManagerAlgorithmIntegrationTests.swift` | Full rewrite with per-test isolation |
| `WatchMainAlgorithmAuditRemediationTests.swift` | Isolated log storage; haptic UserDefaults hygiene |
| `WatchReadinessAlgorithmTests.swift` | First-sample CSV time origin |
| `WatchSyncCodecAlgorithmTests.swift` | First-sample CSV time origin |
| `DiveAlgorithmTests.swift` | Updated export header assertions |

## H. Tests run

```
xcodegen generate                                    → PASS
xcodebuild -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build → PASS

xcodebuild -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test
```

| Metric | Before remediation | After remediation |
|---|---:|---:|
| Executed | 113 | **120** |
| Skipped | 3 | 3 |
| Failures | **21** (all `DiveManagerAlgorithmIntegrationTests`) | **0** |
| Result | TEST FAILED | **TEST SUCCEEDED** |

Targeted suites verified green as part of full run:

- `DiveManagerAlgorithmIntegrationTests`
- `WatchMainAlgorithmAuditRemediationTests`
- `WatchMainAlgorithmRemediationPhaseTests`
- `MissionModeAlgorithmInvariantTests`
- `GPSLifecycleTests`

## I. Build results

| Command | Result |
|---|---|
| `xcodegen generate` | PASS |
| `DIRDiving Watch App` build (watchOS Simulator, unsigned) | **BUILD SUCCEEDED** |
| `DIRDiving Watch Algorithm Tests` | **TEST SUCCEEDED** (120 executed, 0 failures) |

## J. Remaining physical QA

Cannot be completed in code. Required before external TestFlight / App Store:

| Gate | Item |
|---|---|
| Depth entitlement | Real Apple Watch Ultra water-submersion entitlement + provisioning |
| Underwater depth | Live depth stream, auto start @ 1 m, auto stop @ 0.3 m / 8 s surface dwell |
| Frozen / stale sensor | Real sensor stuck vs callback silence on hardware |
| Mock fallback UX | Non-Ultra device shows fallback badge; simulation badge distinct |
| GPS | Entry/exit capture, late permission grant after dive end (no restart) |
| Haptics | Depth-limit + ascent pulses on wrist; disable/enable during delayed pulse |
| Sync | Paired Watch ↔ iPhone tombstone, pending queue, signed ACK |
| Action Button / App Intents | Hardware shortcut execution after legal gate |
| VoiceOver / Dynamic Type | Watch Live readability |

See [`WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md`](WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md) and [`WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`](WATCH_ULTRA_PHYSICAL_QA_MATRIX.md).

## K. Remaining risks

| Risk | Mitigation |
|---|---|
| Receipt-time depth timestamps vs sensor time | Documented; stale callback watchdog is primary guard |
| Legacy users with pre-schema drafts | Discarded safely; quarantine under Diagnostics |
| CSV round-trip iOS ↔ Watch | Column-aligned; Watch omits iOS-only metadata fields (equipment/pressure) — documented |
| Simulator cannot validate real haptics / submersion | Physical QA matrix required |
| 512 companion ID cap still bounded | Older IDs may re-import after cap overflow — documented policy |

## L. Final readiness estimate

| Dimension | Pre-audit | Post-remediation (excl. physical QA) |
|---:|---:|---:|
| Watch MAIN algorithm readiness | 93% | **~98%** |
| Mathematical robustness | 94% | **~96%** |
| Safety algorithm confidence | 90% | **~93%** (physical haptics/depth still open) |
| Runtime / lifecycle confidence | 93% | **~98%** |
| Sync / data confidence | 91% | **~94%** |
| Mission Mode safety | 96% | **96%** |
| App Intents safety | 95% | **95%** |
| Test coverage confidence | 87% | **~97%** |

**Overall Watch MAIN readiness excluding physical QA: ~97–98%**

## M. Confirmation

| Constraint | Status |
|---|---|
| MAIN branch only | ✓ |
| Watch MAIN target only (shared codec unchanged at model level) | ✓ |
| Experimental branches / features untouched | ✓ |
| No UI redesign / Watch visual identity change | ✓ |
| TTV semantics unchanged | ✓ |
| No NDL / TTS / decompression on Watch | ✓ |
| Mission Mode remains non-mathematical | ✓ |
| App Intents remain legal-gated | ✓ |
| Sensor simulation policy preserved | ✓ |
| No certified dive-computer claim introduced | ✓ |
| Safety / legal disclaimers preserved | ✓ |
| Physical QA not falsely marked complete | ✓ |

---

## Policy summaries (quick reference)

| Topic | Policy |
|---|---|
| Integration tests | Isolated temp dirs; mock provider suppressed in tests |
| Mock frozen 0 m | Exempt user-facing frozen warning when simulation active + surface band |
| Mock fallback | Persistent badge when `.automatic` resolves to mock |
| Draft schema | Version 1 required; legacy without version discarded |
| Corrupt finalizing draft | Quarantine + Info diagnostic; no silent loss |
| GPS auth callback | Start updates only if capture/dive GPS still active |
| CSV export | First-sample-relative monotonic seconds; iOS column parity |
| Timestamp | Receipt time; stale via callback silence |
| Manual end UX | Handoff copy after submersion; auto surface-end unchanged |
| Depth-limit haptics | Preference toggle cancels/resyncs delayed pulses |
| Sync dedup | 512 most recent companion import IDs retained |
| 40 m split | Intentional safety exceeded + ascent band boundary |
| TTV | Informational index only |
