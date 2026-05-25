# Watch MAIN — UX conventions (product baseline)

**Last updated:** 2026-05-25
**Applies to:** Apple Watch `main` branch only (not experimental modes).

These conventions are **accepted product behavior**. Future UI work should treat them as defaults unless the product owner explicitly requests a change.

---

## Ascent speed alarm — inline banner (non-blocking)

When `ascentStatus.isOverLimit` is true during an active dive:

| Requirement | Policy |
|-------------|--------|
| Layout | Red banner **between** TTV/RunTime and the depth block |
| Live metrics | TTV, RunTime, depth, max/avg depth, ascent gauge, stopwatch, and controls **stay visible** |
| Full-screen takeover | **Not used** — no modal, sheet, or replacement of the live dive screen |
| Duration | Banner visible **while** ascent speed remains over limit; auto-hides when condition clears |
| Haptics | Strong warning on first trigger; repeat every **~1.75 s** while active; respect global haptics toggle |
| Localization | `ascent_alarm_title`, `ascent_alarm_instruction`, `ascent_alarm_speed_unit` in `Resources/*.lproj` |

**Code:** `Views/AscentWarningBannerView.swift`, `Views/DiveLiveView.swift`, `Services/HapticService.swift` (`ascentAlarmTriggered`, `ascentAlarmRepeatIfNeeded`).

**Visual reference:** ascent alarm mockup (`ascent_alarm.png`).

**Do not:**
- Hide the ascent gauge during the alarm
- Replace the entire live screen with `AscentWarningView` full-screen layout
- Change ascent thresholds or rate calculation when adjusting this UI

---

## Mode selection on launch

On current `main`, when Diving is the only stable mode, cold launch should **auto-skip** `ModeSelectionView` and enter the standard MAIN flow (legal gate if needed, then Live). `ModeSelectionView` remains dormant for future multi-mode stable builds and must not reappear on MAIN by accident.

---

## Apple Watch controls

| Control | Policy |
|---------|--------|
| Digital Crown | Page navigation, scrollable pages, and threshold tuning controls where present |
| Touch | Primary confirmation path for on-screen actions |
| Action Button | Supported only through watchOS Shortcuts / App Intents when watchOS exposes the actions |
| Side Button | System-controlled; DIR DIVING does not directly override or remap it |

During an active dive, Live remains the primary page and Compass remains reachable. Settings edits are intended for surface use so threshold/preference changes are not accidentally made underwater.

---

## GPS confirmation behavior

GPS start/end confirmation on current MAIN uses a **compact inline banner** that preserves the live metrics context. Do not reintroduce a full-screen GPS takeover on the stable Diving flow.
