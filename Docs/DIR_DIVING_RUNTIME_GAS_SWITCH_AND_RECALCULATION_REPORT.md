# DIR Diving — Runtime Gas Switch and Recalculation (Command 09)

## Summary

Watch Full Computer runtime gas switching with conservative TTS projection, robust long-press confirmation, missed-switch panel, runtime deco gas list, audit trail, and draft recovery.

## Engine

- `FullComputerGasSwitchTracker` — confirmed gases, ignored opportunities, unavailable gases, audit events.
- `FullComputerGasSwitchPolicy` — breathable validation, suggestion at switch depth, projection gases (confirmed only).
- `FullComputerRuntimeEngine` — `confirmGasSwitch`, `ignoreSuggestedGasSwitch`, `markGasUnavailable`, `dismissMissedGasSwitchPrompt`.
- TTS/ceiling/stops use **active gas only** for future switches until confirmed (no optimistic TTS reduction).

## UI (FC_UI_08–10)

- `FullComputerGasSwitchAvailableView` — CAMBIO GAS DISPONIBILE, long-press CONFERMA.
- `FullComputerGasSwitchMissedPanel` — CAMBIO GAS NON EFFETTUATO, CONTINUA / CAMBIA GAS.
- `FullComputerRuntimeDecoGasListView` — deco gases during dive, ATTIVO / lost / unsafe states.

## Persistence

- Active dive draft schema v4 stores `fullComputerGasSwitchTracker` for mid-dive recovery.

## Tests

- `FullComputerGasSwitchPolicyTests` — suggestion, missed surface, projection filtering.
- **V1.0 remediation:** `FullComputerGasSwitchTimestampTests`, `FullComputerNoAutomaticGasSwitchTests`, `FullComputerFutureGasTTSPolicyTests`; `confirmGasSwitch` rejects unavailable gas IDs.
