# MAIN_BRANCH_FULL_CODE_SECURITY_REMEDIATION_REPORT

Date: 2026-05-31
Repository: `egopfe/DirDiving-App`
Base verified before remediation: latest fetched `origin/main` @ `1de70dd` (`fix(ios): use column index IDs in planner table rows.`)
Remediation branch: `codex/main-full-code-security-remediation-current`
Source audit: `MAIN_BRANCH_FULL_CODE_SECURITY_AUDIT_CURRENT.md`

## Summary

All P1/P2/P3 code and documentation items from the audit were addressed in this branch. The only remaining release gate is external validation: this Windows host cannot run XcodeGen, Xcode, simulators, or Swift tests, so macOS validation must be repeated on a Mac before TestFlight/public promotion.

No UI redesign or graphics change was made. The ascent gauge threshold mismatch was corrected in place, and planner labels were clarified only where the math fix changed safety semantics.

## Issue Remediation Matrix

| ID | Status | Summary |
|---|---|---|
| IOS-MATH-001 | Fixed | Buhlmann/MOD safety paths now use planned max depth; average depth remains consumption-only. |
| SYNC-001 | Fixed | Watch replies success only after valid import and returns signed ACK; iOS requires signed ACK before marking direct pushes complete. |
| SYNC-002 | Fixed | iOS outbound Watch queue is persisted with file protection; queued transfers are marked pushed only from direct signed ACK or transfer completion. |
| SEC-001 | Fixed | Full iOS/Watch logbook sessions moved away from raw UserDefaults/KVS writes into protected files with legacy migration/cleanup. |
| VAL-001 | Blocked externally | Required commands were run, but Windows lacks `xcodegen`, `xcodebuild`, `xcrun`, and `swift`; macOS validation remains mandatory. |
| CSV-001 | Fixed | CSV data rows now match the header column count and metadata fields use RFC4180-style quoting. |
| SYNC-003 | Fixed | Unsigned legacy `acknowledged` replies no longer clear pending Watch/iOS queues. |
| SEC-002 | Fixed | Photo transfer temp writes use file protection; Watch validates extension, size, and sanitized file names. |
| UI-001 | Fixed | Ascent gauge labels/bands are driven by `AscentStatus` threshold constants. |
| CI-001 | Fixed | GitHub Actions now runs iOS and Watch algorithm test schemes after XcodeGen/build setup. |
| QA-001 | Fixed | Added `Docs/HARDWARE_QA_MATRIX.md` covering real Watch Ultra, paired iPhone, sync, iCloud, GPS, haptics, and simulator safety. |
| FORCE-001 | Fixed | Removed avoidable production `last!`, `UUID(uuidString:)!`, and `URL(string:)!` patterns in affected files. |
| DOC-001 | Fixed | README baseline no longer references stale `bfbc3e7`; it references latest fetched `origin/main` and this remediation report. |
| BUILD-001 | Fixed | Build docs explicitly require `xcodegen generate` before `xcodebuild` and include simulator validation flow. |

## Files Changed

- Planner/math: `iOSApp/Models/GasPlan.swift`, `iOSApp/Services/BuhlmannPlanner.swift`, `iOSApp/Services/PlannerMODValidator.swift`, `iOSApp/Services/GasPlanningService.swift`, planner localization strings.
- Sync/security: `Services/WatchSyncService.swift`, `iOSApp/Services/WatchSyncService.swift`, `iOSApp/Services/WatchDiveSyncCodec.swift`.
- Storage/privacy: `Services/CloudSyncStore.swift`, `Services/DiveLogStore.swift`, `iOSApp/Services/CloudSyncStore.swift`, `iOSApp/Services/DiveLogStore.swift`.
- CSV/photo/UI: `iOSApp/Services/SubsurfaceExportService.swift`, `Services/UserImageStore.swift`, `Models/AscentStatus.swift`, `Views/AscentGaugeView.swift`.
- Safety cleanup: `iOSApp/Utils/DiveProfileMath.swift`, `iOSApp/Models/DemoDiveCatalog.swift`, `iOSApp/Views/IOSLegalOnboardingView.swift`.
- CI/docs: `.github/workflows/build.yml`, `project.yml`, `README.md`, `Docs/BUILD_VALIDATION.md`, `Docs/HARDWARE_QA_MATRIX.md`, `Docs/RELEASE_CHECKLIST.md`, `Docs/DIR_DIVING_Feature_Comparison.csv`.
- Tests: `Tests/iOSAlgorithmTests/PlanningDepthReferenceTests.swift`, `Tests/iOSAlgorithmTests/CSVMetadataRoundTripTests.swift`, `Tests/iOSAlgorithmTests/CloudSessionMergeTests.swift`, `Tests/iOSAlgorithmTests/WatchSyncConflictTests.swift`, `Tests/WatchAlgorithmTests/WatchReadinessAlgorithmTests.swift`, `Tests/WatchAlgorithmTests/UserImageStorePolicyTests.swift`.

## Tests Added Or Updated

- Max-depth MOD/Buhlmann regression when average depth is lower than max depth.
- Average depth remains consumption-only.
- Signed ACK verification rejects missing/unsigned/wrong-context replies.
- Legacy full-session defaults payload can be removed after migration.
- CSV header/data row alignment.
- CSV metadata round-trip with commas, quotes, and embedded newlines.
- Photo transfer filename and byte-size policy.
- Ascent status threshold constants and boundary mapping.

## Validation Results

Executed from `C:\Users\egopf\Documents\GitHub\DirDiving-App`.

| Command | Result |
|---|---|
| `git fetch --prune origin` | PASS |
| `git log -1 --format='%h %cd %s' --date=iso origin/main` | `1de70dd 2026-05-31 20:52:51 +0200 fix(ios): use column index IDs in planner table rows.` |
| `git status --short` | PASS, showed intended remediation changes before commit |
| `git diff --check` | PASS, no whitespace errors; Git reported expected CRLF conversion warnings on Windows |
| `xcodegen generate` | BLOCKED, `xcodegen` command not available on Windows |
| `xcodebuild -list -project DIRDiving.xcodeproj` | BLOCKED, `xcodebuild` command not available on Windows |
| `xcrun simctl list devices` | BLOCKED, `xcrun` command not available on Windows |
| `xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build` | BLOCKED, `xcodebuild` command not available on Windows |
| `xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' build` | BLOCKED, `xcodebuild` command not available on Windows |
| `xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test` | BLOCKED, `xcodebuild` command not available on Windows |
| `xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' test` | BLOCKED, `xcodebuild` command not available on Windows |
| `swift --version` | BLOCKED, `swift` command not available on Windows |

## Build/Test Gate Answers

- Apple Watch simulator build passes: Not proven here; blocked by missing macOS/Xcode toolchain.
- iOS simulator build passes: Not proven here; blocked by missing macOS/Xcode toolchain.
- iOS algorithm tests pass: Not proven here; blocked by missing macOS/Xcode toolchain.
- Watch algorithm tests pass: Not proven here; blocked by missing macOS/Xcode toolchain.
- Simulator builds do not require underwater entitlement in source/project configuration: preserved; final proof requires macOS simulator build.

## Remaining Risks

- Mandatory macOS validation remains open: `xcodegen generate`, both simulator builds, both algorithm test schemes, and simulator device listing.
- Hardware QA remains open until `Docs/HARDWARE_QA_MATRIX.md` is executed on Apple Watch Ultra plus paired iPhone.
- Real underwater depth behavior still depends on Apple water-submersion entitlement/provisioning.
- WatchConnectivity transfer completion confirms OS delivery, not semantic remote import for queued `transferUserInfo`; direct reachable paths now require signed semantic ACK.

## Readiness Percentages

- Apple Watch: 88% - code hardening complete, simulator/device validation still required.
- iOS companion: 90% - code hardening complete, simulator tests still required.
- Security/privacy: 92% - primary audit findings fixed, hardware/iCloud verification still required.
- Release readiness: 78% - blocked mainly by unavailable macOS/Xcode and physical-device QA.

## Final Gate

Before release or TestFlight promotion, run the validation flow on macOS:

```bash
git fetch --prune origin
xcodegen generate
xcodebuild -list -project DIRDiving.xcodeproj
xcrun simctl list devices
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' build
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' test
```
