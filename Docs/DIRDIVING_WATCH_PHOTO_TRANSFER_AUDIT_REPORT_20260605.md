# DIR DIVING Watch Photo Transfer Audit Report

Date: 2026-06-05

Repository reviewed: `C:\Users\egopf\Documents\GitHub\DirDiving-App`

Branch/commit reviewed: `main` at `ca76a19`

Scope: Verify the iOS companion app image transfer path to the Apple Watch app, confirm whether the image should be shown on Watch, review related UI/UX, identify issues, and provide a fixing plan. No application code was changed.

## Executive Summary

The iOS to Apple Watch photo transfer feature is implemented with the correct high-level architecture:

- iOS picks a photo with `PhotosPicker`.
- iOS preprocesses the image for Watch use.
- iOS sends the binary payload with `WCSession.transferFile`.
- Watch receives the file through `WCSessionDelegate.session(_:didReceive:)`.
- Watch validates, normalizes, and stores the image under `Documents/UserImages`.
- Watch `UserImagesView` reloads and displays the image list/detail view.

Static code review found no blocking defect in the core transfer path. However, the current implementation cannot fully prove to the user that the image was actually imported and displayed on Watch. The iOS UI currently reports success when the file is queued to WatchConnectivity, not when the Watch has completed receipt, validation, storage, and gallery display.

Runtime verification was not possible in the current Windows environment because `xcodebuild`, `xcodegen`, `swift`, the watchOS simulator, and paired Apple Watch hardware are unavailable. Final confirmation must be performed on macOS with an iPhone/Apple Watch pair or watchOS simulator where WatchConnectivity behavior can be observed.

## Evidence Reviewed

### iOS Entry Point

File: `iOSApp/Views/MoreView.swift`

`WatchPhotoTransferPanel()` is included in the Watch sync card, so the user can access photo sending from the iOS companion app settings/more area.

Relevant location:

- `MoreView.swift:69-77`

### iOS Photo Picker and Send Trigger

File: `iOSApp/Views/WatchPhotoTransferPanel.swift`

The view:

- Lets the user choose an image using `PhotosPicker`.
- Loads the selected item as `Data`.
- Calls `WatchPhotoPreprocessor.prepareForWatch(from:)`.
- Sends the prepared bytes through `watchSync.sendPhotoToWatch(...)`.

Relevant locations:

- `WatchPhotoTransferPanel.swift:22-30`
- `WatchPhotoTransferPanel.swift:44-61`

### iOS Image Preprocessing

File: `iOSApp/Services/WatchPhotoPreprocessor.swift`

The preprocessor:

- Decodes the selected bytes as a `UIImage`.
- Resizes images larger than the target max dimension.
- Re-encodes output to JPEG.
- Uses a target max dimension of `400`.
- Uses an optimal byte target of `350_000`.

Relevant locations:

- `WatchPhotoPreprocessor.swift:4-6`
- `WatchPhotoPreprocessor.swift:28-55`

This is a good fit for Apple Watch display because it avoids sending unnecessarily large originals and normalizes the image format.

### iOS WatchConnectivity File Transfer

File: `iOSApp/Services/WatchSyncService.swift`

The sender:

- Checks WatchConnectivity support.
- Checks paired Watch and installed Watch app.
- Enforces a 10 MB maximum photo transfer size.
- Sanitizes the filename and whitelists image extensions.
- Writes the transfer file to a temporary URL.
- Calls `WCSession.default.transferFile(url, metadata: ...)`.

Relevant locations:

- `WatchSyncService.swift:38-39`
- `WatchSyncService.swift:156-178`
- `WatchSyncService.swift:180-196`

This is the correct WatchConnectivity API for binary image transfer.

### Shared Metadata Key

Files:

- `iOSApp/Utils/WatchSyncKeys.swift`
- `Utils/WatchSyncKeys.swift`

Both sides define:

```swift
static let companionPhotoFileNameKey = "photoFileName"
```

The metadata key is consistent between iOS and Watch, so the Watch can recover the intended filename.

Relevant locations:

- `iOSApp/Utils/WatchSyncKeys.swift:7`
- `Utils/WatchSyncKeys.swift:8`

### Watch File Receive and Import

File: `Services/WatchSyncService.swift`

The Watch:

- Implements `session(_:didReceive file:)`.
- Extracts `photoFileName` metadata.
- Calls `UserImageStore.importCompanionPhoto(...)`.
- Updates sync status and recent activity on success/failure.

Relevant locations:

- `WatchSyncService.swift:315-325`
- `WatchSyncService.swift:404-407`

### Watch Image Storage

File: `Services/UserImageStore.swift`

The Watch import flow:

- Sanitizes the incoming filename.
- Checks file size.
- Reads the received file data.
- Validates and normalizes the image.
- Creates `Documents/UserImages`.
- Writes the normalized JPEG with `.completeFileProtection`.
- Posts `.companionPhotoDidArrive`.

Relevant locations:

- `UserImageStore.swift:28-29`
- `UserImageStore.swift:31-39`
- `UserImageStore.swift:43-63`
- `UserImageStore.swift:65-89`
- `UserImageStore.swift:91-111`

### Watch Image Validation

File: `Utils/WatchCompanionPhotoValidator.swift`

The validator:

- Rejects empty or over-size data.
- Decodes bytes as `UIImage`.
- Rejects invalid pixel dimensions.
- Rejects images over the maximum pixel dimension.
- Re-encodes to JPEG.
- Returns a sanitized `.jpg` filename.

Relevant locations:

- `WatchCompanionPhotoValidator.swift:28-30`
- `WatchCompanionPhotoValidator.swift:32-62`

This is a strong safety layer because non-image data with a fake `.jpg` extension will be rejected.

### Watch Gallery UI

File: `Views/UserImagesView.swift`

The Watch UI:

- Reloads `UserImageStore` on appear.
- Shows an empty state when there are no images.
- Shows thumbnails in a list.
- Opens a detail view on tap.
- Displays document-stored images with `UIImage(contentsOfFile:)`.
- Uses `scaledToFit` in detail mode.
- Includes accessibility labels/hints for rows and detail images.

Relevant locations:

- `UserImagesView.swift:12-24`
- `UserImagesView.swift:26-51`
- `UserImagesView.swift:71-106`
- `UserImagesView.swift:108-132`
- `UserImagesView.swift:164-220`
- `UserImagesView.swift:255-265`

### Watch Navigation

File: `Views/ContentView.swift`

`UserImagesView` is part of the vertical Watch `TabView` and is available outside active dives. During an active dive, navigation is restricted to Live and Compass.

Relevant locations:

- `ContentView.swift:11-28`
- `ContentView.swift:36-48`

### Permissions and Localization

File: `iOSApp/App/Info.plist`

The iOS app includes `NSPhotoLibraryUsageDescription`, which is required for photo library access.

Relevant location:

- `Info.plist:9-10`

Localization exists for the iOS photo sender and Watch image UI in English and Italian.

Relevant locations:

- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Resources/en.lproj/Localizable.strings`
- `Resources/it.lproj/Localizable.strings`

## Issues

### Issue 1: iOS reports success before Watch receipt is proven

Severity: Medium

The iOS side sets the status to "Foto inviata al Watch" immediately after calling `WCSession.default.transferFile(...)`.

Current behavior:

- The app confirms that the file was handed to WatchConnectivity.
- It does not confirm that the Watch received the file.
- It does not confirm that the Watch decoded and stored the image.
- It does not confirm that the image is visible in `UserImagesView`.

Risk:

The user can see a success message even if the Watch is offline, transfer later fails, the file is rejected on Watch, or the image never appears in the Watch gallery.

Evidence:

- `iOSApp/Services/WatchSyncService.swift:171-174`

### Issue 2: No Watch-to-iOS photo import acknowledgement

Severity: Medium

The Watch imports the photo locally but does not send a photo-specific acknowledgement back to iOS.

Risk:

The iOS companion cannot display reliable final states such as:

- "Queued"
- "Delivered to Watch"
- "Imported on Watch"
- "Rejected by Watch"
- "Visible in Screens"

Evidence:

- Watch receive/import exists at `Services/WatchSyncService.swift:315-325`.
- No reverse acknowledgement message/userInfo is present for photo import.

### Issue 3: iOS does not track `WCSessionFileTransfer` completion

Severity: Medium

`transferFile` returns a `WCSessionFileTransfer`, but the current implementation does not keep or surface that transfer state. There is also no `session(_:didFinish:fileTransfer:error:)` handling visible in the iOS `WatchSyncService`.

Risk:

Delivery failures can be invisible to the user after the optimistic "photo sent" message.

Evidence:

- `iOSApp/Services/WatchSyncService.swift:172`

### Issue 4: Possible filename collision on rapid sends

Severity: Low

The iOS UI generates filenames using second-level timestamps:

```swift
let fileName = "companion_\(Int(Date().timeIntervalSince1970)).jpg"
```

If two photos are selected/sent within the same second, both can use the same filename. The Watch import code removes an existing file at the destination before writing the new one.

Risk:

A rapid second photo can overwrite the first photo on Watch.

Evidence:

- `iOSApp/Views/WatchPhotoTransferPanel.swift:56`
- `Services/UserImageStore.swift:83-87`

### Issue 5: UI layout requires device-size verification

Severity: Low

The Watch gallery UI is thoughtfully built, but it still needs visual QA on small and large Watch sizes. The detail screen contains:

- Header/back button/clock
- Image label
- Large image area with max height `168`
- Caption
- Page dots
- Bottom return button

Risk:

On smaller Watch sizes, the detail page may feel cramped or require more scrolling than intended. Captions and the bottom button should be verified on 41 mm, 45 mm, and 49 mm layouts.

Evidence:

- `Views/UserImagesView.swift:164-220`

### Issue 6: Page dots always show at least four dots

Severity: Low

The detail view calculates:

```swift
let count = max(imageStore.imageNames.count, 4)
```

Risk:

When there are fewer than four images, the dots imply more pages/images than actually exist.

Evidence:

- `Views/UserImagesView.swift:222-231`

### Issue 7: Test coverage is useful but incomplete

Severity: Low

Existing tests cover important Watch-side validation and file policy behavior:

- Valid JPEG accepted.
- Non-image bytes rejected.
- Filename sanitization.
- Size bounds.

Missing coverage:

- iOS preprocessor tests for large image resize/compression.
- PNG/HEIC conversion behavior.
- Duplicate filename behavior.
- Mocked end-to-end metadata key transfer.
- Watch import test that writes an image into a temporary `UserImages` directory and verifies reload/list visibility.

Evidence:

- `Tests/WatchAlgorithmTests/WatchCompanionPhotoValidatorTests.swift`
- `Tests/WatchAlgorithmTests/UserImageStorePolicyTests.swift`

## Fixing Plan

### Phase 1: Make transfer status truthful

Goal: The iOS app should distinguish "queued to WatchConnectivity" from "received/imported on Watch."

Recommended changes:

1. Store the `WCSessionFileTransfer` returned by `transferFile`.
2. Add file transfer lifecycle handling on the iOS side.
3. Replace the immediate final success message with a queued/sending message.
4. Surface transfer failures in the iOS Watch sync card.

Suggested user-facing states:

- `Queued for Watch`
- `Sending to Watch`
- `Delivered to WatchConnectivity`
- `Imported on Watch`
- `Rejected by Watch`
- `Failed`

### Phase 2: Add Watch import acknowledgement

Goal: iOS should know whether the Watch actually imported the image.

Recommended changes:

1. Add a `photoID` UUID to file metadata.
2. Include original sanitized filename in metadata.
3. After `UserImageStore.importCompanionPhoto(...)` succeeds, Watch sends a small ack payload back to iOS.
4. If Watch import fails, send a failure ack with a safe error code.
5. iOS maps the ack to the pending photo transfer and updates the visible status.

Suggested metadata:

```swift
[
    "photoID": photoID.uuidString,
    "photoFileName": sanitized
]
```

Suggested Watch ack:

```swift
[
    "type": "companionPhotoAck",
    "photoID": photoID.uuidString,
    "status": "imported",
    "storedFileName": normalizedFileName
]
```

### Phase 3: Prevent duplicate filename overwrite

Goal: Every sent photo should persist as a separate Watch image unless the user explicitly replaces it.

Recommended changes:

1. Generate iOS filenames with UUIDs rather than second-level timestamps.
2. Alternatively, make Watch storage append `-2`, `-3`, etc. when a destination exists.

Preferred fix:

Use UUID filenames from iOS:

```swift
let fileName = "companion_\(UUID().uuidString).jpg"
```

This is simple, robust, and avoids hidden overwrite behavior.

### Phase 4: Improve iOS sender UX

Goal: The user should understand availability and outcome.

Recommended changes:

1. Disable or visually de-emphasize the photo picker when:
   - WatchConnectivity is not supported.
   - Watch is not paired.
   - Watch app is not installed.
   - Session activation has not completed.
2. Show the selected transfer state under the button.
3. Use distinct wording:
   - "Queued for Watch" before delivery.
   - "Received on Watch" only after Watch ack.
4. Keep the conversion warning, but ensure it does not imply failure.

### Phase 5: Polish Watch gallery UX

Goal: The received image should be easy to find and inspect on Apple Watch.

Recommended changes:

1. Consider navigating or highlighting the newest received image when `companionPhotoDidArrive` fires.
2. Change page dots to use the actual image count instead of a minimum of four.
3. Test the detail page on 41 mm, 45 mm, and 49 mm Watch sizes.
4. Verify long captions in English and Italian.
5. Verify image aspect ratios:
   - Portrait
   - Landscape
   - Square
   - Panorama
   - Very bright/dark reference images

### Phase 6: Add focused tests

Goal: Protect the transfer and display pipeline from regressions.

Recommended tests:

1. iOS preprocessor accepts valid JPEG and outputs JPEG.
2. iOS preprocessor resizes large images.
3. iOS preprocessor converts PNG/HEIC inputs.
4. iOS sender rejects unsupported extensions.
5. Watch validator rejects corrupt bytes.
6. Watch import creates `Documents/UserImages`.
7. Watch import stores normalized `.jpg`.
8. Watch store reload includes the imported filename.
9. Duplicate filenames do not overwrite silently.
10. iOS and Watch metadata keys remain identical.

### Phase 7: Required macOS/device QA

Goal: Confirm real behavior beyond static review.

Required setup:

- macOS with Xcode and watchOS SDK.
- Generated Xcode project, if using XcodeGen.
- iPhone simulator plus Watch simulator, or physical iPhone paired with Apple Watch.
- Installed iOS companion app and Watch app with matching bundle IDs.

Commands to run on macOS:

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS' build
xcodebuild -scheme "DIRDiving Watch App" -destination 'generic/platform=watchOS' build
xcodebuild test -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 16'
xcodebuild test -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)'
```

Manual QA matrix:

1. Send a small JPEG from iOS.
2. Confirm iOS shows queued/sending state.
3. Confirm Watch receives the image.
4. Confirm Watch `SCREENS` page updates without relaunch.
5. Open the image detail view and verify full image rendering.
6. Send a PNG.
7. Send a HEIC photo.
8. Send a large image/panorama.
9. Send two images rapidly and verify both remain present.
10. Turn off Watch connectivity, send a photo, reconnect, and verify eventual delivery or failure state.
11. Test Watch sizes: 41 mm, 45 mm, 49 mm.
12. Test both English and Italian text.

## Release Recommendation

Static review supports that the core image transfer implementation is directionally correct and likely functional. The feature should not be described as fully verified until device/simulator QA confirms actual receipt and display on Watch.

Before release, the highest-value fixes are:

1. Add Watch import acknowledgement.
2. Track file transfer completion/failure.
3. Replace timestamp filenames with UUID filenames.
4. Run visual QA on real/simulated Watch sizes.

These changes would close the gap between "the photo was queued" and "the photo is visible on Apple Watch," which is the key product expectation for this feature.
