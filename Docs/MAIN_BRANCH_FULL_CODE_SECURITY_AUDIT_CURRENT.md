# MAIN_BRANCH_FULL_CODE_SECURITY_AUDIT_CURRENT

Audit date: 2026-05-31  
Repository: `egopfe/DirDiving-App`  
Audited branch: `origin/main`  
Audited commit: `1de70dd` (`fix(ios): use column index IDs in planner table rows.`)  
Scope: Apple Watch app, iOS companion app, shared sync/import/export/security/math paths.  
Constraint followed: audit/report only; no production code modified.

## Executive Summary

The local repository and local `main` branch were synchronized to the latest remote `origin/main` before this report was written. The current working audit branch is also based directly on `origin/main` at `1de70dd`.

The codebase has several strong release-hardening improvements already present on main:

- Watch active-depth callback silence is monitored through `DiveAlgorithmConfiguration.activeDepthCallbackSilenceSeconds` and `DiveManager.evaluateDepthCallbackFreshness`.
- Watch GPS no-fix/fallback/fix presentation is explicit and color-coded.
- Watch manual no-depth sessions now have an explicit policy and iOS sync path.
- Watch runtime and stopwatch use `MonotonicElapsedClock`.
- Watch/iOS sync payloads are HMAC-signed, size-bounded, bundle-checked, and skew-limited.
- iOS Buhlmann, gas, import/export, cloud-merge, and manual/no-depth behavior have substantial algorithm tests.

However, main is not ready for broad external release yet. The most important blockers are:

- iOS planner can use average depth as the Buhlmann/MOD reference, which can hide max-depth MOD violations and understate decompression pressure.
- iOS-to-Watch sync can mark a dive as pushed even when the Watch import failed or a queued transfer has not actually completed.
- Full dive logs containing GPS and notes are still written through `UserDefaults`/iCloud KVS by the shared cloud store, despite other sync-conflict data being moved to protected files.
- Current audit host cannot run Xcode, `xcodebuild`, or simulator validation; latest commit therefore remains unbuilt in this environment.

Issue count: P0 = 0, P1 = 4, P2 = 7, P3 = 3, INFO = 4.

Readiness verdict: Not release-ready until P1 items are fixed and macOS/Xcode validation passes on the latest commit.

## Severity Classification

- P0: Immediate crash, data loss, or unsafe behavior that should block all testing.
- P1: Release blocker for TestFlight/public testing, security/privacy exposure, or safety math/data-integrity defect.
- P2: Important hardening, reliability, or UX issue that should be fixed before broad testing.
- P3: Low-risk correctness, maintainability, or polish issue.
- INFO: Observation, positive control, or validation note.

## Validation Commands

Executed from `C:\Users\egopf\Documents\GitHub\DirDiving-App`.

| Command | Result |
|---|---|
| `git fetch --prune origin` | PASS |
| `git pull --ff-only origin main` | PASS, updated to `1de70dd` |
| `git branch -f main origin/main` after ancestor check | PASS, local `main` now matches `origin/main` |
| `git status -sb` | PASS, clean before report edit |
| `git log -1 --format='%h %cd %s' --date=iso` | `1de70dd 2026-05-31 20:52:51 +0200 fix(ios): use column index IDs in planner table rows.` |
| `gh pr status --repo egopfe/DirDiving-App` | PASS, open PRs #8, #9, #10 all report failing checks |
| `xcodebuild -list -project DIRDiving.xcodeproj` | BLOCKED, `xcodebuild` not available on Windows |
| `xcodebuild -scheme "DIRDiving iOS" ... build` | BLOCKED, `xcodebuild` not available on Windows |
| `xcodebuild -scheme "DIRDiving Watch App" ... build` | BLOCKED, `xcodebuild` not available on Windows |
| `xcrun simctl list devices` | BLOCKED, `xcrun` not available on Windows |

Static searches performed:

- Force unwrap / risky Swift search: `try!`, `as!`, `fatalError`, `precondition`, `assertionFailure`, `UUID(uuidString:)!`, `URL(string:)!`.
- Sensitive API search: `CMWaterSubmersionManager`, `HKHealthStore`, `CLLocationManager`, `WCSession`, `UserDefaults`, `FileManager`, `Keychain`, `SecItem`, `NSUbiquitousKeyValueStore`, URLs.
- TODO/security search: `TODO`, `FIXME`, `password`, `secret`, `token`, `privateKey`, `credential`.
- Test inventory: 187 XCTest functions found, 31 Watch algorithm tests and 156 iOS algorithm tests.

## Complete Issue Table

| ID | Severity | Area | Finding | Primary Evidence | Recommended Fix |
|---|---:|---|---|---|---|
| IOS-MATH-001 | P1 | iOS planner/math | Average-depth reference is used for Buhlmann max depth and bottom-gas MOD checks, so max-depth hazards can be hidden. | `iOSApp/Models/GasPlan.swift:347`, `iOSApp/Services/BuhlmannPlanner.swift:255`, `iOSApp/Services/PlannerMODValidator.swift:51`, `Tests/iOSAlgorithmTests/PlanningDepthReferenceTests.swift:30` | Use planned max depth for MOD and conservative decompression checks, or make average-depth mode explicitly non-decompression/non-MOD and block safety claims. |
| SYNC-001 | P1 | iOS -> Watch sync | Watch always replies `acknowledged` to direct iOS messages after attempting import, even if parsing/import failed. iOS marks direct reply as pushed without checking status/signature. | `Services/WatchSyncService.swift:358`, `iOSApp/Services/WatchSyncService.swift:303` | Mirror the iOS signed ACK path on Watch, return `failed` on import failure, and have iOS remove queue only after signed ACK. |
| SYNC-002 | P1 | iOS -> Watch sync | Offline iOS `transferUserInfo` path marks sessions pushed and removes them immediately, with no persisted outbound queue and no `didFinish userInfoTransfer` handling. | `iOSApp/Services/WatchSyncService.swift:317`, absence of iOS `didFinish userInfoTransfer` delegate | Persist outbound queue with file protection; mark pushed only after direct signed ACK or transfer completion callback. |
| SEC-001 | P1 | Privacy/storage | Full logbook sessions with GPS/notes are saved through `UserDefaults` and iCloud KVS by `CloudSyncStore`, while only some conflict/pending data uses protected files. | `iOSApp/Services/CloudSyncStore.swift:112`, `iOSApp/Services/DiveLogStore.swift:230`, `Services/CloudSyncStore.swift:78`, `Services/DiveLogStore.swift:170` | Move primary logbook persistence to protected files and make cloud sync opt-in/clearly disclosed or encrypted. |
| VAL-001 | P1 | Build/release gate | Latest main commit could not be compiled or tested in this Windows audit environment. | blocked `xcodebuild`/`xcrun` commands | Run `xcodegen generate`, app builds, and XCTest on macOS for latest `1de70dd` or later. |
| CSV-001 | P2 | iOS import/export | iOS Subsurface CSV header declares 12 columns, but data rows write 7 columns. Metadata escaping doubles quotes but does not quote fields with commas/newlines. | `iOSApp/Services/SubsurfaceExportService.swift:29`, `:38`, `:50`, `:74` | Make data rows match header or shrink header; implement real RFC4180 quoting for metadata fields. |
| SYNC-003 | P2 | Watch -> iOS sync | Watch accepts legacy plain `"acknowledged"` replies and removes pending sessions even when no signed ACK is present. | `Services/WatchSyncService.swift:193`, `:199`, `:205` | Remove legacy ACK fallback once minimum iOS build is bumped; require signed ACK. |
| SEC-002 | P2 | Photo transfer | iOS writes Watch photo transfer temp files with `.atomic` only, and Watch import trusts metadata file name without extension/size validation. | `iOSApp/Services/WatchSyncService.swift:124`, `Services/WatchSyncService.swift:302`, `Services/UserImageStore.swift:47` | Use `.completeFileProtection`, whitelist image extensions, bound file size, normalize file name on Watch. |
| UI-001 | P2 | Watch ascent UX | Ascent status turns yellow above 70 percent of the limit, while gauge labels/bands imply 75 percent/even thirds. | `Models/AscentStatus.swift:19`, `Views/AscentGaugeView.swift:44`, `:68` | Drive gauge bands and labels from the same thresholds used by `AscentStatus`. |
| CI-001 | P2 | CI/test coverage | GitHub Actions builds apps but does not run the Watch/iOS XCTest schemes; open PRs #8/#9/#10 show failing checks. | `.github/workflows/build.yml:68`, `:81`; `gh pr status` | Add `xcodebuild test` steps for both algorithm test schemes and keep PR checks required. |
| QA-001 | P2 | Device QA | Depth automation, water-submersion entitlement, haptics, GPS surface capture, WatchConnectivity, and iCloud KVS require real device/simulator validation not available here. | `Config/DIRDiving.entitlements`, `App/Info.plist`, blocked `xcrun` | Execute the documented hardware/device matrix on Apple Watch Ultra and paired iPhone. |
| FORCE-001 | P3 | Swift safety | Production force unwraps remain in static constants and iOS profile math. The profile math unwraps are guarded by non-empty arrays, but the pattern is still avoidable. | `iOSApp/Utils/DiveProfileMath.swift:94`, `:127`; `iOSApp/Models/DemoDiveCatalog.swift:5`; `iOSApp/Views/IOSLegalOnboardingView.swift:4` | Replace `sorted.last!` with bound `last`; use non-optional URL/UUID builders or guarded static initialization. |
| DOC-001 | P3 | Documentation | README baseline still references an old main commit, not current `origin/main`. | `README.md:7` | Update README baseline after latest main synchronization. |
| BUILD-001 | P3 | Local build workflow | `DIRDiving.xcodeproj` is generated and gitignored; pasted command using `xcodebuild -project DIRDiving.xcodeproj` must be preceded by `xcodegen generate`. | `Docs/BUILD_VALIDATION.md:6`, no committed `.xcodeproj` | Keep docs explicit and ensure automation always runs XcodeGen first. |
| WATCH-INFO-001 | INFO | Watch algorithms | Active depth callback freshness watchdog is present and tied to the runtime timer. | `Utils/DiveAlgorithmConfiguration.swift:10`, `Services/DiveManager.swift:319` | Keep regression tests. |
| WATCH-INFO-002 | INFO | Watch GPS truthfulness | GPS confirmation now differentiates fix, fallback, and no-fix with distinct icon/color. | `Views/DiveLiveView.swift:143`, `:174` | Keep device QA around no-fix/fallback cases. |
| WATCH-INFO-003 | INFO | Manual no-depth policy | Watch and iOS now agree that manual no-depth sessions may sync without fabricated samples. | `Services/DiveLogStore.swift:53`, `iOSApp/Services/WatchDiveSyncCodec.swift:184`, `Docs/WATCH_MANUAL_NODEPTH_SYNC_POLICY.md` | Keep sync and export tests. |
| IOS-INFO-001 | INFO | Test inventory | Algorithm test suite is substantial: 187 XCTest functions found across Watch and iOS algorithm targets. | `Tests/WatchAlgorithmTests`, `Tests/iOSAlgorithmTests` | Add CI execution, UI/device tests, and signed ACK regression tests. |

## Apple Watch Findings

### Positive Controls

- `CMWaterSubmersionManager` integration is present in `Services/DiveManager.swift`.
- Automatic lifecycle uses validated samples and dwell logic through `DiveLifecycleAlgorithm`.
- Depth callback silence now sets stale/last-known flags in `DiveManager.evaluateDepthCallbackFreshness`.
- Runtime and stopwatch use `MonotonicElapsedClock`, reducing wall-clock skew risk.
- Manual no-depth sessions are classified and can sync without fake depth samples.
- Local Watch log and pending sync files use `.completeFileProtection`.
- GPS presentation distinguishes real fix, fallback point, and no fix.
- Depth-limit haptics re-check user preference before delayed pulses.

### Watch Release Risks

SYNC-001 and SYNC-002 affect the Watch app as receiver of iOS companion pushes. A failed Watch import can still cause the iOS side to mark a session as delivered. This is the main Watch data-integrity blocker.

UI-001 is a user-facing safety-presentation risk: the visual ascent gauge should not imply a threshold different from the algorithm that drives warnings.

QA-001 remains mandatory because water-submersion, haptics, WatchConnectivity, GPS surface capture, and Apple entitlement behavior cannot be proven from static Windows analysis.

## iOS Companion Findings

### Positive Controls

- Buhlmann ZHL-16C N2+He engine is present with validation, gradient factors, gas switching, stop limits, and test coverage.
- Gas validation, MOD validation, oxygen exposure, import/export, manual logbook, and conflict detection are centralized.
- Watch sync payloads validate payload size, schema version, bundle ID, HMAC signature, timestamp skew, and session consistency.
- iOS sync conflicts are stored in a protected file rather than legacy `UserDefaults`.
- CSV import caps input size at 10 MB and bounds sample count.

### iOS Release Risks

IOS-MATH-001 is the highest iOS functional risk. The current tests intentionally assert that average depth suppresses max-depth Buhlmann/MOD behavior. That behavior can be acceptable only if it is clearly labeled as a non-safety average-profile estimator. It is not safe as a blocking MOD/decompression gate.

CSV-001 affects interoperability and round-trip integrity with Subsurface-style files. The current exporter can produce rows whose column count does not match the header.

SEC-001 affects the companion because the primary logbook path persists full sessions through `UserDefaults`/iCloud KVS.

## Security Findings

### SEC-001: PII Storage Through UserDefaults/iCloud KVS

`CloudSyncStore.save` writes encoded log data to `UserDefaults` and `NSUbiquitousKeyValueStore`. `DiveLogStore` uses that path for sessions containing GPS coordinates, site names, buddy names, notes, equipment, pressures, and decompression notes.

The codebase already acknowledges this risk for sync conflicts and moved conflicts to protected files. The same principle should apply to full logbook sessions, which are at least as sensitive.

Recommended release standard:

- Store full sessions in protected app files by default.
- Use iCloud only after explicit user opt-in or a clearly documented setting.
- Consider encryption-at-rest for synchronized logbook payloads.
- Keep tombstones and bounded ID lists separate from full session bodies.

### Sync Secret Exchange

Watch/iOS HMAC derivation is substantially improved compared with deterministic-secret patterns. Both sides now use random 32-byte keychain secrets and ordered-secret derivation.

Residual risk:

- Secrets are exchanged through WatchConnectivity application context.
- Legacy ACK fallback remains on Watch.
- iOS-to-Watch ACK parity is incomplete.

This is not a P0 because WatchConnectivity is OS-paired, but it is a release hardening target.

## Mathematical / Algorithmic Findings

### IOS-MATH-001: Average Depth Can Hide Max-Depth Hazards

Evidence:

- `GasPlanInput.effectivePlanningDepthMeters` returns average depth when `planningDepthReference == .averageDepth`.
- `BuhlmannPlanner.makeRequest` uses that value as `maxDepthMeters`.
- `PlannerMODValidator.validatePlannerCylinders` checks bottom gas against effective planning depth.
- Tests assert this behavior in `PlanningDepthReferenceTests`.

Risk scenario:

1. User plans a 45 m dive with average depth 25 m.
2. User selects a gas whose MOD is safe at 25 m but unsafe at 45 m.
3. The current average-depth path can avoid the bottom-gas MOD warning and produce a Buhlmann request at 25 m.

Recommended correction:

- Always evaluate MOD and conservative decompression ceilings against planned maximum depth.
- Use average depth only for gas consumption/END summaries or as a clearly labeled estimator.
- Add regression tests where average depth is safe but max depth violates MOD.

### Watch Depth/Runtime Math

Current Watch math is materially improved:

- Time-weighted average depth uses sanitized samples.
- Ascent rate is windowed and capped.
- Depth freshness is actively evaluated.
- Runtime is monotonic.

Remaining Watch math concerns are mostly presentation and hardware validation rather than obvious static calculation defects.

## Test Coverage Gap Analysis

Existing automated coverage:

- 187 XCTest functions found.
- 31 Watch algorithm tests.
- 156 iOS algorithm tests.
- Tests cover many Buhlmann, gas, oxygen exposure, import/export, sync conflict, manual no-depth, and pressure-model cases.

Gaps to close:

- CI should execute both Watch and iOS algorithm test schemes, not only build apps.
- Add iOS-to-Watch signed ACK regression tests.
- Add regression test for average-depth planner mode where max depth violates MOD.
- Add CSV export shape tests that verify every data row matches the header column count and quoted metadata round-trips with commas/newlines.
- Add storage/security tests or static checks to prevent full session PII from being saved in `UserDefaults`.
- Add UI snapshot/device tests for ascent gauge thresholds and warning bands.
- Execute hardware QA for Apple Watch Ultra water-submersion, haptics, GPS surface capture, iCloud KVS, and WatchConnectivity queued transfers.

## Recommended Fix Plan

### Phase 1: Release Blockers

1. Fix IOS-MATH-001: max-depth MOD and Buhlmann safety checks must not be suppressed by average-depth mode.
2. Fix SYNC-001 and SYNC-002: add signed Watch ACKs, failure-aware replies, persisted iOS outbound queue, and transfer completion handling.
3. Fix SEC-001: move full logbook persistence out of `UserDefaults`/raw KVS or gate cloud sync behind explicit opt-in/encryption.
4. Run latest main on macOS: `xcodegen generate`, iOS build, Watch build, iOS XCTest, Watch XCTest, simulator list, and paired-device smoke tests.

### Phase 2: Important Hardening

1. Fix CSV-001 with header/row alignment and real CSV quoting.
2. Remove Watch legacy ACK fallback after bumping the minimum compatible companion build.
3. Protect photo transfer temp files and validate imported photo metadata.
4. Align ascent gauge thresholds with algorithm states.
5. Add CI `xcodebuild test` jobs and require them on PRs.

### Phase 3: Polish and Documentation

1. Remove avoidable production force unwraps.
2. Update README baseline to `origin/main` at the current commit.
3. Keep generated-project instructions explicit: run `xcodegen generate` before `xcodebuild`.

## Final Readiness Gate

Current gate status: NOT READY for broad TestFlight/public release.

Minimum gate to pass:

- P1 issues fixed or explicitly product-accepted with strong user-facing limitations.
- macOS `xcodegen generate` passes.
- `DIRDiving iOS` build passes on iOS Simulator.
- `DIRDiving Watch App` build passes on watchOS Simulator.
- `DIRDiving iOS Algorithm Tests` passes.
- `DIRDiving Watch Algorithm Tests` passes.
- Apple Watch Ultra paired-device QA passes for depth, haptics, GPS, sync, and iCloud behavior.
- CSV export/import round-trip verified against at least one external tool or strict local parser.

Concise summary:

- P0: 0
- P1: 4
- P2: 7
- P3: 3
- INFO: 4
- Readiness: not release-ready
- Report path: `MAIN_BRANCH_FULL_CODE_SECURITY_AUDIT_CURRENT.md`
