# DIR Diving iOS Apnea — Full Deep Audit — CURRENT

**Audit command:** `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.5` (Apnea first-class scope)  
**Audit date:** 2026-07-01  
**Repository:** `egopfe/DirDiving-App`  
**Branch:** `main` @ `2c30412`  
**Apnea P1/P2/P3 baseline:** Watch @ `76f3703` (iOS companion cross-read)  
**Execution mode:** Read-only static analysis + iOS Algorithm Tests evidence

---

## A. Executive Summary

Apnea is a **first-class product area** on iOS Companion with strict isolation from Diving decompression math. The iOS role is **companion**: session planning, profiles, training tables, settings, logbook, equipment/buddy, export, and signed Watch plan transfer. **Live session execution, automatic wet detection, depth/time profile recording, recovery countdown, and training compound P1/P2/P3 runtime** are **Watch-authoritative** (@ `76f3703`).

**Verdict:** **PASS** for iOS Apnea companion software scope. **PARTIAL** for end-to-end product readiness due to physical wet QA and Apnea cloud stub.

| Check | Verdict |
|---|---|
| No decompression/GF/gas/MOD in Apnea iOS UI | **PASS** |
| Settings owned by Apnea; no cross-activity leakage | **PASS** |
| Logbook owned by Apnea; 6/6 forbidden routes blocked | **PASS** |
| Sync schema isolated (`dirdiving_apnea_*`) | **PASS** |
| No medical guarantee for recovery | **PASS** — copy audited |
| Apnea iOS tests | **PASS** — `IOSApneaCompanionTests`, `ApneaReleaseHardValidationTests`, sync codec suites |
| Physical wet auto-detection QA | **PENDING_PHYSICAL** |
| Apnea iCloud backup | **STUB** — IOS-P3-002 documented |

---

## B. iOS Apnea Companion Scope (explicit)

### In scope on iOS Companion

| Area | Primary files | Reachable UI |
|---|---|---|
| Root / dashboard | `IOSApneaRootView`, `IOSApneaDashboardView` | Activity selection → Apnea |
| Tabs | dashboard, sessions, statistics, profiles | Tab bar |
| Session planner | `IOSApneaSessionPlannerView`, `IOSApneaPlannerStore` | Dashboard → planner |
| Profiles | `IOSApneaProfileStore`, `IOSApneaProfilesView` | Profiles tab |
| Training tables | `IOSApneaTrainingTablesView` | Profiles / planner |
| Settings | `IOSApneaSettingsContent`, `IOSApneaSettingsForm` | Gear icon → Settings Apnea mode |
| Logbook | `IOSApneaLogbookStore`, `IOSApneaSessionsListView` | Sessions tab |
| Statistics | Apnea analytics views | Statistics tab |
| Equipment / buddy | `IOSApneaEquipmentView`, `IOSApneaBuddySafetyView` | Dashboard / settings links |
| Checklist | `IOSApneaChecklistView` | Apnea checklist |
| Export | `IOSApneaSessionExportService`, `IOSApneaSessionExportView` | Session detail export |
| Watch transfer | `IOSApneaWatchTransferService`, `ApneaSyncCodec` | Planner → transfer |
| Fake demo logbook | `IOSActivityDemoLogbookSettingsStore` | Apnea Settings; default OFF |

### Out of scope on iOS (Watch @76f3703)

| Area | Authority | Notes |
|---|---|---|
| Live apnea session / dive lifecycle | Watch | iOS imports completed sessions |
| Automatic session detection | Watch | Not physically validated |
| Depth/time profile sampling | Watch | iOS displays imported profile |
| Descent/ascent metrics live | Watch | Analytics on imported data |
| Surface interval / recovery countdown live | Watch | Settings sync; no medical claim |
| Targets / alarms / markers at runtime | Watch | iOS configures defaults |
| Water auto-open → Apnea session | Watch routing | **Does not auto-start session** |
| Action Button / Digital Crown underwater | Watch | iOS read-only cross-target |
| Apnea training P1/P2/P3 compound steps | Watch `ApneaSessionEngine` | Isolation tests PASS on Watch |

---

## C. Mandatory truthfulness checks

| Requirement | Result | Evidence |
|---|---|---|
| No decompression wording in Apnea iOS | **PASS** | Grep Apnea views — no GF/MOD/PPO2/deco settings |
| No GF/gas/MOD/PPO2/deco settings in Apnea | **PASS** | `IOSActivitySettingsRoutingTests` |
| No medical guarantee for recovery | **PASS** | Localization + `ApneaReleaseHardValidationTests` |
| No claim Apnea auto-detection physically validated | **PASS** | Marked PENDING_PHYSICAL |
| No claim water auto-open starts Apnea session | **PASS** | Watch policy; audit 01 boundary |
| No cross-activity logbook/settings leakage | **PASS** | `IOSActivityLogbookRoutingTests` |

---

## D. Settings ownership

See `Docs/MASTER_IOS_APNEA_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv`. Apnea settings include: session detection defaults, recovery minimum, targets, depth/time/speed alarms, markers, buddy/equipment, profiles, fake logbook toggle. **Absent from Diving and Snorkeling settings scopes.**

Gear button on Apnea dashboard opens `IOSCompanionSettingsRootView` with **Apnea** pre-selected (`IOSActivitySettingsRoutingTests`).

---

## E. Logbook ownership

See `Docs/MASTER_IOS_APNEA_LOGBOOK_OWNERSHIP_MATRIX_CURRENT.csv`. Persistence: `dirdiving_ios_apnea_sessions.json`. No `DiveLogStore` in Apnea environment. Demo sessions isolated when fake logbook enabled.

---

## F. Sync / schema isolation

See `Docs/MASTER_IOS_APNEA_SYNC_SCHEMA_MATRIX_CURRENT.csv`.

- Envelope: `dirdiving_apnea_session`
- Tombstones: `dirdiving_deleted_apnea_session_tombstones`
- Plan transfer: `ApneaSyncCodec` with HMAC, schema version, checksum
- Cross-decode rejection: `ActivitySyncCrossDecodeRejectionTests`, `ApneaSyncCodecNegativePathTests`

---

## G. Test evidence @2c30412

| Suite | Result |
|---|---|
| `IOSApneaCompanionTests` | PASS |
| `IOSApneaLogbookAnalyticsTests` | PASS |
| `IOSApneaMapEquipmentExportTests` | PASS |
| `ApneaReleaseHardValidationTests` | PASS |
| `ApneaSyncCodecTests` / negative paths | PASS |
| `ApneaCloudBackupStubTruthfulnessTests` | PASS (stub disclosed) |
| `ApneaDemoLogbookPresentationTests` | PASS |

---

## H. Findings (Apnea-specific)

| ID | Severity | Summary | Status |
|---|---|---|---|
| IOS-P3-002 | P3 | Apnea iCloud backup stubbed | OPEN — documented |
| IOS-P2-007 | P2 | Watch WAO routing drift after Apnea P1/P2/P3 | OPEN — Watch-side; iOS unaffected |
| — | — | No Apnea-specific P0/P1 software defect | — |

---

## I. Final Apnea verdict

```text
IOS_APNEA_COMPANION_AUDIT: PASS
IOS_APNEA_SETTINGS_OWNERSHIP: PASS
IOS_APNEA_LOGBOOK_OWNERSHIP: PASS
IOS_APNEA_NO_DIVING_MATH_LEAKAGE: PASS
IOS_APNEA_SYNC_ISOLATION: PASS
IOS_APNEA_WATCH_SCOPE_BOUNDARY: PASS
IOS_APNEA_PHYSICAL_QA: PENDING_PHYSICAL
IOS_APNEA_CLOUD_BACKUP: STUB (IOS-P3-002)
```

---

*End of iOS Apnea audit — V1.5 @ `2c30412`.*
