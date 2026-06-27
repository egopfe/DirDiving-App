# Watch Water Auto-Open Policy

## Purpose

When watchOS opens DIR Diving after water entry (system Auto-Launch, manual open after submersion, App Intent, or relaunch near submersion), the app can route to a configured startup destination instead of the generic cold-launch flow.

## User options (`WatchWaterAutoOpenMode`)

| Mode | Behavior |
|------|----------|
| Disabled | Uses existing `DIRStartupSelectionPolicy.resolveLaunchStep()` |
| Last selected mode | Routes to last completed activity/mode selection |
| Preferred mode | Routes to user-configured preferred activity (+ Diving mode if applicable) |

## What it does

- Opens the selected **startup destination** (activity UI / Full Computer predive flow)
- Records last selected destination when startup completes via `completeStartup`
- Exposes Settings UI and `OpenWaterAutoLaunchModeIntent` App Shortcut

## What it does not do

- Does **not** start a dive, Apnea, or Snorkeling session automatically
- Does **not** bypass legal/safety acceptance
- Does **not** enter Full Computer live runtime without predive configuration + confirmation
- Does **not** change mode during an active session
- Does **not** force Apple Watch **Settings → General → Auto-Launch → When Submerged** listing (watchOS-controlled)

## Full Computer

Preferred or last-selected Diving + Full Computer resolves to `.fullComputerPrediveConfiguration` via existing `resolveAutomaticStep`. Live runtime requires explicit predive confirmation unchanged.

## Active session protection

`beginWaterAutoLaunch()` respects `canChangeModes` (blocks when Diving, Apnea, or Snorkeling session is active).

## Persistence

Watch-only UserDefaults keys under `WatchWaterAutoOpenPolicy`. Corrupt values fail closed to `disabled` / diving / gauge.

## Rollback

Revert branch; set `dirdiving_watch_water_auto_open_mode` to `disabled` or remove keys. No logbook impact.

See [WATCH_WATER_AUTO_OPEN_IMPLEMENTATION_REPORT_CURRENT.md](WATCH_WATER_AUTO_OPEN_IMPLEMENTATION_REPORT_CURRENT.md).
