# Diving Export Privacy Policy (Current)

**Command:** 10 remediation  
**Date:** 2026-06-20  
**Finding:** SEC-P2-002 — **FIXED**

---

## Policy owner

`Shared/Utils/DivingExportPrivacyPolicy.swift`

---

## Location precision modes

| Mode | CSV lat/lon | User acknowledgment |
|------|-------------|---------------------|
| `omitted` (default) | Empty strings | Not required |
| `approximate` | 3 decimal places (~100 m) | Required |
| `precise` | 6 decimal places | Required |

Default options: `DivingExportPrivacyOptions.default` → omitted GPS, no acknowledgment.

---

## Preferences

| Key | Purpose |
|-----|---------|
| `dirdiving_diving_export_location_precision_v1` | Persisted precision mode |
| `dirdiving_diving_export_privacy_migration_v1` | Migration version |
| `dirdiving_diving_export_had_prior_exports` | Legacy users who exported before policy keep precise if unset |

---

## Export integration

`SubsurfaceExportService` (Watch + iOS):

- Applies `exportCoordinateStrings` for entry/exit GPS
- Embeds metadata line `dirdiving_export_location_precision: <mode>`
- Tags simulated sessions: `dirdiving_depth_sensor_source: simulation`

---

## Parity

Matches Apnea/Snorkeling export redaction philosophy: **default share sheet does not expose exact dive site coordinates** unless user explicitly opts in.

---

## Validation

| Test | Matrix ID |
|------|-----------|
| `testDivingExportOmitsGPSByDefault` | SEC-NEG-13 |
| `testDivingExportApproximateGPSReducesPrecision` | REQ-SEC-REM-02 |
| `testWatchSubsurfaceExportOmitsGPSByDefault` | REQ-SEC-REM-03 |
