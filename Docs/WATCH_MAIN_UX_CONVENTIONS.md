# Watch MAIN — UX conventions (product baseline)

**Last updated:** 2026-05-20  
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

## Mode selection on launch (accepted for now)

`ModeSelectionView` as the first vertical page on cold launch is **acceptable** for the current release.

---

## Related open items (not conventions)

GPS start/end confirmation still uses a full-screen overlay for ~2.4 s — see audit UX-H2 / SAF-2; separate from this ascent alarm policy.
