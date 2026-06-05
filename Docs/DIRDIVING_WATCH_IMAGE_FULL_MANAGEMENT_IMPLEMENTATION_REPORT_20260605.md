# Watch Image Full Management — Implementation Report (2026-06-05)

Implementation of `DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt` (Option 1 + Option 2 + full inventory sync).

## Preflight

| Item | Value |
|------|-------|
| Branch | `main` |
| Baseline commit (start) | `7eea941` |
| Targets | `DIRDiving Watch App`, `DIRDiving iOS` |
| Experimental exclusions | Unchanged (`project.yml` excludes preserved) |

## Files modified / added

| File | Change |
|------|--------|
| `Services/UserImageStore.swift` | Delete API, metadata, uploaded inventory builder |
| `Views/UserImagesView.swift` | Trash button, confirmation, fullscreen dismiss on delete |
| `Services/WatchSyncService.swift` (Watch) | Inventory response, delete request handling, inventory push after import/delete |
| `iOSApp/Services/WatchSyncService.swift` | Inventory state, delete requests, ACK handling |
| `Utils/WatchSyncKeys.swift` / `iOSApp/Utils/WatchSyncKeys.swift` | Inventory + delete protocol keys |
| `Utils/CompanionPhotoManagementSupport.swift` | **New** — shared inventory/delete payloads (Watch) |
| `iOSApp/Utils/CompanionPhotoManagementSupport.swift` | **New** — iOS inventory/delete models + parsers |
| `iOSApp/Views/WatchPhotoTransferPanel.swift` | Manage Watch Images section |
| `Resources/*/Localizable.strings` | Watch delete strings |
| `iOSApp/Resources/*/Localizable.strings` | Manage/inventory/delete strings |
| `Tests/WatchAlgorithmTests/UserImageStorePolicyTests.swift` | Delete + inventory tests |
| `Tests/WatchAlgorithmTests/CompanionPhotoManagementTests.swift` | **New** |
| `Tests/iOSAlgorithmTests/CompanionPhotoManagementIOSTests.swift` | **New** |
| `project.yml` | Test target sources for management support |

## A. Watch local delete

- `canDeleteImage(named:)` / `deleteImage(named:)` / `deleteUploadedImage(named:)` restrict deletion to `Documents/UserImages`.
- Path traversal, nested paths, and bundle assets are rejected.
- Detail view shows trash only for deletable uploaded images.
- Destructive confirmation before removal.
- Fullscreen closes on delete; list/selection refreshes immediately.
- Watch publishes inventory update after local delete.

## B. Full inventory sync

**Model:** `WatchUserImageInventoryItem` (storedFileName, displayName, importedAt, byteCount, dimensions, isUploaded, isDeletable).

**Watch source of truth:**
- Inventory rebuilt from `Documents/UserImages` on reload.
- Lightweight metadata persisted in `Documents/UserImages/metadata.json` on import.
- Missing metadata falls back to file attributes + ImageIO dimensions.

**Protocol:**
- Request: `companionPhotoInventoryRequest` + `requestID`
- Response: `companionPhotoInventoryResponse` + `items` + `generatedAt` + `status`

**iOS state:**
- `watchImageInventory`, `watchImageInventoryStatus` (unknown/loading/loaded/stale/watchUnavailable/failed)
- `lastInventoryRefreshDate`, `inventoryErrorMessage`
- Refresh on panel open and after successful photo import ACK / delete ACK

## C. iOS remote delete with ACK

**Protocol:**
- Request: `companionPhotoDeleteRequest` + `requestID` + `storedFileName`
- ACK: `companionPhotoDeleteAck` + statuses `deleted` / `notFound` / `rejected` / `failed`

**iOS behavior:**
- `requestDeletePhotoOnWatch(storedFileName:)` tracks `pendingDeleteRequests` by requestID.
- Success shown only after ACK (`deletedOnWatch`, etc.).
- Duplicate ACKs ignored via handled request ID set.
- Unknown request IDs ignored safely.
- Inventory refresh requested after terminal delete ACK.

## Security

- Filename sanitization reuses companion photo sanitizer.
- URLs resolved only under `Documents/UserImages` with prefix check.
- Bundle `UserImages` assets never deleted.
- Inventory parser drops items with `/` or `..` in filenames.

## Tests added

### Watch
- Delete uploaded document image
- Path traversal rejection
- Inventory contains uploaded images
- Inventory updates after delete
- Import support tests (existing) still pass
- Management protocol key/payload tests

### iOS
- Inventory response mapping
- Delete ACK state mapping (deleted/rejected/notFound/failed)
- Shared key parity
- Existing photo transfer pipeline tests still pass

## Build / test results

| Command | Result |
|---------|--------|
| `xcodegen generate` | ✅ |
| `xcodebuild -scheme "DIRDiving Watch App" -destination 'generic/platform=watchOS' build` | ✅ |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS' build` | ✅ |
| Watch tests (`UserImageStorePolicyTests`, `CompanionPhotoManagementTests`, `CompanionPhotoImportSupportTests`) | ✅ 16/16 |
| iOS tests (`CompanionPhotoManagementIOSTests`, `CompanionPhotoTransferPipelineTests`) | ✅ 11/11 |

## Remaining future work

- Bulk “clear all uploaded images” UI (API exists: `deleteAllUploadedImages()`).
- iOS thumbnail previews in manage list.
- Multi-device / unreachable Watch edge QA on physical hardware.
- Optional inventory snapshot embedded in delete ACK (currently refresh-after-ACK).

## Manual QA checklist

| # | Scenario | Expected |
|---|----------|----------|
| 1 | Upload one photo from iOS | Appears in iOS Manage Watch Images after refresh/ACK |
| 2 | Delete from Watch detail | Image removed; iOS inventory refreshes |
| 3 | Upload two photos | Both listed on iOS |
| 4 | Delete one from iOS | Pending → deleted only after Watch ACK; Watch gallery updates |
| 5 | Keep second image | Remains on Watch and in inventory |
| 6 | Delete last from Watch | Empty states on Watch + iOS |
| 7 | Watch unreachable | iOS shows unavailable/stale, not fake inventory |
| 8 | Delete stale filename from iOS | `notFound` ACK |
| 9 | Bundled image on Watch | Trash hidden; delete rejected if forced |
| 10 | Fullscreen + delete | Fullscreen dismisses safely |

## Confirmation

- ✅ MAIN only; experimental targets untouched
- ✅ No UI redesign beyond required controls
- ✅ No dive/planner algorithm changes
- ✅ Existing photo upload + import/reject ACK preserved
- ✅ Existing fullscreen viewing preserved
- ✅ Watch is source of truth; iOS does not invent inventory
- ✅ iOS delete success only after Watch ACK
