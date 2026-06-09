# CSV / Subsurface External Validation — Evidence Folder

**Status: PENDING** — Do not mark PASS without attached files.

**Matrix:** [`Docs/CSV_SUBSURFACE_QA_MATRIX.md`](../../CSV_SUBSURFACE_QA_MATRIX.md)  
**Procedure:** [`Docs/SUBSURFACE_CSV_ROUNDTRIP.md`](../../SUBSURFACE_CSV_ROUNDTRIP.md)  
**Watch export policy:** [`Docs/WATCH_CSV_EXPORT_POLICY.md`](../../WATCH_CSV_EXPORT_POLICY.md)

---

## Scope

Desktop Subsurface round-trip validation of DIR DIVING CSV export/import. Covers OC and CCR manual samples, metadata preservation, malformed-file handling, and known platform limitations (Watch omits `# dirdiving_ccr_*` by design).

---

## Required device / simulator matrix

| Component | Requirement |
|-----------|-------------|
| DIR DIVING iOS | Physical device or simulator — build under test |
| Subsurface desktop | Version recorded; macOS or Linux per team standard |
| Apple Watch (optional) | Watch CSV export policy verification only |

---

## Required evidence files

- [ ] Exported sample CSV files (OC + CCR manual dives)
- [ ] Subsurface import screenshots / result tables
- [ ] App re-import round-trip notes
- [ ] Metadata field checklist (CCR keys on iOS only when applicable)
- [ ] Edge-case logs (malformed / oversized file) if tested

---

## Sign-off

| Field | Value |
|-------|-------|
| Subsurface desktop version | |
| OS version | |
| DIR Diving build / commit SHA | |
| Samples exported | OC / CCR |
| Known limitations documented | |
| Tester / reviewer | |
| Date | |
| Pass/Fail | **PENDING** |

**Desktop Subsurface round-trip is not passed until evidence is attached here.**
