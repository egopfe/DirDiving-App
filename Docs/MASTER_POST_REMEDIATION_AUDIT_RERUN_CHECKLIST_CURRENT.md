# Post-Remediation Audit Rerun Checklist

**Date:** 2026-06-23  
**Software remediation:** complete on `main` (see `MASTER_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md`)

| Audit command | Rerun status | Notes |
|---------------|--------------|-------|
| 01 Watch FC forensic | **Recommended** | Verify CONS-001 oracle independence in traceability |
| 02 iOS comprehensive | **Recommended** | Verify CONS-008 restoration |
| 03 UI/UX | Optional | No UI layout changes in remediation |
| 04 Main code/sync/security/perf | **Recommended** | WatchSync test hook + perf test |
| 05 Release QA | **Recommended** | Full XCTest matrix + IntegratedModes included |
| 06 Documentation | **Recommended** | P0 doc fixes |
| 00 Orchestrator consolidation | After 01–06 | Refresh consolidated % |

Execute read-only; no production changes unless new findings emerge.
