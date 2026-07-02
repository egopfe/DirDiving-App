# Snorkeling Photo Marker Policy

**Scope:** iOS Snorkeling marker logbook presentation.

## Supported

- `SnorkelingMarker.photoReferenceID` UUID on marker model
- `SnorkelingSessionPhotoAttachment` linked by `markerID`
- iOS logbook thumbnail via `IOSSnorkelingSessionPhotoStore` when file exists
- Session JSON encoding of photo reference UUIDs (no binary blobs in session JSON)

## Not in P3 scope

- Watch camera capture
- New photo import pipeline
- Large binary data in sync payloads

## Unavailable state

When no attachment exists, omit thumbnail; do not fabricate images.
