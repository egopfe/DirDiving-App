# Subsurface CSV External Round-Trip — Evidence Folder

**Status: PENDING** — Do not mark PASS without attached files.

**Procedure:** [`Docs/SUBSURFACE_CSV_ROUNDTRIP.md`](../../SUBSURFACE_CSV_ROUNDTRIP.md)  
**Watch/iOS note:** Watch CSV omits `# dirdiving_ccr_*` by design — see [`Docs/WATCH_CSV_EXPORT_POLICY.md`](../../WATCH_CSV_EXPORT_POLICY.md)

---

## Required artifacts

| Field | Value |
|---|---|
| Subsurface desktop version | |
| OS version | |
| DIR Diving iOS build / commit | |
| Exported sample CSV files | attach OC + CCR manual samples |
| Import steps executed | numbered list |
| Expected imported fields | table |
| Known limitations | |
| CCR metadata keys present (iOS only) | list |
| Screenshots | import result |
| Reviewer / date | |
| Pass/Fail | **PENDING** |

## Policy reminders

- Metric `depth_m` export policy on iOS
- `time_seconds` monotonic from first sample
- CCR metadata only when `ccrLogbookMetadata` exists — not fabricated for OC dives
- No certified / life-support claims in CSV comments

**Desktop Subsurface round-trip is not passed until evidence is attached.**
