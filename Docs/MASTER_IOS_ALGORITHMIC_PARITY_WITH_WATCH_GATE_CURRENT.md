# iOS Algorithmic Parity with Watch Full Computer Gate — CURRENT

**Audit command:** `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.5`  
**Baseline:** `main` @ `2c30412`  
**Upstream audit:** `01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V1.5` @ `2c30412`  
**Audit date:** 2026-07-01

---

## Gate policy (V1.5)

Per orchestrator priority rule: **Audit 01 Watch Full Computer Forensic = highest-risk blocking audit**. iOS audit 02 **must not contradict or weaken** audit 01 conclusions. iOS cannot claim higher decompression safety readiness than Watch FC when upstream gates are open.

---

## Shared mathematical core

| Component | iOS role | Watch FC role | Parity status |
|---|---|---|---|
| `Shared/BuhlmannCore/BuhlmannEngine.swift` | Planner reference | Live runtime | **SHARED CANONICAL** |
| `BuhlmannConstants` ZH-L16C | Planner + tests | Live tissue model | **PASS** — same constants |
| `FullComputerGradientFactorPreset` | Package export | Live GF lock | **PASS** — CONS-002 |
| `DivePlanPackageBuilder` | Sealed plan → Watch | Import at predive | **PASS** — all presets emit `gradientFactorPreset` |
| Schreiner / multilevel | Planner simulation | Live integration | **UNDERSTOOD SEPARATION** — iOS does not execute live 1 Hz integration |

---

## iOS-specific vs Watch-authoritative

| Domain | iOS authority | Watch authority | Gate |
|---|---|---|---|
| Live NDL/TTS/Ceiling during dive | **No** — reference planner only | **Yes** — Full Computer runtime | iOS must label reference-only |
| GF at predive | Package suggestion | User preset + plan override lock | **PASS** software |
| Briefing card PNG | Generate + transfer | Display reference-only | **PASS** software; paired QA pending |
| Apnea live session | Companion logbook/settings/export | Watch runtime @76f3703 | **PASS** isolation |
| Snorkeling GPS route | Route planner P1/P2/P3 | Watch runtime evaluator P3 | **PASS** software; field QA pending |
| Water auto-open routing | Read-only cross-target | Watch policy | **PARTIAL** — WFC-P2-005 13 test failures |

---

## Upstream audit 01 blockers affecting iOS release posture

| ID | Severity | iOS impact | Status @2c30412 |
|---|---|---|---|
| WFC-P1-001 | P1 | Cannot claim external Bühlmann validation for planner or FC | **PENDING_EXTERNAL_VALIDATION** |
| WFC-P2-005 | P2 | Watch routing test drift after Apnea P1/P2/P3; iOS cross-read only | **OPEN** — 13 Watch test failures; **0 FC math failures** |

---

## CONS post-remediation gates (iOS-affecting)

| Gate | Verdict @2c30412 | Evidence |
|---|---|---|
| IOS_GF_PRESET_PARITY (CONS-002) | **PASS** | `PlannerGFPresetDisplayTests`; `DivePlanPackageBuilderTests` |
| IOS_INFLIGHT_ACK_CLEANUP (CONS-003) | **PASS** | `MainDeepCodeAuditRemediationTests` |
| IOS_DIVE_IMPORT_ACK_SYMMETRY (CONS-004) | **PASS** | `ActivitySyncSignedAckSymmetryTests` |
| IOS_TOMBSTONE_SECURITY (CONS-005) | **PASS** | `ActivitySyncTombstoneTests` |
| CONS-046 command integrity V1.5 | **PASS** | `validate_commands_for_cursor_integrity.sh` EXIT 0 |

---

## Overall gate verdict

```text
IOS_ALGORITHMIC_PARITY_WITH_WATCH_GATE: PARTIAL
SHARED_BUHLMANN_CORE: PASS
GF_PRESET_CROSS_PLATFORM: PASS
PLANNER_REFERENCE_ONLY_TRUTHFULNESS: PASS
LIVE_FC_AUTHORITY_ON_WATCH: PASS (iOS does not claim live FC)
EXTERNAL_BUHLMANN_VALIDATION: PENDING (WFC-P1-001)
WATCH_ROUTING_TEST_GREEN: FAIL (WFC-P2-005 — non-FC)
IOS_CONTRADICTS_AUDIT_01: NO
```

**Interpretation:** iOS companion software is **aligned** with Watch FC math via shared BuhlmannCore and verified GF/sync remediations. Consolidated release readiness remains **PARTIAL** because upstream external Bühlmann validation and physical/paired QA gates are open — not because iOS introduces independent P0 math defects.

---

*End of algorithmic parity gate — V1.5 @ `2c30412`.*
