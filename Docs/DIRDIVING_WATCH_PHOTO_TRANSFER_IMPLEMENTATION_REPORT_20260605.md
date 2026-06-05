# Watch Photo Transfer — Implementation Report (2026-06-05)

Implementation of audit fixes from `DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md`.

## Files changed

| File | Change |
|------|--------|
| `Utils/WatchSyncKeys.swift` | Shared companion-photo metadata + ACK keys |
| `iOSApp/Utils/WatchSyncKeys.swift` | Same keys on iOS |
| `Utils/CompanionPhotoImportSupport.swift` | **New** — unique destination URLs, ACK payload builder, safe error codes |
| `iOSApp/Utils/CompanionPhotoTransferSupport.swift` | **New** — transfer status model, UUID filenames, ACK parse/apply |
| `iOSApp/Services/WatchSyncService.swift` | Lifecycle tracking, `didFinish fileTransfer`, ACK receive |
| `Services/WatchSyncService.swift` | Import ACK delivery via `sendMessage` / `transferUserInfo` |
| `iOSApp/Views/WatchPhotoTransferPanel.swift` | UUID `photoID`, truthful status display |
| `Services/UserImageStore.swift` | Returns stored filename; no silent overwrite |
| `Views/UserImagesView.swift` | Page dots match image count; select newest on arrival |
| `iOSApp/Services/WatchPhotoPreprocessor.swift` | Resize renderer uses `scale = 1` for correct pixel bounds |
| `iOSApp/Resources/en.lproj/Localizable.strings` | `watch_photo_status_*` strings |
| `iOSApp/Resources/it.lproj/Localizable.strings` | Italian status strings |
| `Tests/iOSAlgorithmTests/CompanionPhotoTransferPipelineTests.swift` | **New** — iOS pipeline + ACK unit tests |
| `Tests/WatchAlgorithmTests/CompanionPhotoImportSupportTests.swift` | **New** — Watch import + dedup tests |
| `project.yml` | Test target source membership for new helpers |

## Transfer status behavior

### Before

- iOS called `WCSession.transferFile()` and immediately showed final success (“imported on Watch”).
- No tracking of WatchConnectivity delivery or Watch-side import.
- Filenames used second-level timestamps (`companion_<epoch>.jpg`), risking collisions on rapid sends.
- Watch could silently overwrite an existing file with the same name.
- Gallery page dots forced a minimum of four regardless of actual image count.

### After

iOS exposes `companionPhotoTransfer` with states:

| State | User-facing string (EN) | When set |
|-------|-------------------------|----------|
| `sending` | Sending to Watch | Preparing temp file |
| `queued` | Queued for Watch | After `transferFile()` succeeds |
| `deliveredToConnectivity` | Delivered to WatchConnectivity | `session(_:didFinish:fileTransfer:error:)` with no error |
| `importedOnWatch` | Imported on Watch | Watch ACK `status == imported` |
| `rejectedByWatch` | Rejected by Watch | Watch ACK `status == rejected` |
| `failed` | Photo transfer failed | Validation, WC error, or unreachable Watch |

**Important:** iOS never shows “Imported on Watch” until the Watch sends an acknowledgement.

## ACK payload

Watch → iOS (via `sendMessage` when reachable, else `transferUserInfo`; `sendMessage` failure also queues `transferUserInfo`):

### Success

```json
{
  "type": "companionPhotoAck",
  "photoID": "<uuid>",
  "status": "imported",
  "storedFileName": "companion_<uuid>.jpg"
}
```

### Rejection

```json
{
  "type": "companionPhotoAck",
  "photoID": "<uuid>",
  "status": "rejected",
  "errorCode": "invalidImage | tooLarge | unsupportedFormat | storageFailed | unknown"
}
```

iOS handles ACK in both `didReceiveMessage` and `didReceiveUserInfo`.

Transfer file metadata (iOS → Watch):

```json
{
  "photoID": "<uuid>",
  "photoFileName": "companion_<uuid>.jpg"
}
```

## Duplicate filename handling

1. **Primary:** iOS generates `companion_<UUID>.jpg` — collisions are practically impossible.
2. **Defensive (Watch):** `CompanionPhotoImportSupport.uniqueDestinationURL` appends `-2`, `-3`, … if the preferred name already exists. `importCompanionPhoto` returns the actual stored name for the ACK.

## Tests added

### iOS (`CompanionPhotoTransferPipelineTests`)

1. Valid JPEG accepted; output is JPEG-compatible
2. Oversized image resized within max dimension
3. PNG converted to JPEG-compatible output
4. UUID filenames do not collide (50 rapid generations)
5. Shared metadata keys match expected values
6. Imported ACK → `importedOnWatch`
7. Rejected ACK → `rejectedByWatch`

### Watch (`CompanionPhotoImportSupportTests`)

1. Corrupt bytes rejected by validator
2. `uniqueDestinationURL` appends suffix instead of overwriting
3. Import creates `UserImages` directory when missing
4. Import stores normalized `.jpg`
5. Import returns actual stored filename
6. Duplicate preferred names produce distinct files (`-2` suffix)
7. ACK payload uses shared metadata keys

## Build / test results

| Command | Result |
|---------|--------|
| `xcodegen generate` | ✅ |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS' build` | ✅ |
| `xcodebuild -scheme "DIRDiving Watch App" -destination 'generic/platform=watchOS' build` | ✅ |
| `xcodebuild test -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:…CompanionPhotoTransferPipelineTests` | ✅ 7/7 |
| `xcodebuild test -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' -only-testing:…CompanionPhotoImportSupportTests` | ✅ 7/7 |

Note: `iPhone 16` simulator is not installed on this machine; `iPhone 17` (iOS 26.5) was used instead.

## Remaining limitations

- Only the **latest** transfer is shown in `WatchPhotoTransferPanel` (`companionPhotoTransfer` is a single published value). Rapid consecutive sends overwrite the displayed status (files on Watch are still preserved).
- ACK correlation requires `photoID` in transfer metadata; missing `photoID` still imports on Watch but sends no ACK.
- `deliveredToConnectivity` means WC accepted the file, not that the Watch app has imported it yet.
- Physical two-device QA (pairing, background delivery, airplane mode recovery) is not automated.

## Manual QA matrix

| # | Scenario | Expected |
|---|----------|----------|
| 1 | Send small JPEG from iOS | Watch receives image |
| 2 | After pick + send | iOS shows **Queued** / **Sending**, not “Imported” |
| 3 | After Watch imports | iOS shows **Imported on Watch** only after ACK |
| 4 | Watch IMMAGINI page | Updates without relaunch when photo arrives |
| 5 | Open image detail | Image renders at enlarged size |
| 6 | Send PNG | Converts and imports as `.jpg` |
| 7 | Send HEIC (if picker provides) | Converts and imports |
| 8 | Send large image / panorama | Resized; transfer within size cap |
| 9 | Send two images rapidly | Both remain on Watch (distinct UUID names) |
| 10 | Disable connectivity, send, reconnect | Deferred delivery; final state matches ACK |
| 11 | Watch 41 mm / 45 mm / 49 mm | Gallery dots and layout unchanged; dots = count |
| 12 | EN / IT localization | Status strings localized |
