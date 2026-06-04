# DIR DIVING Security Remediation Report

**Date:** 2026-06-04  
**Branch:** `main`  
**Source audit:** `Docs/DIR_DIVING_SECURITY_EXPLOIT_AUDIT_AND_REMEDIATION_PLAN_20260604.md`  
**Post-remediation readiness (code/repo/static):** **100%** — physical-device QA still required (see §R)

---

## A. Branch confirmed

`main` (aligned with `origin/main` at implementation time).

## B. Commit base

Implementation performed on `main` after `40bf110` (`docs: add security exploit remediation plan`), with additional uncommitted security remediation changes.

## C. Targets confirmed

- `DIRDiving Watch App` (Watch MAIN)
- `DIRDiving iOS` (iOS Companion MAIN)

## D. Experimental exclusions confirmed

Unchanged per `project.yml` (Apnea, Snorkeling, Buddy Assist, Exploration Lab, experimental iOS views excluded).

## E. Files modified (security remediation)

| Area | Files |
|------|--------|
| P1-001 Legal gate | `Utils/LegalAcceptanceGate.swift`, `Services/ActionButtonIntents.swift`, `Resources/*/Localizable.strings` |
| P1-002 Sensor policy | `Utils/SensorSourceMode.swift`, `iOSApp/Utils/SensorSourceMode.swift`, `Utils/DeveloperSettings.swift`, `iOSApp/Utils/DeveloperSettings.swift`, `Utils/DeveloperVersionUnlock.swift`, `iOSApp/Utils/DeveloperVersionUnlock.swift`, `Services/DiveManager.swift`, `Views/DeveloperSettingsView.swift`, `iOSApp/Views/DeveloperSettingsView.swift`, `Views/DiveLiveView.swift`, `App/DIRDivingApp.swift`, `iOSApp/App/DIRDivingiOSApp.swift` |
| P1-003 Cloud opt-in | `iOSApp/Utils/CloudBackupSettings.swift`, `iOSApp/Services/DiveLogStore.swift`, `iOSApp/Views/MoreView.swift`, `iOSApp/Resources/*/Localizable.strings` |
| P2-001 TOFU pinning | `Services/WatchSyncAuth.swift`, `iOSApp/Services/WatchSyncAuth.swift`, `Utils/WatchSyncNotifications.swift`, `iOSApp/Utils/WatchSyncNotifications.swift`, `Services/WatchSyncService.swift`, `iOSApp/Services/WatchSyncService.swift` |
| P2-002 Photo validation | `Utils/WatchCompanionPhotoValidator.swift`, `Services/UserImageStore.swift` |
| P2-003 Archive hygiene | `DirDiving-All-Branches-20260516-115813.zip` (removed from git), `.gitignore`, `Scripts/check_secrets.sh` |
| P3-001 ACK parity | `Services/WatchDiveSyncCodec.swift` |
| P3-002 CI permissions | `.github/workflows/build.yml` |
| Tests | `Tests/WatchAlgorithmTests/*`, `Tests/iOSAlgorithmTests/*`, `project.yml` |
| Docs | This report + policy docs below |

## F. Issues fixed by ID

| ID | Status | Summary |
|----|--------|---------|
| SEC-P1-001 | Fixed | `LegalAcceptanceGate` blocks all safety App Intents until onboarding accepted |
| SEC-P1-002 | Fixed | Default sensor `.automatic`; simulation DEBUG/TestFlight-only; red SIMULATION badge on live dive |
| SEC-P1-003 | Fixed | Full logbook iCloud KVS backup opt-in (default OFF) in More |
| SEC-P2-001 | Fixed | Peer secret TOFU pinning; mismatch warning; `resetPeerTrust` on Watch |
| SEC-P2-002 | Fixed | Watch decodes/re-encodes JPEG before storage |
| SEC-P2-003 | Fixed | Tracked branch ZIP removed; `*.zip` gitignored |
| SEC-P3-001 | Fixed | Watch ACK rejects empty/`"acknowledged"` like iOS |
| SEC-P3-002 | Fixed | `permissions: contents: read` on GitHub Actions |

## G. Security behavior after remediation

- App Intents fail closed with localized EN/IT error until legal acceptance.
- Release/App Store builds cannot keep silent simulation depth; TestFlight may use simulation with visible badge.
- iCloud full session backup only when user enables Cloud backup toggle.
- Peer secrets cannot be silently replaced; user must reset pairing trust.
- Companion photos must decode as images before storage.
- Repository no longer tracks multi-branch ZIP snapshots.

## H. Tests added

- `LegalAcceptanceGateTests`
- `WatchSyncPeerSecretPinningTests`
- `WatchAckVerifierSecurityTests`
- `WatchCompanionPhotoValidatorTests`
- `CloudBackupPolicyTests`
- `WatchSyncPeerSecretPinningIOSTests`
- Updated `DeveloperSensorSourceTests`, `WatchSyncConflictTests`

## I. Tests run

| Suite | Result |
|-------|--------|
| DIRDiving Watch Algorithm Tests | **SUCCEEDED** (peer-secret tests skip if keychain unavailable) |
| DIRDiving iOS Algorithm Tests | **SUCCEEDED** |

## J. Build results

| Target | Result |
|--------|--------|
| DIRDiving Watch App | **BUILD SUCCEEDED** |
| DIRDiving iOS | **BUILD SUCCEEDED** |

## K. Secret scan results

`Scripts/check_secrets.sh` → **no obvious secrets detected**

## L. Archive cleanup result

- `git rm DirDiving-All-Branches-20260516-115813.zip`
- `.gitignore` blocks future `*.zip` (except `approved-source-fixtures/**/*.zip`)

## M. Cloud backup opt-in behavior

- Default: `CloudBackupSettings.isEnabled == false`
- `DiveLogStore.syncCloudSessionsBackup()` no-ops when disabled
- More → Cloud backup toggle + privacy copy (EN/IT)
- Local protected-file logbook unchanged

## N. App Intent gate behavior

All listed intents call `requireLegalAcceptanceForSafetyIntent()` before touching runtime managers.

## O. Sensor source release policy

- Missing preference → `.automatic`
- Stored `.simulation` in non-DEBUG non-TestFlight → effective `.automatic`
- Developer unlock gesture disabled outside `DEBUG`

## P. Peer-secret pinning behavior

- First secret: accept
- Same secret: unchanged
- Different secret: reject + `sync.trust.mismatch` status
- `resetPeerTrust()` clears peer secret and mismatch flag

## Q. Photo validation behavior

- Raw bytes decoded with `UIImage`
- Re-encoded as JPEG; filename sanitized
- Invalid bytes rejected

## R. Remaining physical QA

- Action Button / App Intents on real Watch before/after onboarding
- WatchConnectivity trust reset on paired devices
- iCloud opt-in across two devices
- Photo transfer rendering on Watch
- Legal revision re-acceptance flow

## S. Remaining risks

- Keychain-dependent sync tests may skip in some CI/sandbox environments (documented; runtime pinning still active).
- Existing iCloud KVS data for prior users is not auto-deleted when backup is off (by design).
- Optional KVS payload encryption deferred (not half-implemented).

## T. Confirmation

- MAIN only; experimental untouched
- No UI redesign (only security copy/badges/toggles)
- No algorithm / Bühlmann / TTV / safety threshold changes
- No certified dive-computer claims
- No false Apple system Low Power Mode enablement
- Legal/safety disclaimers preserved
- No iOS companion algorithm changes beyond security/privacy gates
