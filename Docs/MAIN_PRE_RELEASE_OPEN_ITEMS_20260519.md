# DIR DIVING — MAIN Pre-Release Open Items

**Date:** 2026-05-19
**Source of truth:** `MAIN UX / Interaction / Feature Accessibility Audit, 2026-05-19`
**Branches in scope:** `main` (Apple Watch MAIN), `main-iOS` (iOS Companion MAIN)
**Scope rules:** no business logic, no UI redesign, no experimental code.

This document tracks every backlog item from the 2026-05-19 audit that is **not** fully closed in code on the MAIN branches, with the reason it was deferred. All other HIGH / MEDIUM / LOW / SAFETY items were resolved in the pre-release fix cluster (see `MAIN_UX_GAP_FIX_IMPLEMENTATION_20260518.md` and the unpushed commits on `main` and `main-iOS`).

> Convention: each row lists the backlog ID, the platform, the current state in code, why it was deferred, and what is required to close it. Severity reflects the original audit; “status” is from the perspective of pre-release readiness.

---

## 1. Items intentionally not fixed (out-of-scope by design)

These items were explicitly deferred because closing them would require either business-logic changes, UI redesign, or work on experimental code — all forbidden by the 2026-05-19 backlog rules. UI is honest in each case.

### 1.1 Watch imperial unit conversion
- **ID:** UX-M7 / UX-L2 (partial)
- **Platform:** Apple Watch (`main`)
- **State today:**
  - `pushUnitsPreference` broadcasts `metric` / `imperial` via WatchConnectivity `applicationContext` (key `units`).
  - Watch ingestor (`WatchSyncService.ingestCompanionContext`) accepts only `metric`; any other value is a no-op.
  - `SettingsView` shows a static informational pill (“Display Watch: metrico”) plus a yellow disclaimer; the picker control is removed.
- **Why deferred:** Watch-side imperial conversion would change formatters/units pipelines (business logic). Out of scope.
- **Closure plan:** introduce a `WatchUnitFormatter` that swaps `m`/`°C` for `ft`/`°F` at the view layer only; keep storage and logs metric. Estimated 0.5–1 day plus QA.

### 1.2 Additional export formats (GPX / UDDF)
- **ID:** UX-M12 (partial) / Export honesty
- **Platform:** Both
- **State today:** UI labels all non-Subsurface formats as `Planned` in Watch `SettingsView` and iOS `MoreView → EXPORT`. Subsurface CSV remains the only exporter and is exposed via `SubsurfaceExportService` + `ShareLink`.
- **Why deferred:** new exporters are net-new functionality, not UX honesty. Out of scope for this pre-release pass.
- **Closure plan:** add `GPXExportService` / `UDDFExportService` files; surface in detail views once stable.

### 1.3 Per-field cloud conflict resolution for Equipment & Planner
- **ID:** UX-M6 / SET-I3
- **Platform:** iOS (`main-iOS`)
- **State today:**
  - Dive sessions have full per-record conflict UI (`WatchSyncService.SyncConflict`, “Mantieni locale” / “Usa Watch”).
  - Equipment + Planner go through `CloudSyncStore` with last-write-wins on the iCloud KVS payload.
  - `MoreView → BACKUP CLOUD` carries explicit copy: *“Attrezzatura e planner usano ultimo salvataggio KVS e non hanno ancora risoluzione per-campo.”*
- **Why deferred:** per-field merge is architectural — it requires a diff/merge engine on every editable field. Backlog forbids architectural changes.
- **Closure plan:** introduce `Mergeable` protocol on `EquipmentProfile` / `PlannerInput` and a per-field reconciliation step before writing KVS. Estimated multi-day effort.

### 1.4 watchOS hardware side-button capture
- **ID:** HARD-W3 (partial)
- **Platform:** Apple Watch (`main`)
- **State today:** `WatchShortcutHelpView` explicitly tells the user *“DIR DIVING non puo intercettare direttamente il tasto laterale o una pressione lunga arbitraria.”* Five App Intents are wired (`StartManualDiveIntent`, `EndManualDiveIntent`, `SetBearingIntent`, `ClearBearingIntent`, `AcknowledgeAlarmIntent`).
- **Why deferred:** watchOS does not allow arbitrary side-button hijacking outside of system-defined patterns. There is no fix that respects the platform.
- **Closure plan:** none. UI is correct; only Action Button (on Ultra) shortcuts can be added if Apple ever exposes a friendly API.

### 1.5 Branch convergence (`main` ↔ `main-iOS`)
- **ID:** UX-H5
- **Platform:** Both
- **State today:**
  - `Docs/IOS_COMPANION_MAIN_CANONICAL_NOTE.md` (on `main-iOS`) declares `main-iOS` canonical for iOS.
  - `main` still carries a legacy copy of `iOSApp/` so the unified `project.yml` can build both targets.
  - No experimental tab is imported on either side.
- **Why deferred:** a true cleanup would mean either (a) removing `iOSApp/` from `main` (and changing the Xcode project layout), or (b) making the Watch target reference `main-iOS` via a submodule/worktree pipeline. Both are structural changes outside the no-redesign rule.
- **Closure plan:** decide between (a) and (b) post-release, then execute as a focused refactor PR.

---

## 2. Remaining pre-release risks (require process / decision)

These risks do not block code but should be acknowledged before tagging the release.

### 2.1 Build verification missing on this machine
- **Severity:** HIGH (process)
- **Platform:** Both
- **State today:** `xcodegen generate` succeeded on both worktrees. `swiftc -parse / -typecheck` of every touched file passes against the iOS and watchOS SDKs.
- **Risk:** A full `xcodebuild` could **not** run locally because Xcode 26.5 has the SDKs but neither the iOS 26.5 nor the watchOS 26.5 *platform runtimes* installed (`xcrun simctl list devices available` returns empty).
- **Action required:** install the platform runtimes (Xcode → Settings → Components, or `xcodebuild -downloadPlatform iOS` / `xcodebuild -downloadPlatform watchOS`) and run the build commands documented in `MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`.

### 2.2 First-pairing Watch ↔ iPhone trust handshake
- **Severity:** HIGH (UX)
- **Platform:** Both
- **State today:**
  - iOS push is gated by `WatchSyncAuth.hasPeerSecret()`. If the secret has not yet been exchanged in a tester's setup, pushed sessions remain queued in `pendingOutboundSessions` (persisted under `dirdiving_ios_pending_watch_outbound_sessions`).
  - `MoreView → SYNC WATCH` surfaces this honestly: *“In attesa peer secret · push gated”* and shows the pending counter.
- **Risk:** A reviewer who never opens both apps simultaneously will believe sync is broken.
- **Action required:** include first-pairing instructions in the QA checklist (see `MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md` §5 & §6).

### 2.3 Equipment / Planner cross-device editing
- **Severity:** MEDIUM
- **Platform:** iOS
- **State today:** see §1.3. UI is honest, but a tester who edits the same equipment profile on two offline devices will see overwrite, not merge.
- **Action required:** call this out in tester briefings; do not change the code until per-field merge is approved.

### 2.4 Imperial units commitment
- **Severity:** MEDIUM (product decision)
- **Platform:** Both
- **State today:** Watch refuses non-metric units; iOS allows the user to pick imperial but the Watch ignores it. UI is honest.
- **Action required:** product decision before release — either ship metric-only and update App Store copy, or schedule the Watch-side conversion work (§1.1).

### 2.5 Per-session sync delivery status
- **Severity:** LOW
- **Platform:** Both
- **State today:** Watch `SettingsView` and iOS `MoreView → SYNC WATCH` both carry an explicit TODO row: *“Delivery per log: TODO: stato per-sessione planned”*.
- **Risk:** Aggregate counters (`pendingTransferCount`, `acknowledgedTransferCount`) tell the operator *how many*, not *which*. For a small logbook this is fine; for a heavy logbook it could be confusing.
- **Action required:** wire `WCSession` ack callbacks back to per-`DiveSession.id` status. Out of scope for this pre-release.

### 2.6 SAF-10 honest per-session sync UI
- **Severity:** LOW
- **Platform:** iOS
- **State today:** TODO row present (see §2.5). No misleading UI.
- **Action required:** same as §2.5.

---

## 3. Items not yet shipped because the depending platform is missing on the build machine

These will be closed automatically once the platform runtimes from §2.1 are installed; nothing in code is missing.

| ID | Platform | Why it depends on build runtime |
|---|---|---|
| All `xcodebuild` smoke tests | Watch + iOS | Need installed platform to compile/link. |
| Watch Ultra layout sweep | Watch | Need watchOS 26.5 simulator for 49 mm display. |
| Small-display iPhone SE QA | iOS | Need iOS 26.5 simulator for SE 3rd-gen. |
| Large-display iPhone Pro Max QA | iOS | Need iOS 26.5 simulator for 6.7" display. |

---

## 4. Suggested next-step priority order (post pre-release)

1. **Build runtimes** — install iOS 26.5 + watchOS 26.5 platforms and re-run the simulator QA checklist.
2. **Per-field cloud merge** for Equipment & Planner (§1.3).
3. **Per-session sync delivery** UI (§2.5).
4. **Imperial conversion** on Watch (§1.1) — only if product confirms imperial is shipping.
5. **Branch convergence** decision (§1.5).
6. **GPX / UDDF exporters** (§1.2).

---

## 5. Confirmations

- Business logic, decompression, TTV/TTR algorithms, gas models, and sync rules are **unchanged** by the items in this document. Closure of any of them must continue to honor those constraints.
- No experimental code is referenced or imported. `Utils/ExperimentalFeatures.swift` flag is untouched.
- UI/UX styling (black/neon Watch, dark-marine cyan iOS) is to be preserved when these items are eventually closed.

---

*Generated as part of the MAIN pre-release backlog execution, 2026-05-19. Pair with `MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`.*
