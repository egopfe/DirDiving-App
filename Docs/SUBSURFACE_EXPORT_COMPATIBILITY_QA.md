# Subsurface export compatibility QA

**Status:** Internal regression tests pass; **external Subsurface import not executed** in CI or this remediation pass.

## Internal coverage

Automated tests in:

- `Tests/iOSAlgorithmTests/IOSMainAlgorithmAuditRemediationTests.swift`
- `Tests/iOSAlgorithmTests/IOSAlgorithmTests.swift`
- `Tests/iOSAlgorithmTests/CSVMetadataRoundTripTests.swift`

Verify:

- Non-empty profile export produces CSV with headers and monotonic `time_seconds`
- Empty profile rejected
- Manual session metadata headers (`dirdiving_*`, `session_meta`)
- Nil temperature columns export as empty fields (not `0`)
- GPS and pressure metadata round-trip where present

## Manual external validation (required before App Store claim)

1. Build **DIRDiving iOS** from `main`.
2. Export a **Watch-synced** dive with depth profile via dive detail → Generate Subsurface CSV.
3. Export a **manual** dive with synthetic profile if available.
4. Import both files into **Subsurface** (desktop) current stable release.
5. Confirm:
   - Profile renders with correct depth/time scale
   - Temperature gaps do not show as zero unless sample was zero
   - Metadata notes preserved in headers or session fields
   - No parser errors on quoted metadata (commas, quotes)

## Failure recording

If import fails, record: Subsurface version, macOS version, CSV snippet (redact GPS if needed), and DIR DIVING app build number.

Do **not** mark App Store readiness complete until this matrix is signed off.
