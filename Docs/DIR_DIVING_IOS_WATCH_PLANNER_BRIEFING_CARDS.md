# DIR DIVING — iOS → Apple Watch Planner Briefing Cards

## Purpose

The Planner Briefing feature exports **static reference image cards** from the iOS MAIN Planner to a paired Apple Watch MAIN app. Cards are generated from **already-calculated** planner presentation output only:

- **Deco Stops** / **Tappe Decompressione**
- **Dive Runtime** / **Runtime immersione**

This is a visual briefing / reference-card feature. It is **not** a live decompression computer, certified schedule, or replacement for the live dive interface.

**This feature does not modify Bühlmann, CCR, Ratio Deco, gas or Rock Bottom algorithms.**

## iOS generation flow

1. User opens Planner results (`PlanResultView`).
2. **Send Briefing to Watch** builds export rows from:
   - `DecoStopsPresentationBuilder` rows (deco stops)
   - `PlannerAscentTableRow` values (runtime)
3. `PlannerBriefingImageExportService` renders PNG cards (no planner math).
4. `PlannerBriefingWatchTransferService` queues files via WatchConnectivity.

## Watch receive / store / display flow

1. `WatchSyncService.session(_:didReceive:)` routes files with `transferType` metadata.
2. `PlannerBriefingWatchReceiver` stages card PNGs, then commits on manifest import.
3. `PlannerBriefingCardStore` validates SHA256, size, and PNG type; stores under Application Support.
4. `PlannerBriefingCardsView` (Settings → **Planner Briefing** / **Briefing Planner**) displays cards.

## Image specifications

| Property | Value |
|----------|-------|
| Width | 410 px |
| Height | 502 px |
| Format | PNG |
| Max rows per card | 8 |
| Max card size | 1 MB |
| Max package size | 5 MB |
| Style | Dark background, white text, cyan accents |

## Card types

| Kind | Source | Footer |
|------|--------|--------|
| `decoStops` | Existing deco stop presentation rows | `DIR DIVING — REF ONLY` + `NOT A CERTIFIED DECO COMPUTER` |
| `runtime` | Existing ascent/runtime table rows | `NOT A CERTIFIED DECO COMPUTER` when runtime includes deco stops; otherwise `REF ONLY` |

## WatchConnectivity transport

- **Method:** `WCSession.transferFile(_:metadata:)`
- **Card metadata:** `transferType=plannerBriefingCard`, `packageId`, `cardId`, `order`, `fileName`, `contentHashSHA256`, `referenceOnly=true`
- **Manifest:** JSON file with `transferType=plannerBriefingManifest` (sent after cards)
- **Ack:** Watch sends `type=plannerBriefingAck` via `transferUserInfo`
- **iOS states:** generating → sending → queued (files enqueued) → sent (ack received) or failed

## Storage policy (Watch)

- Latest package **replaces** the previous package.
- Staging directory per `packageId` during transfer.
- Orphan staged files removed after successful manifest import.
- User can delete briefing from Watch UI.
- Not stored in Photos; no internet required.

## Safety wording

Every generated card includes:

- `DIR DIVING — REF ONLY`
- Deco cards and runtime-with-deco cards also include `NOT A CERTIFIED DECO COMPUTER`

Watch UI shows **REF ONLY** / **SOLO RIFERIMENTO** near the briefing title.

## Known limitations

- Static image cards only; Watch does not recalculate decompression.
- Reference-only; not certified decompression guidance.
- Cards are **not** auto-opened during live dive.
- Delivery may remain **queued** until Watch receives files; iOS reports queued vs sent honestly.
- Long tables split into multiple cards (e.g. Runtime 1/2).

## Out of scope (unchanged)

- BühlmannEngine / BuhlmannPlanner
- DecoStop calculation
- Runtime row generation math
- Gas planning / Rock Bottom / CCR / Ratio Deco
- MOD / PPO2 / CNS / OTU calculations
- Live dive UI integration
