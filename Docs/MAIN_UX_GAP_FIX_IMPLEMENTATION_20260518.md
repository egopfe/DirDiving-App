# DIR DIVING MAIN UX Gap Fix Implementation - 2026-05-18

Scope: iOS Companion MAIN branch.

## Implemented

- Committed existing iOS pre-release runtime hardening separately from later audit-driven implementation.
- Added dynamic Logbook month grouping with Italian month labels.
- Split Explore empty-state sync actions into Apple Watch sync and iCloud sync.
- Added real Analysis empty-state actions for CSV import, Watch sync and opening Logbook.
- Added iOS Watch trust reset/re-pair flow with confirmation and no deterministic fallback.
- Added iOS notification authorization status display.
- Added cloud merge-policy visibility for log/equipment/planner data.
- Added export preference visibility with unsupported formats marked Planned.
- Added subtle Gear auto-save feedback.
- Added persisted GPS fix-source metadata so details can distinguish real surface fix, fallback and no-fix.
- Replaced simple CSV splitting with quoted-field CSV parsing, malformed-row skipping, duplicate-aware import messaging and source-date preservation reporting.

## Validation

- `git diff --check` passed for the iOS MAIN worktree.
- `xcodegen generate` could not run on this Windows environment: `xcodegen` is not installed.
- `xcodebuild` could not run on this Windows environment: `xcodebuild` is not installed.
- Required external validation remains: run XcodeGen and Xcode builds on macOS and test WatchConnectivity with real devices.

## Safety Notes

- Planner safety acknowledgement remains required.
- GPS copy remains surface-only and entry/exit based.
- Sync trust remains strict: unverified Watch payloads are not treated as secure.
- Cloud KVS merge policy is surfaced in Settings, but full per-field conflict resolution remains a future larger feature.
