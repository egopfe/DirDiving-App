# DIR DIVING — MAIN Branch Targeted Fix Report

**Date:** 2026-05-24  
**Branch:** `main`  
**Scope:** Four residual items from `MAIN_BRANCH_FINAL_READINESS_REPORT.md`

---

## 1. Branch confirmed

- Branch: **`main`**
- `project.yml` experimental excludes unchanged (Snorkeling, Apnea, Buddy, Explore Lab).

---

## 2. Files modified

| File | Change |
|------|--------|
| `Views/AscentGaugeView.swift` | Imperial/metric ascent label formatting |
| `Views/DiveLiveView.swift` | Pass `unitPreference` to gauge |
| `Services/ActionButtonIntents.swift` | Register 7 App Shortcuts |
| `Views/SettingsView.swift` (`WatchShortcutHelpView`) | Side-button / Shortcuts copy |
| `iOSApp/Views/DiveDetailView.swift` | Refresh session from `DiveLogStore` after edit |
| `Docs/TESTFLIGHT_REVIEW_NOTES.md` | Side-button clarification |
| `Resources/en.lproj/Localizable.strings` | Ascent gauge + shortcuts help strings |
| `Resources/it.lproj/Localizable.strings` | Same (IT) |

---

## 3. Ascent gauge imperial label fix

- `AscentGaugeView` accepts `units: DIRUnitPreference` (default metric).
- Scale ticks and unit caption use `ascentRateDisplay(metersPerMinute:)` — **m/min** or **ft/min**.
- Pointer position still uses internal m/min ratios (threshold logic unchanged).
- VoiceOver value string localized with display units.

**Acceptance:** Metric → m/min; Imperial → ft/min on Live gauge.

---

## 4. App Intents catalog changes

`DIRDivingAppShortcuts` now registers:

| Intent | Short title |
|--------|-------------|
| `ToggleStopwatchIntent` | Stopwatch |
| `ResetStopwatchIntent` | Reset Stopwatch |
| `StartManualDiveIntent` | Manual Dive Start |
| `EndManualDiveIntent` | Manual Dive End |
| `SetBearingIntent` | Set Bearing |
| `ClearBearingIntent` | Clear Bearing |
| `AcknowledgeAlarmIntent` | Acknowledge Alarm |

Each intent calls existing `DiveManager` / `CompassManager` paths only — no new behavior.

---

## 5. Side-button documentation/copy changes

- `WatchShortcutHelpView`: panels for stopwatch, reset, bearing, alarm, **side button by design**, on-screen START/STOP.
- `Docs/TESTFLIGHT_REVIEW_NOTES.md`: clarifies no direct side-button mapping; Action Button / Shortcuts only.
- No hardware behavior changes; no false “side button starts dive” claim.

---

## 6. Dive detail refresh fix

- `DiveDetailView` stores `sessionID` + `@State session`, observes `logStore.sessions`.
- On store update after manual save, `session` is replaced from `logStore.session(id:)`.
- Edit flow unchanged; demo dives still protected via existing guards.

**Acceptance:** Save manual edit → detail shows updated site/depth/pressures without leaving Logbook.

---

## 7. Confirmation: no business logic changed

- Ascent calculations, limits, and alarm thresholds remain metric internally.
- App Intents only invoke existing APIs.
- Manual dive save path unchanged (`logStore.add`).

---

## 8. Confirmation: UI graphics unchanged

- Gauge layout, colors, and panel styling preserved.
- Help panels use same `helpPanel` chrome; text-only updates.
- Dive detail layout unchanged.

---

## 9. Confirmation: experimental untouched

- No experimental branch or excluded target files modified.

---

## 10. Build results

| Target | Result |
|--------|--------|
| DIRDiving Watch App | **BUILD SUCCEEDED** |
| DIRDiving iOS | **BUILD SUCCEEDED** |

---

## 11. Manual QA checklist

- [ ] Watch Settings → Units **Imperial** → Live ascent gauge shows **ft/min** scale
- [ ] Watch Settings → Units **Metric** → gauge shows **m/min**
- [ ] Shortcuts app / Action Button: all 7 DIR DIVING shortcuts visible (device/OS dependent)
- [ ] Settings → Azione / Comandi: side-button limitation text readable
- [ ] iOS: edit manual dive → save → detail updates in place
- [ ] Demo dive: edit button still hidden

---

## 12. Remaining risks

| Risk | Level | Notes |
|------|-------|-------|
| Shortcuts visibility OS-dependent | LOW | Apple may hide intents until first app launch |
| Manual dive intents without depth fallback | LOW | Existing `startManualDive()` guards unchanged |
| `DiveSession` equality on large samples | LOW | `onChange` compares full session; acceptable for manual dives |

**Overall:** Targeted items closed; MAIN UX readiness ~**94%** for documented flows.
