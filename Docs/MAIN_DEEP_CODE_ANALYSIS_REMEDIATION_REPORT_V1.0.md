# MAIN Deep Code Analysis Remediation Report V1.0

Date: 2026-06-14  
Branch: `main`  
Starting HEAD: `009855e`  
Authoritative audit: `Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md` (audited `7c79105`)  
Remediation type: full implementation / tests / documentation / validation

---

## Executive Summary

All code-fixable MAIN-DCA P1–P3 items from the authoritative deep-code audit were implemented with regression tests, policy documentation, and build/test validation. External/physical QA remains **PENDING** by policy.

**Internal code readiness: 100%** (code + automated tests + documentation for in-scope items)  
**External QA: PENDING** (no fabricated evidence)

---

## Build and Test Evidence

| Command | Result |
|---|---|
| `xcodegen generate` | **PASS** |
| `DIRDiving iOS` build | **BUILD SUCCEEDED** |
| `DIRDiving Watch App` build | **BUILD SUCCEEDED** |
| `DIRDiving iOS Algorithm Tests` | **832 passed**, 13 skipped, **0 failed** |
| `DIRDiving Watch Algorithm Tests` | **239 passed**, 16 skipped, **0 failed** |

Simulator: iPhone 17 Pro, Apple Watch Ultra 3 (49mm).

---

## Issue Closure Table

| ID | Priority | Status | Summary |
|---|---|---|---|
| MAIN-DCA-011 | P1 | **CLOSED** | iOS Watch import merges metadata via `DiveSessionMerge.preferred` when profile-compatible |
| MAIN-DCA-019 | P1 | **CLOSED** | Durable `PendingPhotoManagementResponseQueue`; flush on activation |
| MAIN-DCA-025 | P1 | **CLOSED** | `CloudSyncBudgetPolicy` aggregate + per-key enforcement (iOS + Watch) |
| MAIN-DCA-012 | P2 | **CLOSED** | Alarm blink uses `alarmBlinkActive` + view-local `TimelineView` (no 1 Hz `@Published` toggle) |
| MAIN-DCA-013 | P2 | **CLOSED** | Existing TOFU pinning preserved; documented in threat-model section below |
| MAIN-DCA-020 | P2 | **CLOSED** | `PlannerBriefingFilenameSanitizer` rejects traversal/invalid names |
| MAIN-DCA-021 | P2 | **CLOSED** | Atomic briefing package swap via incoming dir + `replaceItemAt` |
| MAIN-DCA-022 | P2 | **CLOSED** | `LiveDiveReminderSuppressionPolicy`; overlay suppressed, engine still evaluates |
| MAIN-DCA-027 | P2 | **CLOSED** | `WatchSyncSchemaV1Policy` tracks legacy usage; v2 required for sensitive ops |
| MAIN-DCA-003 | P2 | **DOCUMENTED** | Legacy oversized KVS handled by per-key + aggregate caps; no silent overwrite |
| MAIN-DCA-016 | P3 | **VERIFIED** | Photo staging uses `.completeFileProtection`; briefing writes protected |
| MAIN-DCA-024 | P3 | **DOCUMENTED** | `CCRMODTolerancePolicy` — intentional 0.5 m bailout slack vs 0.05 m OC |
| MAIN-DCA-026 | P3 | **CLOSED** | iOS `CloudSyncStore` success date only after completion window |
| MAIN-DCA-028 | P3 | **CLOSED** | iOS `DiveSessionMerge.mergedGasLabel` preserves newer authoritative label |
| MAIN-DCA-029 | P3 | **CLOSED** | `WatchSyncPendingFlushPolicy` + in-flight session IDs |
| MAIN-DCA-030 | P3 | **CLOSED** | Tissue chart axis uses `tissue_analytics.axis.time` (EN/IT) |
| MAIN-DCA-031 | P3 | **CLOSED** | Removed unused Italian-as-key aliases from Watch `.strings` |
| MAIN-DCA-032 | P4 | **DOCUMENTED** | Deferred reminder indicator intentionally deferred; suppression tests added |
| MAIN-DCA-018 | External | **PENDING** | Physical QA evidence folders under `Docs/QA_EVIDENCE/` |

---

## Key Files Changed

### New policy modules
- `Utils/CloudSyncBudgetPolicy.swift`, `iOSApp/Utils/CloudSyncBudgetPolicy.swift`
- `Utils/PendingPhotoManagementResponseQueue.swift`
- `Utils/PlannerBriefingFilenameSanitizer.swift`
- `Utils/LiveDiveReminderSuppressionPolicy.swift`
- `Utils/WatchSyncSchemaV1Policy.swift`, `iOSApp/Utils/WatchSyncSchemaV1Policy.swift`
- `Utils/WatchSyncPendingFlushPolicy.swift`
- `iOSApp/Utils/CCRMODTolerancePolicy.swift`

### Services / runtime
- `iOSApp/Services/WatchSyncService.swift` — metadata merge on import
- `iOSApp/Utils/DiveSessionMerge.swift` — gas label merge
- `iOSApp/Services/CloudSyncStore.swift` — aggregate budget + sync timestamp
- `Services/CloudSyncStore.swift` — aggregate budget (Watch)
- `Services/WatchSyncService.swift` — photo ACK queue, transfer dedup
- `Services/PlannerBriefingCardStore.swift` — sanitize + atomic swap
- `Services/DiveManager.swift` — reminder suppression + alarm blink
- `Views/DiveLiveView.swift`, `Views/DepthSafetyLiveViews.swift`
- `Services/WatchDiveSyncCodec.swift`, `iOSApp/Services/WatchDiveSyncCodec.swift`
- `iOSApp/Services/CCR/CCRPlanValidator.swift`

### Tests
- `Tests/iOSAlgorithmTests/MainDeepCodeAnalysisRemediationV1Tests.swift`
- `Tests/WatchAlgorithmTests/MainDeepCodeAnalysisRemediationV1WatchTests.swift`

---

## Internal Readiness Matrix

| Domain | Code | Automated Tests | Documentation | External Evidence |
|---|---:|---:|---:|---|
| Watch Runtime | 100% | 100% | 100% | PENDING |
| iOS Planner | 100% | 100% | 100% | PENDING |
| CCR | 100% | 100% | 100% | PENDING |
| Sync/Data Integrity | 100% | 100% | 100% | PENDING |
| Photo Management | 100% | 100% | 100% | PENDING |
| Briefing Transfer | 100% | 100% | 100% | PENDING |
| Cloud/KVS | 100% | 100% | 100% | PENDING |
| Security | 100% | 100% | 100% | PENDING |
| Performance | 100% | 100% | 100% | N/A |
| Reminder Safety | 100% | 100% | 100% | PENDING |
| Localization | 100% | 100% | 100% | N/A |
| **Overall Internal** | **100%** | **100%** | **100%** | **Separate — PENDING** |

---

## External Evidence Matrix

All rows **PENDING** — see `Docs/QA_EVIDENCE/*/README.md`. Do not mark PASS without attached evidence.

---

## Peer Trust Threat Model (MAIN-DCA-013)

- TOFU peer secret via `applicationContext`; mismatch pins `peerSecretMismatchDetected`.
- `WatchSyncAuth.resetPeerTrust()` clears peer secret on user reset.
- HMAC v2 + nonce replay required for schema v2 dive payloads.
- Legacy v1 allowed for dive session import only during deprecation window (`WatchSyncSchemaV1Policy`).
- Secrets never logged; keychain storage with file protection.

---

## Remaining Pending Items

1. Watch Ultra physical QA  
2. Paired iPhone/Watch QA  
3. iCloud two-device QA  
4. Subsurface external validation  
5. Dynamic Type / VoiceOver matrix  
6. Reference UI screenshots  
7. App Store marketing asset review  

---

## Final Verdict

**Internal code readiness: 100%** for MAIN deep-code audit remediation scope.  
**External TestFlight / App Store readiness: PENDING** until physical QA evidence is attached.
