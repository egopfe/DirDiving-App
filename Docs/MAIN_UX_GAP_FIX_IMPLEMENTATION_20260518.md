# DIR DIVING MAIN UX Gap Fix Implementation - 2026-05-18

Scope: Apple Watch MAIN and iOS Companion MAIN only.

## Implemented

- Committed existing pre-release runtime hardening separately from audit/report artifacts.
- Preserved `project.yml` experimental exclusions for Apnea, Snorkeling, Buddy Assist and experimental-only stores/views.
- Added Watch depth diagnostics in `Info`, including entitlement configuration status, depth sensor availability, water callback availability and real Apple Watch Ultra validation warning.
- Added visible Watch delete flow in dive detail with destructive confirmation and haptic feedback.
- Replaced Watch UserImages release-looking placeholders with a proper empty state.
- Added Watch sync queue status, retry time and clear-queue confirmation.
- Added explicit Watch GPS behavior/export/settings scope copy.
- Added persisted GPS fix-source metadata: real surface fix, fallback last-known point or no-fix.
- Added App Intent failure behavior when Watch app state is unavailable instead of silently succeeding.
- Added iOS dynamic Logbook month grouping with Italian month labels.
- Split Explore empty-state sync actions into Apple Watch sync and iCloud sync.
- Added real Analysis empty-state actions for CSV import, Watch sync and opening Logbook.
- Added iOS Watch trust reset/re-pair flow with confirmation and no deterministic fallback.
- Added iOS notification authorization status display.
- Added cloud merge-policy visibility for log/equipment/planner data.
- Added export preference visibility with unsupported formats marked Planned.
- Added subtle Gear auto-save feedback.
- Replaced simple CSV splitting with quoted-field CSV parsing, malformed-row skipping, duplicate-aware import messaging and source-date preservation reporting.

## Validation

- `git diff --check` passed for both MAIN worktrees.
- `xcodegen generate` could not run on this Windows environment: `xcodegen` is not installed.
- `xcodebuild` could not run on this Windows environment: `xcodebuild` is not installed.
- Required external validation remains: run XcodeGen and Xcode builds on macOS, then validate depth/pressure behavior on a real Apple Watch Ultra with the Apple Developer entitlement/profile.

## Safety Notes

- DIR DIVING is still presented as an assistive/logging/planning app, not a certified dive computer.
- Planner safety acknowledgement remains required.
- GPS copy remains surface-only and entry/exit based.
- Haptics-off visibility remains present during active dive.
- Sync trust remains strict: unverified Watch payloads are not treated as secure.
