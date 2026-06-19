# Watch MAIN — UX conventions (product baseline)

**Last updated:** 2026-05-26
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

**Visual reference:** `Docs/FeatureScreenshots/02-ascent-warning.png` (inline ascent banner).

**Do not:**
- Hide the ascent gauge during the alarm
- Replace the entire live screen with `AscentWarningView` full-screen layout
- Change ascent thresholds or rate calculation when adjusting this UI

---

## Mode selection on launch

On current `main`, when Diving is the only stable mode, cold launch should **auto-skip** `ModeSelectionView` and enter the standard MAIN flow (legal gate if needed, then Live). `ModeSelectionView` remains dormant for future multi-mode stable builds and must not reappear on MAIN by accident.

---

## Surface manual dive entry

On current `main`, the Watch surface/live home state must expose an on-screen **Start Dive** action.

| Requirement | Policy |
|-------------|--------|
| Visibility | Visible on the surface/live entry state before an active dive begins |
| Interaction | Starts a manual dive session without requiring the user to wait for automatic depth detection |
| Automatic start | Must remain active; manual start does **not** disable the automatic depth-driven lifecycle |
| Duplicate protection | Must not create a second session if a dive is already active |
| Layout | Reuse existing button style/patterns; no redesign of the live header or primary metric hierarchy |

This manual entry is a stable MAIN affordance, not an experimental fallback hidden behind sensor unavailability.

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

---

## Mission Mode

Mission Mode on current MAIN is a **DIR DIVING internal runtime/UI optimization profile**. It is **not** Apple Watch system Low Power Mode.

| Requirement | Policy |
|-------------|--------|
| Activation | After `isDiveActive == true` when auto-enable is on, manual pending from surface, manual toggle on Live, or draft restore with auto-enable on |
| Dive start paths | Automatic depth-driven and manual start; active-dive draft restore re-applies when auto-enable is on |
| Deactivation | Automatic at dive end; auto-enable preference unchanged; manual pending cleared |
| Manual control | Surface: Settings enable/disable; active dive: compact bolt control on Live header (Settings shows hint) |
| Allowed optimizations | Reduce non-essential animations and decorative shadows on Live and Compass only |
| Visual indicator | Small bolt control near the octopus on Live during active dive (filled = on, outline = off) |
| Forbidden changes | No change to depth sampling, logging, ascent logic, warning logic, alarm thresholds, haptics policy, GPS, or dive calculations |
| Copy | Settings and Info must state Mission Mode does not enable Apple system Low Power Mode |

Mission Mode must **not** suppress or delay safety-critical information. Depth, runtime, ascent warning state, supported-depth warnings, existing haptics, and other critical alerts remain active.
