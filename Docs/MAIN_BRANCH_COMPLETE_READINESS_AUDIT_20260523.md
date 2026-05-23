# DIR DIVING — MAIN BRANCH COMPLETE READINESS AUDIT

**Date:** 2026-05-23  
**Type:** Audit-only — no code changes, no merges, no fixes  
**Branch:** `main` @ `6cda004`  
**Scope:** Apple Watch MAIN (`DIRDiving Watch App`) + iOS Companion MAIN (`DIRDiving iOS`) in unified workspace  
**Out of scope:** `codex/experimental-features`, `codex/ios-experimental-features`, `main-iOS` worktree (parallel history; not required for this checkout)

**Visual benchmarks (mandatory):**

- Watch: `Docs/ReferenceUI/Watch_LIVE_reference.png` — present  
- iOS: `Docs/ReferenceUI/iOS_Companion_reference.png` — present  

**Method:** Static code review, `project.yml` target membership, `xcodegen generate`, `xcodebuild` (Watch Ultra 3 + iPhone 17 + generic iOS Simulator), cross-check with [`MAIN_BRANCH_FINAL_READINESS_REPORT.md`](MAIN_BRANCH_FINAL_READINESS_REPORT.md), feature CSV, depth-safety checklist, prior audits.

**Delta since [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.md):** Bundle IDs Watch `com.egopfe.dirdiving.ios.watch` (embedded companion prefix); `GENERATE_INFOPLIST_FILE` for bundle ID; production-readiness pass (i18n, sync push, conflict UI); depth-limit safety UI/haptics/logs/onboarding ack (`6cda004`). Generic iOS Simulator build now **succeeds** (separate internal product names).

---

## A. Branch Confirmed

| Item | Result |
|------|--------|
| Current branch | `main` |
| HEAD | `6cda004` (`feat(watch): depth limit safety UI, haptics, logs, and onboarding ack`) |
| Targets inspected | `DIRDiving Watch App` (watchOS 10+), `DIRDiving iOS` (iOS 17+, embeds Watch) |
| `project.yml` | Valid; experimental sources **excluded** from MAIN |
| `xcodegen generate` | **PASS** |
| `xcodebuild` Watch (Apple Watch Ultra 3 (49mm)) | **BUILD SUCCEEDED** |
| `xcodebuild` iOS (iPhone 17) | **BUILD SUCCEEDED** |
| `xcodebuild` iOS (`generic/platform=iOS Simulator`) | **BUILD SUCCEEDED** (2026-05-23) |
| Bundle IDs | iOS `com.egopfe.dirdiving.ios`; Watch `com.egopfe.dirdiving.ios.watch`; `WKCompanionAppBundleIdentifier` = iOS ID |
| Entitlements | Watch: iCloud KVS + water submersion; iOS: iCloud KVS (no submersion on iOS — correct) |
| Experimental in MAIN binary | **None** — Apnea/Snorkeling/Buddy/Exploration excluded |
| Reference UI | Present under `Docs/ReferenceUI/` |
| Blocking TODO in MAIN Swift | **0** (one iOS `TODO(F11-followup)` comment only) |

---

## B. Executive Summary

| Dimension | Readiness % | Notes |
|-----------|-------------|-------|
| **Overall MAIN readiness** | **86%** | Builds clean; not App Store–complete |
| Apple Watch MAIN | **88%** | Strong live UX + depth safety; real Ultra + entitlement still external |
| iOS Companion MAIN | **87%** | Five-tab companion solid; planner chrome partial |
| UX completeness | **82%** | Legal re-onboarding; some decorative UI; import hidden when logbook non-empty |
| Safety / disclaimers | **88%** | Legal gate + depth limits 35/38/40 m + planner ack |
| Compile readiness | **97%** | All three build paths succeeded this audit |

**One-line verdict:** MAIN is **ready to compile** and **ready for internal / paired-device QA** using [`INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md) and [`DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md`](DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md). It is **not 100%** for an average end user without physical Watch Ultra depth proof, Apple entitlement on `com.egopfe.dirdiving.ios.watch`, and App Store legal/screenshot review.

---

## C. Feature Inventory

| Platform | Feature | Impl. | Reach. | Usable | Complete | Sev. | Notes |
|----------|---------|-------|--------|--------|----------|------|-------|
| Watch | Legal onboarding + depth-limits ack | Y | Y | Y | Y | — | Revision `2026-05-23` re-prompts existing users |
| Watch | Live dive (depth, TTV, runtime) | Y | Y | Y | Partial | HIGH | Simulator: manual fallback; Ultra needs entitlement |
| Watch | Depth safety 35/38/40 m + haptics | Y | Y | Y | Y | — | New `6cda004`; throttled haptics |
| Watch | Stopwatch START/STOP/RESET | Y | Y | Y | Y | — | Haptics gated |
| Watch | Avg/max depth (live) | Y | Y | Y | Y | — | Hidden when exceeded (no celebration) |
| Watch | Temperature | Y | Y | Y | Partial | LOW | Sensor-dependent |
| Watch | Ascent gauge + inline banner | Y | Y | Y | Y | — | BUSSOLA terminology preserved |
| Watch | BUSSOLA / bearing SET/CLEAR | Y | Y | Y | Y | — | `CompassView` |
| Watch | Dive log / detail / delete | Y | Y | Y | Y | — | Exceeded-range flag in log |
| Watch | GPS entry/exit metadata | Y | Y | Y | Partial | MED | Surface-only; compact banner |
| Watch | Subsurface CSV export + ShareLink | Y | Y | Y | Y | — | List + detail paths |
| Watch | User images | Y | Hidden | — | Partial | LOW | Tab hidden if no bundle images |
| Watch | Settings (ascent, alarms, haptics, language) | Y | Y | Y | Partial | MED | Some IT literals; export row informational |
| Watch | Info / battery / depth status | Y | Y | Y | Partial | MED | “Configured” ≠ validated on device |
| Watch | Mode Selection | Y | Hidden | — | — | — | Skipped when single stable mode (default) |
| Watch | Haptics | Y | Y | Y | Y | — | No audio tones (by design) |
| Watch | Watch → iPhone sync | Y | Y | Y | Partial | MED | Needs paired iPhone + peer secret |
| Watch | iPhone → Watch session push | Y | Y | Y | Partial | MED | Implemented on iOS; device QA required |
| Watch | Action Button / App Intents | Partial | Partial | Partial | Partial | LOW | Only stopwatch shortcuts promoted |
| iOS | Legal onboarding + depth ack | Y | Y | Y | Y | — | Same revision bump |
| iOS | Logbook list / detail / delete | Y | Y | Y | Y | — | Demo dives protected |
| iOS | Analysis charts / metrics | Y | Y | Y | Y | — | Includes demo if loaded |
| iOS | CSV import | Y | Partial | Y | Partial | MED | Only from Analysis **empty** state |
| iOS | Subsurface CSV export | Y | Y | Y | Y | — | Per dive in detail |
| iOS | Planner input + safety ack | Y | Y | Y | Y | — | Calculate gated |
| iOS | Planner results (Bühlmann/charts) | Y | Y | Partial | Partial | MED | Tab chrome partial; placeholder row |
| iOS | Equipment profile + checklist | Y | Y | Y | Y | — | iCloud KVS |
| iOS | More: sync / conflict / iCloud / demo | Y | Y | Y | Partial | MED | Units picker missing |
| iOS | Watch sync + push to Watch | Y | Y | Y | Partial | MED | Simulator limited |
| iOS | Exploration / Buddy / Lab | N | — | — | — | — | Excluded from target |

---

## D. Navigation Map

### Apple Watch (vertical `TabView` + Crown)

1. **Legal gate** → 2. **Live** (default) ↔ **Compass** ↔ **Settings** ↔ **[User Images if assets]** ↔ **Dive log** → **Dive detail** → **Export completion**  
   - Subflows: Ascent rate settings, Alarm settings, Legal & Safety, Info  
   - **No dead ends** in MAIN paths  
   - **Hidden:** Mode Selection (not in tab list), experimental modes  

### iOS (5-tab bar)

1. **Legal gate** → **Logbook** | **Analysis** | **Planner** → **PlanResult** | **Equipment** | **More**  
   - **Dive detail** from logbook (push)  
   - **Legal & Safety** from More  
   - **Dead ends:** none critical  
   - **Unreachable:** excluded experimental views (not in binary)  

---

## E. UI Consistency Report

### Apple Watch vs `Watch_LIVE_reference.png`

| Finding | Severity | Recommendation |
|---------|----------|----------------|
| Black canvas, neon palette, large depth hero, rounded panels | **Match** | Maintain |
| Ascent gauge + TTV/RunTime panel layout | **Match** | — |
| Depth safety banners add extra chrome not in reference | **LOW** | Acceptable safety overlay |
| Settings uses mix of localized + literal Italian rows | **MED** | Finish `String(localized:)` pass |
| `contextMenu` deprecation on log rows | **LOW** | Migrate to `swipeActions` when touching file |
| Orphan full-screen GPS views unused | **LOW** | Remove in future cleanup (non-blocking) |

### iOS vs `iOS_Companion_reference.png`

| Finding | Severity | Recommendation |
|---------|----------|----------------|
| Dark marine + cyan tab tint + card layout | **Match** | — |
| Logbook metric tiles and detail tabs | **Match** | — |
| Planner mode segmented control is **display-only** | **MED** | Label “UI only” or wire logic |
| Plan result tab bar does not switch content | **MED** | Wire tab state or remove tabs |
| Logbook header +/⋯ icons decorative | **LOW** | Wire or hide from a11y (already hidden) |
| Hardcoded “Acqua Salata” in detail | **LOW** | Localize / derive from data |

---

## F. Settings Report

| Setting | Watch UI | iOS UI | Persisted | Applied | Cross-sync |
|---------|----------|--------|-----------|---------|------------|
| Units | Metric wheel; imperial N/A | Formatters only; **no picker** | Y | Y | No |
| Ascent rate limits | Y | — | Y (KVS) | Y | No |
| Alarms (depth/runtime/battery) | Y | — | Y | Y | No |
| Haptics on/off | Y | — | Y | Immediate | No |
| Language IT/EN/System | Y | Y (More) | Y | Restart UI | No |
| Depth safety (runtime) | Automatic | — | Session flag | Live | N/A |
| Planner safety ack | — | Y | Y | Before calculate | No |
| iCloud KVS | Status only | Sync now | Y | Background | Partial |
| Sync settings | Informational “planned” | Local-only label | — | — | Partial WC only |

**Missing vs ideal:** imperial units UI; Watch↔iOS settings mirror; brightness/AOD controls (watchOS-managed only).

---

## G. Haptics / Tones Report

| Event | Watch haptic | Gated by setting | Notes |
|-------|--------------|------------------|-------|
| Stopwatch / confirm actions | Y | Y | `HapticService` |
| Ascent over-limit | Y (repeat) | Y | Inline banner loop |
| Depth 35/38/40 m | Y (throttled) | Y | `DepthLimitHapticCoordinator` |
| Alarms | Y | Y | Throttled 30s |
| GPS confirm | Y | Y | Short confirm |
| Export complete | Y | Y | notify |
| **Audio tones** | **N** | — | Settings states vibration-only (intentional) |
| iOS sounds | **N** | — | No alert sounds; visual feedback only |

**Safety-critical gaps:** None for haptics on Watch MAIN if haptics enabled; simulator may not reproduce all patterns.

---

## H. Hardware Controls Report

| Control | Implementation | Notes |
|---------|----------------|-------|
| Digital Crown | **Y** — `TabView` `.verticalPage` between main tabs | Primary navigation |
| Crown in ScrollViews | Standard scroll in Settings / Log / Legal | Expected |
| Side button / Action Button | **Partial** — App Intents; only 2 shortcuts in catalog | User must assign in watchOS |
| Long press | Not used for critical MAIN flows | — |
| Double-tap (Ultra) | Not mapped | Optional future |

**Fallback:** All critical actions have on-screen buttons (START/STOP, SET BEARING, etc.).

---

## I. Sync Report

| Path | Status | Notes |
|------|--------|-------|
| Watch → iOS dive sessions | **Implemented** | HMAC `WatchDiveSyncCodec`; queue + pending UI |
| iOS → Watch push | **Implemented** | `transferToWatch`, More “Push to Watch”, suppress loop on import |
| Tombstones / deleted IDs | **Implemented** | KVS + application context |
| Conflict resolution UI | **Implemented** (iOS More) | Use Watch / Keep iPhone |
| Offline queue | **Implemented** | Pending/failed counters on Watch |
| Peer secret pairing | **Required** | Until secret exchanged, sync guarded |
| Settings cross-sync | **Not implemented** | Documented local-only |
| **Simulator** | **Partial** | Full WC needs paired devices |

---

## J. Export Report

| Format | Watch | iOS | Validity |
|--------|-------|-----|----------|
| Subsurface CSV | Y (list + detail) | Y (detail) | Metric columns; temp file + ShareLink |
| GPX/KML | N | N | Not in MAIN |
| Import CSV | — | Y | Subsurface-like columns; 10 MB cap |

**UX:** Export failures surface messages; empty samples blocked. Settings “Export” row on Watch is informational only.

---

## K. Safety Report

| Item | Status |
|------|--------|
| NOT a dive computer messaging | **Present** (onboarding + settings) |
| Planner indicative / not certified deco | **Present** |
| TTV not NDL/TTS | **Present** |
| GPS surface-only labeling | **Present** |
| Depth limits 35/38/40 m discouragement | **Present** (`6cda004`) |
| Exceeded depth log flag | **Present** |
| Water submersion entitlement | **Portal** on `com.egopfe.dirdiving.ios.watch` — **must be approved** for real depth |
| App Store screenshots / privacy nutrition | **Not verified** in repo |
| Dangerous default (40 m user alarm) | Overlaps with safety state; configurable |

**App Store risks:** Missing marketing assets; entitlement proof; legal review of Italian/English disclaimer files.

---

## L. Error / Empty State Report

| Condition | Watch | iOS |
|-----------|-------|-----|
| No dives | Export message | Logbook + Analysis empty cards |
| No GPS | Labeled noFix/fallback | n/d in detail |
| No depth sensor | Manual dive panel + error string | N/A |
| No iPhone / WC | Status + retry queue | More sync panel |
| Sync fail | Failed transfer count | Status string |
| Export fail | Banner message | Alert text |
| Permissions denied | GPS row red / compass blocked | System prompts |
| Load error | `DiveLogStore` banner | Rare |

**Silent failures:** iCloud without entitlement still saves locally (documented). Depth on simulator without manual start can look “idle” — mitigated by copy.

---

## M. Bugs To Fix

| Title | Platform | Location | Sev. | Impact | Fix | Impact |
|-------|----------|----------|------|--------|-----|--------|
| Real depth unvalidated on Ultra | Watch | `DiveManager` + entitlement | **CRITICAL** | No production depth without Apple approval | Process + device QA | External |
| Physical sync/tombstone QA not done | Both | `WatchSyncService` | **HIGH** | Data loss perceived in field | Playbook Phase 3–4 | QA |
| CSV import hidden when logbook has data | iOS | `AnalysisView` | **MED** | User cannot import second file easily | Add import in More/Logbook | Small functional |
| Planner result tabs non-functional | iOS | `PlanResultView` | **MED** | Confusing UX | Wire tabs or remove | UI-only |
| Planner mode picker display-only | iOS | `PlannerView` | **MED** | Misleading | Label or implement | Small functional |
| Residual hardcoded Italian (Watch Settings) | Watch | `SettingsView` etc. | **LOW** | EN users see IT | i18n keys | UI-only |
| Units picker missing on iOS | iOS | `MoreView` | **LOW** | Imperial unavailable in UI | Add picker | UI-only |
| Watch Settings export row placeholder | Watch | `SettingsView` | **LOW** | Looks broken | Link to log export | UI-only |
| `contextMenu` deprecated | Watch | `DiveLogListView` | **LOW** | Future SDK warning | `swipeActions` | UI-only |
| Legal scroll honor-system | Both | Onboarding | **LOW** | Compliance nuance | Optional scroll detection | UI-only |

---

## N. Priority Roadmap

### 1. Must fix before compile/use

- None blocking compile (all builds passed 2026-05-23).

### 2. Must fix before TestFlight

- Apple Developer: **Water Submersion** on `com.egopfe.dirdiving.ios.watch`  
- Physical Watch Ultra depth + sync playbook execution  
- Re-run legal onboarding QA after revision `2026-05-23`  
- App icons / launch screens / privacy manifest review  

### 3. Must fix before App Store

- All TestFlight items + marketing copy review  
- Proof of depth behavior on supported hardware  
- Resolve planner misleading UI (tabs/mode) or document as beta  
- Complete EN localization on primary settings surfaces  

### 4. Post-release

- Action Button intent catalog expansion  
- Settings cross-sync  
- Imperial units  
- Remove dead Watch views (`GPSStartRegisteredView`, etc.)  

---

## O. Final Verdict

| Question | Answer |
|----------|--------|
| **Ready to compile?** | **YES** — `xcodegen` + Watch + iOS (named and generic sim) succeeded. |
| **Ready for internal test?** | **YES** — with playbook + paired devices + depth checklist. |
| **Ready for average user?** | **CONDITIONAL** — simulator lacks real depth; legal re-accept required; sync needs iPhone. |
| **Ready for TestFlight?** | **CONDITIONAL** — after entitlement + physical QA. |
| **Ready for App Store?** | **NO** — entitlement, field validation, store assets, planner polish. |
| **What blocks 100%?** | Physical Ultra depth proof; approved submersion on new Watch bundle ID; device sync QA; App Store package; residual UX polish (planner tabs, import discoverability, i18n). |

---

*Audit generated 2026-05-23 · DIR DIVING · audit-only · no repository code modified.*
