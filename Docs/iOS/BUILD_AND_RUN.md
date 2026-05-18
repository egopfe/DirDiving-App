# Build and run

This file documents the stable iOS Companion build path. The root `project.yml` also contains the watchOS app target.

## Generate the project

```bash
xcodegen generate
```

## Open in Xcode

```bash
open DIRDiving.xcodeproj
```

## Build

1. Select the `DIRDiving iOS` scheme.
2. Select an iPhone simulator or a physical iPhone.
3. Press **Run**.

Available schemes from `project.yml`:

- `DIRDiving iOS`
- `DIRDiving Watch App`

The iOS Companion stable branch exposes Logbook, Route Review, Analysis, Planner, Gear and Settings in the main tab bar. Settings contains WatchConnectivity status/retry, Watch conflict review, iCloud/manual sync, onboarding notes, local units/export status, demo logbook and Subsurface export context. Route Review, Analysis and Gear must use real local/logbook data or clearly label local-only limitations; placeholder-heavy experimental concepts remain out of the stable tab bar.

UI-only visual alignment must not change planner calculations, sync, persistence, models, managers or navigation flows.

## Pre-release validation TODO

- Verificare su macOS che `xcodegen generate` crei correttamente il progetto dal `project.yml` corrente.
- Verificare che tutti i PNG referenziati da `iOSApp/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json` siano presenti prima di una build App Store/TestFlight.
- Eseguire almeno una build `DIRDiving iOS` con Xcode e Apple SDK reali; l'ambiente Windows non puo sostituire questa validazione.
- Testare import/export CSV con file valido, file vuoto e file malformato prima della promozione release.
- Watch MAIN: verificare che `WatchSyncAuth` compili senza `SecureBuddyStore` nel target MAIN e che le esclusioni experimental in `project.yml` restino coerenti.
- Watch MAIN: verificare su Apple Developer portal e Apple Watch Ultra reale l'entitlement `com.apple.developer.coremotion.water-submersion`.
- iOS MAIN: testare peer secret mancante/verificata per Watch sync, re-import CSV anti-duplicato, tombstone KVS/delete e Planner invalid-input/safety acknowledgement.
- Watch MAIN: verificare con build macOS il fix `AscentWarningView` -> `Formatters.zero` committato in `946d3c1`.
- iOS MAIN: verificare con build macOS il fix `PlannerView.swift` / `ResultPanelStyle` / `PlanTab` committato in `33bcb7e`.
- Watch/iOS MAIN: verificare TTV come metrica informativa non-safety, CSV bounds hardening, valori mancanti non-zero, GPS fix-source export e coda Watch sync pending/sent/ack/failed.
- PR #8 e #9: non merge automatico finche `mergeable=CONFLICTING` e i build check restano falliti.

## Signing

Configured values:

```text
Team ID: C6FKKPB6A9
Bundle ID: com.egopfe.dirdiving.ios
```

If automatic signing does not create a provisioning profile, press **Fix Issue** in Xcode.

The companion uses:

```text
Entitlements: iOSApp/Config/DIRDivingiOS.entitlements
Info.plist:   iOSApp/App/Info.plist
Sources:      iOSApp
```
