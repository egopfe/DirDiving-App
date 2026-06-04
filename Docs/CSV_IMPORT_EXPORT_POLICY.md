# CSV import / export policy

## Required columns (import)

- `time_seconds`
- `depth_m`

## Optional columns

- `temperature_c` — when absent, samples import with `temperatureCelsius = nil`; session temperature stats remain unavailable (not zero).
- GPS columns (`entry_lat`, `entry_lon`, `exit_lat`, `exit_lon`) remain optional as before.

## Export

Export continues to include `temperature_c` when sample data exists. Export behavior is unchanged by the optional-import remediation.

## Validation

- Malformed `temperature_c` values reject the affected row (same as before).
- Missing `depth_m` or `time_seconds` still fails import (`emptyProfile` / missing header row).

## Tests

See `Tests/iOSAlgorithmTests/AuditRemediationTests.swift`, `IOSMainAlgorithmAuditRemediationTests.swift`, and `CSVMetadataRoundTripTests.swift`.
