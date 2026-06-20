# Apnea Cloud Capability — CURRENT

**Policy:** `EXPLICITLY_UNAVAILABLE` (local-only on iOS Companion)

## Summary

Apnea sessions on iOS Companion remain **device-local**. There is no upload queue, no iCloud namespace, and no cross-activity cloud merge for Apnea data.

## Implementation

| Component | Behavior |
|---|---|
| `ApneaCloudCapability.current` | `.notAvailable(reason: .localOnlyPolicy)` |
| `IOSApneaSessionExportView` | Shows status + note; no toggle |
| `ApneaCloudBackupPreference` | Legacy key cleared on launch via `reconcileWithCapability()` |
| `IOSApneaLogbookStore` | No `CloudSyncStore` reference |

## UX copy (EN)

- Status: "Not available"
- Note: Apnea cloud backup is not available on iOS Companion; sessions remain stored locally.

## Tests

- `ApneaCloudBackupStubTruthfulnessTests` — capability state, no upload path, localization

## External gates still pending

- iCloud two-device Apnea QA (if product adds cloud later)
- Physical Apnea field QA
