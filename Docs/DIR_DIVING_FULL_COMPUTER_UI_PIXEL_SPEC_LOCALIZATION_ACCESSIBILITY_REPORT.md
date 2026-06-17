# DIR Diving — Full Computer UI Pixel Spec, Localization & Accessibility (Command 11)

## Delivered

### Design-system alignment
- Full Computer live panels use `DiveUI.panelFill`, `DiveUI.panelRadius`, and DIR blue for technical labels/units.
- Metric hierarchy: white oversized depth values, blue units, green/yellow/red safety accents on values and borders.
- Startup rows (activity + diving mode) use `DiveUI.Typography.rowTitle`.

### State coverage
- Distinct titles for **too shallow** and **too deep** stop guidance.
- `FullComputerLivePanelFixtures` provides deterministic fixtures for the 20-state visual regression matrix.
- Pre-dive sensor unavailability now blocks start (`FullComputerPrediveReadiness`).

### Localization (IT + EN)
- Added units (`live.unit.min`, `live.unit.m`), PPO2 label, verify-cylinder note, gas-switch a11y strings, stop titles, recovery hints, diving-mode hints.
- Removed hardcoded `m`, `min`, `PPO2` from FC live and gas-switch views.

### Accessibility
- Gas switch overlay: summary label, ignore hint, depth announcement.
- Missed gas switch panel: combined VoiceOver summary.
- Runtime deco gas list rows: label + hint.
- Deco stop panel: stops remaining + ascent allowed in a11y summary.
- Recovery banner: hint + optional quarantine diagnostic text.
- Diving mode rows: semantic hints for Gauge vs Full Computer.

### Tests
- `FullComputerUIStateMatrixTests` — 20-state matrix, NDL thresholds, localization keys, predive sensor gate, distinct stop titles.
- Updated `FullComputerDecoStopStateMachineTests` for new title keys.

## Files
- `Views/FullComputerLivePanels.swift`, `FullComputerGasSwitchViews.swift`, `DiveLiveView.swift`
- `Views/ActivitySelectionView.swift`, `DivingModeSelectionView.swift`, `FullComputerPrediveConfirmationView.swift`
- `Utils/FullComputerLivePanelFixtures.swift`, `Utils/FullComputerDecoStopStateMachine.swift`
- `Resources/en.lproj/Localizable.strings`, `Resources/it.lproj/Localizable.strings`
- `Tests/WatchAlgorithmTests/FullComputerUIStateMatrixTests.swift`
