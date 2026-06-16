# Command 07 — Multigas Models and Pre-dive Configuration Report

**Branch:** `integration/full-computer`

## Domain

- `FullComputerConfiguredGas` — stable UUID, role, FO2/FHe/FN2, max PPO2, switch depth, enabled, availability, sort order.
- `FullComputerGasProfile` — bottom gas kind (Air/EAN/Trimix), deco/travel/bailout lists, GF, future-gas TTS policy.
- `FullComputerGasProfileValidator` — fractions, bottom gas, MOD/MOD, hypoxic, duplicates, ordered switch depths.
- `FullComputerPrediveConfigurationStore` — draft/confirmed persistence, locked during active dive.

## Runtime

- `FullComputerRuntimePlan(profile:)` maps confirmed profile to Bühlmann gases.
- Engine starts with bottom gas only; no automatic gas switching.
- TTS uses enabled deco/travel gases only when `futureGasTTSPolicy == .enabledSwitchGasesOnly`.

## UI

- `FullComputerPrediveSettingsView` — bottom gas segmented control, composition, GF, sensor, deco list link.
- `FullComputerDecoGasListView` — sorted deco gases, add/edit sheet.
- `FullComputerPrediveConfirmationView` — summary with validation-gated AVVIA.

## Startup flow

`divingMode.fullComputer` → `fullComputerPrediveConfiguration` → `fullComputerConfirmation` → Live.

## Tests

`FullComputerGasProfileTests`, updated `DIRModesAndStartupFlowTests`.
