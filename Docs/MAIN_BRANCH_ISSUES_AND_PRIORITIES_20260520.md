# DIR DIVING — MAIN: issues and priorities

**Date:** 2026-05-20  
**Branch:** `main` @ `b92e03a`  
**Source:** [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md)

Use this file as the single checklist of open issues, ordered by priority and release gate.

**Legend**

| Priority | Meaning |
|----------|---------|
| **P0 — CRITICAL** | Blocks correct data, safety perception, or core sync; fix before any external test |
| **P1 — HIGH** | Blocks compile verification, TestFlight, or trust in sync/delete |
| **P2 — MEDIUM** | Degrades UX or field readiness; fix before App Store |
| **P3 — LOW** | Friction or honesty gaps; acceptable for internal test with docs |
| **P4 — POST-RELEASE** | Planned enhancements; not blocking MAIN ship |

| Fix type | Meaning |
|----------|---------|
| UI-only | Layout, copy, navigation — no algorithm changes |
| Small functional | Localized logic (sync handlers, keys, dismiss) |
| Environment | Xcode / SDK / signing on Mac |
| Process | QA, legal, App Store metadata |
| Planned | Product decision or multi-day scope |

---

## Release gates (summary)

| Gate | Must close |
|------|------------|
| **Compile / local use** | P1-ENV-01, verify assets in Xcode |
| **Internal test** | P0 items + pairing QA instructions |
| **TestFlight** | All P0 + P1 + P2 depth/sync |
| **App Store** | Above + i18n/legal + entitlement proof |
| **Post-release** | P4 backlog |

---

## P0 — CRITICAL

| ID | Issue | Platform | File / area | User impact | Fix type | Gate |
|----|-------|----------|-------------|-------------|----------|------|
| P0-SYNC-01 | Watch **does not** implement `WCSessionDelegate` `didReceiveMessage` / `didReceiveUserInfo` — iPhone cannot push dive updates or deletes to Watch | Watch | `Services/WatchSyncService.swift` | Logs deleted or updated on iPhone **do not** appear on Watch; sync feels one-way only | Small functional | TestFlight |

---

## P1 — HIGH

| ID | Issue | Platform | File / area | User impact | Fix type | Gate |
|----|-------|----------|-------------|-------------|----------|------|
| P1-SYNC-02 | **Tombstone key mismatch:** Watch `dirdiving_watch_deleted_session_ids` vs iOS `dirdiving_ios_deleted_session_ids` — not `dirdiving_shared_deleted_session_ids` | Both | `Services/DiveLogStore.swift`, `iOSApp/Services/DiveLogStore.swift` | Deleted dives **reappear** on the other device after sync/cloud | Small functional | TestFlight |
| P1-ENV-01 | `xcodebuild` fails: **iOS 26.5** and **watchOS 26.5** platform runtimes not installed on build Mac | Build | Xcode → Settings → Components | Cannot prove compile/link/archive in CI or locally | Environment | Compile |
| P1-PROC-02 | First-pairing Watch ↔ iPhone: sessions stay pending until peer secret exchanged; easy to misread as “broken sync” | Both | `WatchSyncAuth`, Settings/More copy | Reviewers/testers report sync failure | Process (+ QA doc) | Internal test |
| P1-BACKLOG-03 | Watch UX backlog **not merged** on `main` (on branch `backup/main-watch-backlog-20260519`): tombstone unify (UX-H1), iOS→Watch consumer (UX-H2), GPS compact banner (UX-H4), alarm dismiss (SAF-8), App Intents extras | Watch | `WatchSyncService.swift`, `DiveLiveView.swift`, etc. | Fixes above remain unshipped; conflicts with security F1–F12 cluster | Small functional + merge | TestFlight |

---

## P2 — MEDIUM

| ID | Issue | Platform | File / area | User impact | Fix type | Gate |
|----|-------|----------|-------------|-------------|----------|------|
| P2-UX-01 | GPS start/end confirmation is **full-screen** for ~2.4 s — depth, gauge, and controls hidden | Watch | `DiveManager.swift` (`Task.sleep 2_400_000_000`), `GPSStartRegisteredView`, `GPSEndRegisteredView` | User blind to depth/ascent at dive start/end | UI-only | App Store |
| P2-DEPTH-02 | Water **submersion entitlement** configured in `Config/DIRDiving.entitlements` but **not validated** on real Apple Watch Ultra | Watch | Entitlements, `DiveManager`, depth sensor | Auto depth may not work in water until Apple signs + device test | Process / signing | TestFlight |
| P2-UX-03 | Depth/time/battery **alarm banner** on live dive has **no OK / dismiss** — message until cooldown/condition clears | Watch | `DiveLiveView.swift`, `DiveManager.triggerAlarm` | Annoying or confusing during long alarm | UI-only | App Store |
| P2-I18N-04 | **Partial i18n:** many `Text("…")` literals stay Italian when app language = EN | Both | Multiple `Views/`, `iOSApp/Views/` | English users see mixed IT/EN UI | UI-only | App Store |
| P2-SYNC-05 | **Settings sync** Watch ↔ iPhone marked “planned” — units/alarms not bidirectional | Both | `SettingsView`, `MoreView` | Changing settings on one device does not update the other | Planned / small functional | App Store |
| P2-IOS-06 | **Equipment / Planner** iCloud merge is last-write-wins — no per-field conflict UI | iOS | `CloudSyncStore`, `MoreView` | Edits on two devices overwrite each other (UI is honest) | Architectural (deferred) | App Store (document) |
| P2-PROC-07 | **Imperial units:** iOS may select imperial; Watch forces metric — inconsistent | Both | `SettingsView`, iOS units UI | User expects ft/°F on Watch, still sees metric | Product + Planned | App Store |
| P2-SAFETY-08 | Sync failure feedback mainly in **Settings/More** — easy to miss silent queue growth | Both | `WatchSyncService`, `WatchSyncService` (iOS) | User does not know logs are stuck pending | UI-only | App Store |

---

## P3 — LOW

| ID | Issue | Platform | File / area | User impact | Fix type | Gate |
|----|-------|----------|-------------|-------------|----------|------|
| P3-UX-01 | **Mode Selection** is first tab on cold launch — extra step before live dive | Watch | `AppPage.modeSelection`, `ContentView` | Friction for average user (accepted product policy) | UI-only | Post-release |
| P3-UX-02 | **Imperial units** picker removed on Watch; metric-only pill + disclaimer | Watch | `SettingsView` | Cannot select ft until conversion implemented | Planned | Post-release |
| P3-SYNC-03 | **Per-session sync delivery** status TODO — only aggregate counters (pending/ack) | Both | `SettingsView`, `MoreView` | Operator does not see *which* log failed | Small functional | Post-release |
| P3-UX-04 | **UserImages** empty when no bundled assets — feature useless without `Resources/UserImages` | Watch | `UserImagesView` | Empty screen until assets added | Content / config | Internal test |
| P3-HW-05 | **Side button** cannot map to arbitrary dive actions — only App Intents (stopwatch, etc.) | Watch | `ActionButtonIntents.swift`, help copy | Power users may expect hardware START dive | None (platform limit) | — |
| P3-IOS-06 | **No alert sounds** on iOS — export/sync feedback visual only | iOS | — | Less feedback than some companion apps | Planned | Post-release |
| P3-PROC-07 | **Subsurface CSV** import/export not manually regression-tested on device | Both | `SubsurfaceExportService` | Rare format edge cases | Process (QA) | TestFlight |

---

## P4 — POST-RELEASE (planned / backlog)

| ID | Issue | Platform | Notes | Fix type |
|----|-------|----------|-------|----------|
| P4-EXPORT-01 | GPX / UDDF export | Both | UI already says “Planned”; only Subsurface CSV today | New feature |
| P4-BRANCH-02 | Converge `main` vs `main-iOS` repo layout | Both | See `IOS_COMPANION_MAIN_CANONICAL_NOTE.md` | Architectural |
| P4-I18N-03 | Sync **language preference** Watch ↔ iPhone via WatchConnectivity | Both | Separate sandboxes today | Small functional |
| P4-SYNC-04 | Remove legacy **unsigned ack** fallback when iOS floor build rises | Both | `WatchDiveSyncCodec` F11 follow-up | Small functional |
| P4-UX-05 | Skip Mode Selection → land on Live when only Diving is active | Watch | Product decision | UI-only |
| P4-CLOUD-06 | Per-field merge for Equipment + Planner in iCloud KVS | iOS | Multi-day; see open items doc | Architectural |

---

## Watch backlog on `backup/main-watch-backlog-20260519` (merge before TestFlight)

These are **implemented on backup branch** but **not on `main`** — reconcile with security commits before cherry-pick.

| Backlog ID | Issue | Priority if unmerged |
|------------|-------|----------------------|
| UX-H1 / SAF-6 | Unified tombstone `dirdiving_shared_deleted_session_ids` | **P1** (overlaps P1-SYNC-02) |
| UX-H2 | Watch consumes iOS push (`parseSession` + attach log store) | **P0** (overlaps P0-SYNC-01) |
| UX-H4 / SAF-2 | GPS confirmation **compact banner** (not full-screen) | **P2** (overlaps P2-UX-01) |
| SAF-8 | Alarm **OK** + `AcknowledgeAlarmIntent` | **P2** (overlaps P2-UX-03) |
| UX-M1 | Drop Mode Selection from tab strip | **P3** |
| UX-M4/M5/M8 | Settings retry always visible, bearing toast, info rows | **P3** |
| UX-L* / SAF-7 | A11y labels, haptics-off pre-dive badge, export copy | **P3** |
| Phase-5 | `StartManualDiveIntent`, `EndManualDiveIntent`, `SetBearingIntent`, `ClearBearingIntent` | **P3** |

**Merge procedure (from README):**

```bash
git checkout main
git cherry-pick cbcabf7 c685155 efa53e4
# Prefer security F1–F12 in WatchSyncService.swift / WatchDiveSyncCodec.swift on conflict;
# prefer backlog for UX-only files (DiveLiveView, SettingsView).
```

---

## App Store / legal (process — not code bugs)

| ID | Item | Priority | Action |
|----|------|----------|--------|
| LEGAL-01 | App is **not** a certified dive computer — disclaimer must stay in metadata | P2 | App Store copy + review notes |
| LEGAL-02 | Planner / Bühlmann / TTV **indicative** — legal review of strings | P2 | Copy review |
| LEGAL-03 | Privacy: GPS, iCloud KVS, WatchConnectivity, depth API | P2 | Privacy policy URL |
| LEGAL-04 | Depth entitlement approval + Ultra validation evidence | P1–P2 | Apple Developer + field test |

---

## Quick counts

| Priority | Count (unique issues) |
|----------|----------------------|
| P0 CRITICAL | 1 |
| P1 HIGH | 4 (+ backlog merge) |
| P2 MEDIUM | 8 |
| P3 LOW | 7 |
| P4 POST-RELEASE | 6 |
| Process / legal | 4 |

---

## Suggested fix order (single developer)

1. P1-ENV-01 — install Xcode platforms; confirm `xcodebuild` green  
2. P0-SYNC-01 + P1-SYNC-02 — Watch inbound WC + shared tombstone (or cherry-pick backlog UX-H1/H2)  
3. P1-BACKLOG-03 — merge `backup/main-watch-backlog-20260519` with security-aware conflict resolution  
4. P2-DEPTH-02 — Ultra entitlement + depth smoke test  
5. P2-UX-01, P2-UX-03 — GPS compact banner + alarm dismiss (if not from backlog)  
6. P2-I18N-04 — primary flows to `Localizable.strings`  
7. P3 / P4 — product backlog  

---

*Audit-only list · no code changed · 2026-05-20*
