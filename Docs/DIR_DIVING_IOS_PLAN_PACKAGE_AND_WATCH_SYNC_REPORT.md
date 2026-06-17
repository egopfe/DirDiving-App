# DIR Diving — iOS Plan Package and Watch Sync (Command 08)

## Summary

Structured Full Computer operational plan transfer from iOS planner to Watch, separate from planner briefing image cards.

## Schema

- `Shared/Models/DivePlanPackage.swift` — Codable package with schemaVersion, algorithmVersion, planID, revision, environment, GF, gases, bottom segments, switches, summary, capabilities, SHA-256 checksum.
- `Shared/Utils/DivePlanPackageCodec.swift` — seal, validate, encode/decode.
- `Shared/Utils/DivePlanPackageTransferSupport.swift` — WatchConnectivity namespace `fullComputerPlanPackage*`.

## Transport (iOS → Watch)

- Application context snapshot (`dirdiving_fc_plan_snapshot`) for latest plan.
- `transferUserInfo` queued delivery for reliability.
- Signed ACK (`fullComputerPlanPackageAck`) with planID, revision, checksum, HMAC via `DivePlanPackageAckSigner`.
- iOS `DivePlanPackageWatchTransferService` pending queue; success only after verified Watch ACK.

## Watch import

- `DivePlanPackageWatchReceiver` validates checksum, schema, GF, gases, expiry.
- `FullComputerImportedPlanStore` atomic local persistence, idempotent checksum tracking, revision ordering; **equal revision + different checksum fails closed**.
- `FullComputerImportedPlanView` — summary, **VERIFICA GAS**, **ATTIVA PIANO** (maps to `FullComputerPrediveConfigurationStore`).
- **Policy A:** package import maps bottom+deco only; activation preserves Watch-native travel/bailout arrays.

## iOS UI

- `DivePlanPackageTransferView` — PIANIFICAZIONE DECO summary per FC_UI_07.
- Planner result link **Send operational plan to Watch** (Deco/Technical Bühlmann).

## Tests

- `DivePlanPackageCodecTests` — round trip, tamper, expiry, future schema, idempotency.
- `DivePlanPackageBuilderTests` — iOS builder + WC payload round trip.

## Compatibility

Briefing cards, logbook, and photo sync namespaces unchanged.
