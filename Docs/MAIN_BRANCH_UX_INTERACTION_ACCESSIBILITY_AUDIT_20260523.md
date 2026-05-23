# DIR DIVING — MAIN Branch UX / Interaction / Feature Accessibility Audit

**Date:** 2026-05-23  
**Type:** Pre-modification audit only — **no code changes**  
**Branch:** `main` @ `6cda004`  
**Scope:** Apple Watch MAIN + iOS Companion MAIN (unified `project.yml`)  
**Out of scope:** Experimental branches/files (Apnea, Snorkeling, Buddy, Exploration) — verified excluded from MAIN targets

**Method:** Static navigation graph tracing, `@AppStorage` / settings inventory, haptic call-site review, hardware intent catalog, sync/export flow tracing, cross-check with [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.md).

**Visual references:** `Docs/ReferenceUI/Watch_LIVE_reference.png`, `Docs/ReferenceUI/iOS_Companion_reference.png`

---

## 1. Feature inventory

Legend: **Impl** = implemented in code · **Reach** = reachable from UI · **Complete** = user can finish flow without dev knowledge

### Apple Watch MAIN

| Feature | Impl | Reach | Complete | Status | Notes |
|---------|------|-------|----------|--------|-------|
| Legal onboarding (4 steps + depth-limits ack) | Y | Y | Y | Complete | Blocks app until accepted; revision `2026-05-23` |
| Mode Selection | Y | **N** | — | **Hidden** | `hasMultipleStableModes = false`; tab not in `ContentView` |
| Live dive (auto + manual) | Y | Y | Partial | Usable | Manual panel when no submersion; Ultra needs entitlement |
| Depth safety 35/38/40 m UI + haptics | Y | Y | Y | Complete | Banner + suppressed max-depth cards when exceeded |
| Stopwatch START/STOP/RESET | Y | Y | Y | Complete | On-screen + 2 App Shortcuts |
| TTV / RunTime panel | Y | Y | Y | Complete | Informational disclaimer in Settings |
| Ascent gauge + inline alarm | Y | Y | Y | Complete | Acknowledge on generic alarm banner |
| BUSSOLA (compass) SET/CLEAR | Y | Y | Y | Complete | Crown scroll to Compass page |
| Dive log list → detail | Y | Y | Y | Complete | Context menu delete |
| Dive delete confirm | Y | Y | Y | Complete | Detail + list confirmation |
| Export latest dive (CSV) | Y | Y | Y | Complete | List button + ShareLink |
| Export dive from detail | Y | Y | Y | Complete | |
| Export from Settings row | Y | **N** | — | **Hidden** | Row is informational only |
| User reference images | Y | **N** | — | **Hidden** | Tab omitted when no bundle images |
| Ascent rate settings | Y | Y | Y | Complete | NavigationLink |
| Alarm thresholds | Y | Y | Y | Complete | Persisted `@AppStorage` |
| Haptics master toggle | Y | Y | Y | Complete | Gates `HapticService` |
| Language IT/EN/System | Y | Y | Y | Complete | Wheel picker |
| Units (metric) | Y | Y | Partial | Imperial explicitly N/A in UI |
| Legal & Safety review | Y | Y | Y | Complete | From Settings |
| Info / battery / depth status | Y | Y | Partial | Read-only diagnostics |
| Sync status + retry/clear queue | Y | Y | Y | Complete | When pending/failed |
| Watch → iPhone session sync | Y | Y | Partial | Needs paired app + peer secret |
| iPhone → Watch (receive) | Y | Y | Partial | Push initiated from iOS |
| Action Button / extra intents | Y | Partial | Partial | Only stopwatch shortcuts in catalog |
| GPS entry/exit feedback | Y | Y | Y | Complete | Timed banner on Live |
| Session recovery after crash | Partial | — | Partial | Local JSON + KVS; no explicit “resume dive” UI |
| Audio tones | N | — | — | By design | Settings documents haptics-only |

### iOS Companion MAIN

| Feature | Impl | Reach | Complete | Status | Notes |
|---------|------|-------|----------|--------|-------|
| Legal onboarding | Y | Y | Y | Complete | Same depth-limits ack |
| Logbook browse/search/delete | Y | Y | Y | Complete | Demo dives protected |
| Dive detail (3 tabs) | Y | Y | Y | Complete | Charts need samples |
| Subsurface export + share | Y | Y | Y | Complete | Detail screen |
| CSV import | Y | **Partial** | Y | **Partial** | **Only** when Analysis empty |
| Analysis aggregates/charts | Y | Y | Y | Complete | Includes demo if enabled |
| Planner inputs + calculate | Y | Y | Y | Complete | Safety ack required |
| Planner mode tabs | Y | Y | **N** | **Broken UX** | UI changes; calculations ignore mode |
| Plan result tabs (PIANO/BÜHLMANN/GRAFICI) | Y | Y | **N** | **Broken UX** | Highlight only; all sections visible |
| Plan result share | Y | Y | **N** | Placeholder | Toolbar icon no action |
| Equipment profile edit/reset | Y | Y | Y | Complete | Auto-save |
| More: language | Y | Y | Y | Complete | Segmented control |
| More: Watch sync + push | Y | Y | Partial | Simulator limited |
| More: sync conflict resolve | Y | Y | Y | Complete | When conflicts exist |
| More: iCloud sync now | Y | Y | Partial | Needs iCloud account |
| More: demo logbook toggle | Y | Y | Y | Complete | Reviewer tool |
| Units imperial/metric | Partial | **N** | — | **Hidden** | `@AppStorage` read; no picker in UI |
| Watch pairing reset (`resetPairingTrust`) | Y | **N** | — | **Hidden** | Service only |
| Notifications / alert sounds | N | — | — | Not in MAIN |
| HR | N | — | — | Not in MAIN |

---

## 2. Navigation map

### Watch MAIN (Digital Crown vertical pages)

```
[Legal gate]
    → LIVE (default) ←→ COMPASS ←→ SETTINGS ←→ [USER IMAGES if assets] ←→ DIVE LOG
         │                              │
         │                              ├→ Ascent rate settings → back
         │                              ├→ Alarm settings → back
         │                              ├→ Legal & Safety → back
         │                              ├→ Shortcut help → back
         │                              └→ Info → back
         └→ (in-dive controls on LIVE)

DIVE LOG → DiveDetail → ExportView (after export)
         ↘ confirmation delete
```

| Route | Entry | Return | Dead end? |
|-------|-------|--------|-----------|
| All main tabs | Crown swipe | Crown swipe | No |
| Settings children | Tap row | System back | No |
| Export completion | After export | Back from ExportView | No |
| Legal gate | Cold launch | Accept only | **Soft dead end** if user refuses (alert only) |
| Mode Selection | — | — | **Unreachable** in default MAIN |

**Swipe:** `TabView` verticalPage — primary navigation is Crown, not edge swipe (watchOS default).

**Side button:** No app-level handler; user must assign Shortcuts/Action Button in watchOS settings.

**Long press:** Not used on MAIN screens (log uses `contextMenu` for delete).

### iOS MAIN (tab bar)

```
[Legal gate]
    → Tab: Logbook → DiveDetail (push)
    → Tab: Analysis → (empty actions) / fileImporter when empty
    → Tab: Planner → PlanResult (push on calculate)
    → Tab: Equipment
    → Tab: More → IOSLegalSafetyView (push)
```

| Route | Entry | Return | Dead end? |
|-------|-------|--------|-----------|
| Tab switching | Tab bar | Tab bar | No |
| Modals | Rare | confirmationDialog on delete/reset | No |
| Deep links | **N** | — | Not implemented |

---

## 3. Settings report

### Watch — exposed in UI (`SettingsView` + children)

| Setting | UI | Persisted | Applied | Sync to iOS |
|---------|-----|-----------|---------|-------------|
| Ascent rate limits | Y | Y (KVS) | Y | No |
| Alarm enable/thresholds | Y | Y | Y | No |
| Haptics on/off | Y | Y | Immediate | No |
| Language | Y | Y | UI locale | No |
| Units metric | Y | Y | Partial | No |
| GPS / depth / sync | Status | — | — | No |
| Screen brightness/AOD | Info only | watchOS | — | No |
| Audio tones | Info (off) | — | — | No |
| Export preferences | **N** | — | — | No |
| Depth safety thresholds | **N** | Fixed 35/38/40 in code | Automatic | No |
| Skip mode selection | **N** | Y (`UserDefaults`) | Y | No |

### Watch — in code but not in Settings UI

| Item | Location | Impact |
|------|----------|--------|
| Skip mode selection flag | `WatchModeSelectionPreferences` | No UI to toggle (defaults on) |
| Depth alarm vs safety 40 m | `DiveManager` + `AlarmSettingsView` | User alarm can overlap safety UX |

### iOS — exposed in UI (`MoreView` + Planner ack + per-screen)

| Setting | UI | Persisted | Applied | Sync to Watch |
|---------|-----|-----------|---------|-------------|
| Language | More | Y | Y | No |
| Planner safety ack | Planner | Y | Gates calculate | No |
| Demo logbook | More | Y | Y | No |
| Watch sync push | More button | — | On demand | WC only |
| iCloud sync | More button | Y | Background | No |
| Units | **N** | Key exists | Formatters only | No |
| Alarms | **N** | Watch-only | — | No |
| Export prefs | Info card | — | — | No |
| Notifications | **N** | — | — | No |

### Settings completeness verdict

| Platform | Settings section exists? | Complete for MAIN scope? |
|----------|--------------------------|---------------------------|
| Watch | **Yes** (rich Settings tab) | **Partial** — export/sync prefs informational; no brightness control |
| iOS | **Yes** (`More` tab = settings) | **Partial** — missing units, alarms, notification prefs |

---

## 4. Hardware interaction report

### Digital Crown (Watch)

| Action | Mapped? | Screens |
|--------|---------|---------|
| Vertical page navigation | **Yes** | All main tabs |
| Scroll within ScrollView | **Yes** | Settings, Log, Legal |
| Custom crown button mapping | **No** | — |

### Side button / Action Button

| Action | In App Shortcuts catalog? | On-screen fallback? |
|--------|---------------------------|---------------------|
| Toggle stopwatch | **Yes** | START/STOP on Live |
| Reset stopwatch | **Yes** | RESET on Live |
| Start/end manual dive | **No** | Manual buttons on Live |
| Set/clear bearing | **No** | SET/CLEAR on Compass |
| Acknowledge alarm | **No** | ACK on banner |

Help screen (`WatchShortcutHelpView`) explains limitations.

### Haptic events (Watch)

| Event | Haptic | Gated | Notes |
|-------|--------|-------|-------|
| Stopwatch start/stop/reset | Y | Y | confirm/notify |
| Ascent over-limit | Y | Y | failure + repeat |
| Depth 35/38/40 m | Y | Y | throttled |
| User alarms (depth/runtime/battery) | Y | Y | warnIfNeeded |
| GPS confirm | Y | Y | confirm |
| Export success/fail | Y | Y | notify |
| Compass set bearing | Y | Y | confirm |
| Dive start (auto) | Partial | — | No dedicated start haptic |
| Dive end | Partial | — | Implicit via GPS confirm |

**iOS:** No haptic/tone layer for sync/export (visual only).

### Long press / gestures

| Gesture | Watch | iOS |
|---------|-------|-----|
| Long press | **Not used** | **Not used** |
| Context menu (log delete) | Y | N/A |
| Swipe delete | **No** | N/A |

---

## 5. UX blockers

| # | Blocker | Platform | Severity | User impact |
|---|---------|----------|----------|-------------|
| 1 | CSV import only from empty Analysis | iOS | **HIGH** | Cannot import after first dive without workaround |
| 2 | Planner result tabs do not switch content | iOS | **MED** | User thinks tabs are broken |
| 3 | Planner mode picker does not affect plan | iOS | **MED** | Misleading “mode” selection |
| 4 | Units preference has no UI on iOS | iOS | **MED** | Imperial users stuck on metric |
| 5 | Settings Export row on Watch non-tappable | Watch | **MED** | False affordance |
| 6 | Legal disclaimer “scrolled to bottom” is honor-system | Both | **MED** | Compliance gap |
| 7 | Mode Selection implemented but hidden | Watch | **LOW** | Dead code path for users |
| 8 | Logbook header +/⋯ decorative | iOS | **LOW** | Suggests missing actions |
| 9 | Plan share button inert | iOS | **LOW** | Dead affordance |
| 10 | Watch pairing reset not in UI | iOS | **LOW** | Recovery requires reinstall/clear |
| 11 | Simulator: no real depth without manual | Watch | **HIGH** | Average user on sim confused |
| 12 | Sync requires physical pairing | Both | **MED** | Expected but opaque when failing |

---

## 6. Safety issues (UX perspective)

| Issue | Severity | Notes |
|-------|----------|-------|
| Depth limit UX + haptics | **Mitigated** | 35/38/40 m states clear |
| Ascent alarm + acknowledge | **OK** | Visible + haptic loop |
| Planner calculate without ack | **Mitigated** | Toggle required |
| GPS failure labeling | **OK** | noFix/fallback strings |
| Silent sync when WC inactive | **MED** | Status rows exist but easy to miss |
| User-configurable depth alarm at 40 m overlaps safety | **LOW** | May duplicate exceeded state |
| No HR (not claimed) | — | N/A |
| Pre-dive haptics-off badge | **OK** | Visible on Live |

---

## 7. Recommended priority order

### Immediate (before wider user test)

1. Fix **CSV import reachability** (add to More or Logbook). — *small functional*  
2. Wire or remove **planner result tabs** and **mode picker** labels. — *UI-only / small*  
3. Make Watch Settings **Export** row navigate to log export or remove chevron. — *UI-only*  
4. Add **iOS units picker** in More. — *small functional*

### Pre-release (TestFlight)

5. Legal onboarding: optional real scroll-to-bottom detection. — *small functional*  
6. Expose **reset Watch pairing** in More (advanced). — *small functional*  
7. Device QA playbook for sync + depth (non-UI). — *process*

### Post-release

8. Promote additional App Intents in catalog. — *small*  
9. `contextMenu` → `swipeActions` on Watch log. — *UI-only*  
10. Settings cross-sync Watch↔iOS if product requires. — *medium*

---

## 8. Code impact report

| Issue cluster | Estimate |
|---------------|----------|
| Import button in More/Logbook | **Small UI fix** (1–2 files) |
| Planner tab wiring | **Small UI fix** or label-only |
| Decorative icons removal | **UI-only** |
| iOS units picker | **Small functional** (MoreView + existing `IOSUnitPreference`) |
| Watch export row link | **UI-only** |
| Settings sync across devices | **Medium refactor** (new sync schema) |
| Mode Selection product decision | **Product** — enable tab or remove code |

**No architectural blocker** found for UX accessibility on MAIN.

---

## 9. Final summary

| Metric | Estimate | Rationale |
|--------|----------|-----------|
| **Release readiness (UX)** | **82%** | Core flows work; several false affordances |
| **UX completeness (Watch)** | **84%** | Strong Live/compass/log; hidden mode/images |
| **UX completeness (iOS)** | **80%** | Five tabs solid; planner chrome partial |
| **Interaction completeness** | **78%** | Crown OK; side button relies on system |
| **Stability (UX flows)** | **85%** | Few dead ends; modals complete |
| **Safety UX completeness** | **86%** | Disclaimers + depth states; sync visibility OK |

| Question | Answer |
|----------|--------|
| Can average user complete a dive → log → export on Watch? | **Yes** (with hardware or manual dive) |
| Can average user sync and review on iPhone? | **Yes**, if paired; conflicts UI when needed |
| Can average user import CSV after first dive? | **No** (blocker) |
| Ready for App Store UX bar? | **No** — fix import + planner misleading UI |

**Overall:** MAIN delivers **reachable core diving and companion workflows** with premium visual language matching references. **Primary UX gaps** are **discoverability** (import, units), **non-functional chrome** (planner tabs, decorative buttons), and **informational-only settings rows** that look actionable. This report is intended to guide **targeted UI fixes** without refactoring business logic.

---

*Audit-only · 2026-05-23 · no repository code modified.*
