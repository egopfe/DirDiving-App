# MAIN issues implementation report (2026-05-20)

Implements priorities from [`MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md`](MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md) on branch **`main`**.

---

## A. Branch confirmed

- **Branch:** `main`
- **Approach:** Manual port from `backup/main-watch-backlog-20260519` (commits `cbcabf7`, `c685155`, `efa53e4`) while preserving security F1–F12 in sync/auth files. No cherry-pick merge (avoid overwriting F9/F11).

---

## B. Files changed

| Area | Files |
|------|--------|
| P0/P1 sync | `Utils/WatchSyncKeys.swift`, `iOSApp/Utils/WatchSyncKeys.swift`, `Services/WatchSyncService.swift`, `Services/WatchDiveSyncCodec.swift`, `Services/WatchSyncAuth.swift`, `iOSApp/Services/WatchSyncService.swift`, `iOSApp/Services/WatchSyncAuth.swift`, `iOSApp/Services/WatchDiveSyncCodec.swift` (parse fix) |
| Tombstones | `Services/DiveLogStore.swift`, `iOSApp/Services/DiveLogStore.swift` |
| UX | `Views/DiveLiveView.swift`, `Services/DiveManager.swift`, `Views/InfoView.swift`, `Views/SettingsView.swift` |
| Intents | `Services/ActionButtonIntents.swift`, `Services/CompassManager.swift` |
| App wiring | `App/DIRDivingApp.swift`, `iOSApp/App/DIRDivingiOSApp.swift` |
| i18n | `Resources/{en,it}.lproj/Localizable.strings` |
| Docs | `Docs/BUILD_VALIDATION.md`, `Docs/RELEASE_CHECKLIST.md` |

---

## C. P0 fixed

| ID | Status |
|----|--------|
| **P0-SYNC-01** | **Done** — Watch `WCSessionDelegate` implements `didReceiveMessage`, `didReceiveMessage:replyHandler:`, `didReceiveUserInfo`; `ingestIncomingPayload` + `attachLogStore` |

---

## D. P1 fixed

| ID | Status |
|----|--------|
| **P1-SYNC-02** | **Done** — `dirdiving_shared_deleted_session_ids` with migration from legacy Watch/iOS keys |
| **P1-ENV-01** | **Documented** — `BUILD_VALIDATION.md` updated (iOS/watchOS 26.5 runtimes, simulator commands) |
| **P1-BACKLOG-03** | **Done (manual port)** — Inbound sync, tombstones, GPS compact banner, alarm OK, sync strip, App Intents, CompassManager.shared; not a literal cherry-pick |

---

## E. P2 fixed

| ID | Status |
|----|--------|
| **P2-DEPTH-02** | **Documented** — `RELEASE_CHECKLIST.md` depth entitlement section (no false validation claim) |
| **P2-UX-01** | **Done** — GPS compact banner ~1.4 s; live metrics stay visible |
| **P2-UX-03** | **Done** — Alarm banner **OK** + 15 s dismiss cooldown |
| **P2-I18N-04** | **Partial** — Keys for GPS banner, alarm OK, live ready/haptics; Settings picker uses wheel on watchOS |
| **P2-SYNC-05** | **Honest** — Units: metric-only on Watch; iOS units local; sync settings copy unchanged |
| **P2-PROC-07** | **Honest** — Same as above |
| **P2-SAFETY-08** | **Done** — Pending/failed sync strip on `DiveLiveView` |

---

## F. P3 quick wins

| Item | Status |
|------|--------|
| Sync failure visibility | Covered by sync strip |
| App Intents | Acknowledge + manual dive + bearing intents added |
| UserImages tab hide | **Not done** (would need `AppPage` / navigation change) |
| Subsurface CSV QA | **Not done** (doc-only optional) |

---

## G. P4 left untouched

GPX/UDDF, branch convergence, language sync via WC, per-field cloud merge — **not implemented**.

---

## H. Backlog commits merged?

**No literal cherry-pick.** Functionality from `cbcabf7` / `c685155` / `efa53e4` reimplemented on top of `b92e03a` security baseline.

---

## I. Conflict resolution

- **WatchSyncService / WatchDiveSyncCodec:** Kept F9 file-backed pending queue, F11 signed ack, F6 skew 1 h.
- **DiveLiveView:** Kept inline **ascent alarm banner** (2026-05-20 product); added GPS compact banner (does not replace screen).

---

## J. Business logic unchanged

- No changes to decompression, TTV/TTR math, ascent rate thresholds, depth algorithms, planner gas math, or CSV column business format.

---

## K. Experimental untouched

- `project.yml` exclusions unchanged; no Apnea/Snorkeling/Buddy files added to MAIN targets.

---

## L. Build result

| Command | Result |
|---------|--------|
| `xcodegen generate` | **PASS** |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build` | **BUILD SUCCEEDED** |
| `xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build` | **BUILD SUCCEEDED** |

Fixes applied during build: `InfoView` `@ViewBuilder` on `batteryRow`; `SettingsView` `.wheel` picker (watchOS); `WatchDiveSyncCodec.parsePayload(from:)` on iOS.

---

## M. Manual QA checklist

- [ ] Watch → iPhone dive sync (existing path)
- [ ] iPhone → Watch dive import via `sendMessage` / `transferUserInfo`
- [ ] Delete on iPhone removes session on Watch (tombstone WC + shared KVS key)
- [ ] Delete on Watch removes session on iPhone
- [ ] GPS start/end: banner only, depth/gauge visible
- [ ] Depth alarm: tap OK, 15 s cooldown
- [ ] EN locale: GPS banner + OK strings
- [ ] Ultra depth entitlement field test (checklist in RELEASE_CHECKLIST)

---

## N. Remaining blockers for TestFlight

- Real-device depth entitlement validation on Watch Ultra
- Full i18n pass (many literal Italian strings remain)
- End-to-end sync QA with first pairing (peer secret exchange)
- Watch scheme explicit build + Ultra layout pass

---

## O. Remaining blockers for App Store

All TestFlight items plus legal/metadata review and complete tombstone QA on multi-device iCloud edge cases.

---

*2026-05-20 · DIR DIVING MAIN*
