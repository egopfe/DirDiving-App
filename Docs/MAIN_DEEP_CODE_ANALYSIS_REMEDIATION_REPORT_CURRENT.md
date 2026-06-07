# MAIN Deep Code Analysis Remediation Report (Current)

Baseline commit before remediation work: `4a80c54`  
Validation performed on branch: `main`  
Report date: 2026-06-07

## Issues fixed

| ID | Priority | Summary | Status |
|---|---|---|---|
| MAIN-AUD-001 | P1 | iOS queued `transferUserInfo` no longer clears outbound pending without signed Watch import ACK | Fixed |
| MAIN-AUD-002 | P2 | Companion photo inventory/delete requests and ACKs signed with HMAC peer-secret model | Fixed |
| MAIN-AUD-003 | P2 | Cloud payload size checked before local write; oversize does not overwrite valid local data | Fixed |
| MAIN-AUD-004 | P2 | PDF exports written to protected Application Support directory with cleanup | Fixed |
| MAIN-AUD-005 | P2 | Photo preprocessing preflights bytes/dimensions; heavy work off MainActor | Fixed |
| MAIN-AUD-006 | P2 | Pressure edits preserve switch depth; gas/PPO2 edits still clamp to MOD | Fixed |
| MAIN-AUD-007 | P2 | Planner recalculation/persistence debounced; analysis cache added | Fixed |
| MAIN-AUD-008 | P3 | iOS logbook delete offsets index-guarded | Fixed |
| MAIN-AUD-009 | P3 | Planner table accessibility helper no longer force-unwraps headers | Fixed |
| MAIN-AUD-010 | P3 | Cloud sync `isSynchronizing` uses generation token to avoid stale clears | Fixed |
| MAIN-AUD-011 | P4 | CSV malformed quote handling hardened; large-file budget tests added | Fixed |
| MAIN-AUD-012 | P3 | Sync schema v2 nonce + bounded replay cache (v1 still accepted) | Fixed |
| MAIN-AUD-015 | P4 | Merge conflict detector uses safe dictionary builder | Fixed |
| MAIN-AUD-016 | P4 | Legacy `GasMixCard` documented as test/preview-only `EmptyView` | Documented |
| MAIN-AUD-013 | P1 | xcodegen/build/tests executed (see below) | Done |
| MAIN-AUD-014 | P1 | Physical/external QA checklist created (all items PENDING) | Documented |

## Files changed

### Sync / security
- `iOSApp/Services/WatchSyncService.swift`
- `iOSApp/Services/IOSWatchSyncPendingTransfer.swift` (new)
- `iOSApp/Services/WatchDiveSyncCodec.swift`
- `Services/WatchDiveSyncCodec.swift`
- `Services/WatchSyncService.swift`
- `iOSApp/Utils/WatchSyncKeys.swift`
- `Utils/WatchSyncKeys.swift`
- `iOSApp/Utils/CompanionPhotoManagementSupport.swift`
- `Utils/CompanionPhotoManagementSupport.swift`
- `iOSApp/Utils/CompanionPhotoManagementAuth.swift` (new)
- `Utils/CompanionPhotoManagementAuth.swift` (new)
- `iOSApp/Utils/SyncNonceReplayCache.swift` (new)
- `Utils/SyncNonceReplayCache.swift` (new)

### Privacy / performance / planner / crash hardening
- `iOSApp/Services/CloudSyncStore.swift`
- `iOSApp/Services/PDF/PDFDocumentBuilder.swift`
- `iOSApp/Services/WatchPhotoPreprocessor.swift`
- `iOSApp/Views/WatchPhotoTransferPanel.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Views/PlannerCylinderGasEditorView.swift`
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Services/DiveLogStore.swift`
- `iOSApp/Utils/DiveSessionMergeConflict.swift`
- `iOSApp/Services/DiveImportService.swift`
- `iOSApp/Utils/IOSAlgorithmConfiguration.swift`
- `iOSApp/Views/PlannerGasMixCard.swift`

### Tests / project / docs
- `Tests/iOSAlgorithmTests/MainDeepCodeAuditRemediationTests.swift` (new)
- `Tests/iOSAlgorithmTests/CloudSessionMergeTests.swift`
- `Tests/iOSAlgorithmTests/CompanionPhotoManagementIOSTests.swift`
- `Tests/WatchAlgorithmTests/CompanionPhotoManagementTests.swift`
- `project.yml`
- `Docs/MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md` (new)
- `Docs/MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md` (this file)

## Tests added / modified

### Added
- `Tests/iOSAlgorithmTests/MainDeepCodeAuditRemediationTests.swift` — coverage for AUD-001..012, 015, partial 004–011

### Modified
- `Tests/iOSAlgorithmTests/CloudSessionMergeTests.swift` — oversize payload must not overwrite local value
- `Tests/iOSAlgorithmTests/CompanionPhotoManagementIOSTests.swift` — signed response/ACK parsing
- `Tests/WatchAlgorithmTests/CompanionPhotoManagementTests.swift` — signed request verification + replay

Existing Watch sync integration tests (`WatchSyncServiceIntegrationTests`) continue to validate queued delivery vs signed ACK behavior on Watch→iPhone path.

## Commands run and results

### Preflight
```
git branch --show-current  → main
git status -sb             → modified Docs/INDEX.md (pre-existing) + remediation changes
git rev-parse --short HEAD → 4a80c54 (at task start)
```

### xcodegen
```
xcodegen generate → SUCCEEDED
```

### Builds
| Command | Result |
|---|---|
| `xcodebuild -scheme "DIRDiving Watch App" -destination 'generic/platform=watchOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build` | **SUCCEEDED** |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build` | **SUCCEEDED** (after DerivedData lock retry) |

### Tests
| Command | Result |
|---|---|
| `xcodebuild -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test` | **SUCCEEDED** — 171 executed, 13 skipped, 0 failures |
| `xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test` | **SUCCEEDED** — 415 executed, 13 skipped, 0 failures |

Simulator substitutions: none required (requested simulators were available).

### Commands that could not run initially
- iOS build first attempt failed with DerivedData database lock because Watch and iOS builds ran concurrently. Retried sequentially → **SUCCEEDED**.

## Static checks (modified code)
- No new `try!` / `as!` in modified production files (spot-checked via search).
- No hardcoded secrets added.
- Experimental targets/files were not modified.
- No release-visible simulation-only behavior added.

## Remaining manual QA gates

See `Docs/MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md` — **all items PENDING**, including:
- Watch Ultra underwater depth sensor QA
- Paired direct/queued sync with signed ACK rejection paths
- iCloud two-device conflict/tombstone tests
- PDF/CSV privacy on device
- Subsurface import/export validation on real exports

## Scope / safety confirmations
- Experimental files (Apnea, Snorkeling, Buddy Assist, Exploration) were **not** touched.
- Legal/safety disclaimers, onboarding gates, depth warnings, and reference-only positioning were **not** weakened.
- Bühlmann math, gas-planning semantics, TTV, Mission Mode, and planner mode architecture were **not** changed.
- **No** Internal TestFlight, External TestFlight, or App Store readiness claim is made by this report.
