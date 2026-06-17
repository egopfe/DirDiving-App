# DIR DIVING — iOS → Watch Planner Briefing Cards — Implementation Report

## Branch / commit

| Item | Value |
|------|-------|
| Branch | `main` |
| Starting commit | `1137420` |
| Report commit | uncommitted working tree |

## Files added

### Shared / iOS
- `Models/PlannerBriefingCard.swift`
- `iOSApp/Services/PlannerBriefingImageExportService.swift`
- `iOSApp/Services/PlannerBriefingWatchTransferService.swift`
- `Tests/iOSAlgorithmTests/PlannerBriefingImageExportServiceTests.swift`
- `Tests/iOSAlgorithmTests/PlannerWatchBriefingTransferTests.swift`

### Watch
- `Services/PlannerBriefingCardStore.swift`
- `Services/PlannerBriefingWatchReceiver.swift`
- `Views/PlannerBriefingCardsView.swift`
- `Tests/WatchAlgorithmTests/PlannerBriefingCardStoreTests.swift`
- `Tests/WatchAlgorithmTests/PlannerBriefingReceiverTests.swift`

### Docs
- `Docs/DIR_DIVING_IOS_WATCH_PLANNER_BRIEFING_CARDS.md`

## Files modified

- `App/DIRDivingApp.swift` — briefing store + environment
- `iOSApp/App/DIRDivingiOSApp.swift` — transfer service + WatchSync wiring
- `iOSApp/Views/PlannerView.swift` — **Send Briefing to Watch** in `PlanResultView`
- `iOSApp/Services/WatchSyncService.swift` — planner briefing ack handling
- `Services/WatchSyncService.swift` — receive/route briefing files + ack
- `Views/SettingsView.swift` — navigation to Planner Briefing
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Resources/en.lproj/Localizable.strings`
- `Resources/it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/PlannerPresentationTests.swift`
- `project.yml`

## Card image specs

| Property | Value |
|----------|-------|
| Width | 410 px |
| Height | 502 px |
| Format | PNG (`scale = 1`) |
| Rows per card | max 8 |
| Max card | 1 MB |
| Max package | 5 MB |

## Transport

- `WCSession.transferFile(_:metadata:)`
- Cards first, manifest JSON last
- Watch ack via `transferUserInfo` (`type=plannerBriefingAck`)
- iOS: **queued** after enqueue; **sent** only after Watch ack

## Storage policy (Watch)

- Application Support / `PlannerBriefing`
- Latest package replaces previous
- Staged per `packageId` until manifest commit
- Manual delete in Settings → Planner Briefing

## UI entry points

| Platform | Entry |
|----------|-------|
| iOS | Planner results → **Send Briefing to Watch** / **Invia briefing al Watch** |
| Watch | Settings → Advanced → **Planner Briefing** / **Briefing Planner** |

## Safety wording

- Card header/footer: `DIR DIVING — REF ONLY`
- Deco / runtime-with-deco cards: `NOT A CERTIFIED DECO COMPUTER`
- iOS button footnote + Watch view: localized reference-only strings

## Tests added/updated

| Test | Result |
|------|--------|
| `PlannerBriefingImageExportServiceTests` (7) | Passed |
| `PlannerWatchBriefingTransferTests` (2) | Passed |
| `PlannerPresentationTests` (incl. briefing keys) | Passed |
| `PlannerAscentTableTests` | Passed |
| `PlannerBriefingCardStoreTests` (2) | Passed |
| `PlannerBriefingReceiverTests` (2) | Passed |
| `GasPlanningServiceTests` | Passed |
| `ScheduleGasConsumptionServiceTests` | Passed |

Watch simulator used: **Apple Watch Ultra 3 (49mm)** (Ultra 2 not available on this Xcode install).

## Build results

| Target | Result |
|--------|--------|
| DIRDiving iOS | **BUILD SUCCEEDED** |
| DIRDiving Watch App | **BUILD SUCCEEDED** |

## Algorithm / scope confirmation

- Bühlmann unchanged
- DecoStop generation unchanged
- Runtime generation math unchanged
- Gas planning unchanged
- Rock Bottom unchanged
- CCR unchanged
- Ratio Deco unchanged
- MOD/PPO2/CNS/OTU unchanged
- No experimental Buddy/Apnea/Snorkeling/Exploration files touched
- No live dive auto-display
- Planner remains reference-only
- No certified decompression claim introduced

## Remaining manual QA

- [ ] Paired iPhone/Watch transfer when Watch reachable
- [ ] Paired iPhone/Watch transfer when Watch unreachable (queued state)
- [ ] Card readability on physical Apple Watch Ultra
- [ ] Delete briefing on Watch
- [ ] Replace old briefing with new package
- [ ] Long runtime splitting across multiple cards on device
