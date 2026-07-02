# Master Main Code - Apnea Sync/Security/Performance Audit (CURRENT)

**Baseline:** `main` @ `7ae527b`  
**Mode:** read-only code audit, Docs-only outputs

## Executive verdict

Apnea remains a first-class, activity-isolated area with independent store/sync namespaces and no decompression authority leakage. Software verdict is `PASS` for isolation and privacy posture; final status remains `PARTIAL` because physical wet/paired/instruments evidence is pending.

## Core checks

- No GF/gas/deco authority surfaced through Apnea settings or runtime policy
- Apnea sync envelope and keys remain independent from Diving/Snorkeling
- Apnea checkpoint and session persistence paths remain activity-owned
- Water auto-open policy remains routing-only (no forced live-session start claim)

## Pending gates

- `PENDING_PHYSICAL`: wet/auto-detection field evidence
- `PENDING_INSTRUMENTS`: battery/runtime profiling in physical contexts

## Finding references

- `MAIN-APNEA-001` (P2 pending physical)

## Verdict block

```text
MAIN_APNEA_CODE_SYNC_SECURITY_PERFORMANCE: PASS (software)
APNEA_ACTIVITY_ISOLATION: PASS
APNEA_SYNC_SCHEMA_ISOLATION: PASS
APNEA_SETTINGS_LOGBOOK_OWNERSHIP: PASS
APNEA_PRIVACY_TRUTHFULNESS: PASS
APNEA_PHYSICAL_WET_QA: PENDING_PHYSICAL
P0_FINDINGS: 0
P1_FINDINGS: 0
P2_FINDINGS: 1
P3_FINDINGS: 0
```
