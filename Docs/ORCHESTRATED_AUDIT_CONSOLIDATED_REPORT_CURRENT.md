# Orchestrated Audit Consolidated Report — Current

**Date:** 2026-06-21  
**Branch / commit:** `main` @ `6cbba64948acfed1dccaf586adaeae58408d3fc9`  
**Remote freshness:** local equals `origin/main`, ahead/behind `0/0`  
**Initial state:** clean  
**Commands:** 28 Markdown/Text files discovered; 19 audits executed; 7 superseded V2 commands and 2 metadata files skipped

## 1. Executive summary

The repository was audited at the newest `origin/main`. The current software contains broad, well-structured coverage for multi-activity ownership, Watch live Bühlmann, iOS planning, sync/security, localization, tests, mockups, and release policies. Previous remediation evidence closes many historical defects.

This orchestration found one current P0 root cause not covered by the prior runs: **the iOS Full Computer plan transports altitude and salinity, but Watch activation drops the environment and live runtime silently defaults to sea-level salt water.** The shared Bühlmann math is environment-aware; product integration is not. This can make live ceiling, NDL, TTS, stops, PPO2/MOD, and surfacing criteria inconsistent with the accepted plan.

The P0 also creates a UI truthfulness failure: Watch predive confirmation does not show or reject the environment mismatch. Altitude is absent from completed-dive metadata. Independent Watch altitude profiles do not exist.

Current active deduplicated findings: **15 total — P0 1, P1 7, P2 7, P3 0, P4 0.**

| Gate | Verdict |
|---|---|
| Overall internal readiness | **NO-GO** |
| Internal code readiness | **NO-GO** — P0 live altitude integration |
| Internal test readiness | **NO-GO** — no independent Watch altitude suite/current macOS rerun |
| TestFlight readiness | **NO-GO** |
| App Store readiness | **NO-GO** |
| Physical QA | **PENDING** |
| External validation/legal | **PENDING** |

## 2. Audit coverage

| Area | Coverage/result |
|---|---|
| Diving → Gauge | Software behavior/test contracts present; physical underwater QA pending |
| Diving → Full Computer | Audit 15 software evidence strong at sea level; altitude integration P0 |
| iOS Planner | Base/Deco/Technical/CCR and environment-aware shared math implemented; reference-only |
| Apple Watch runtime | Actual-dt, multilevel, deco/stop/gas/recovery evidence present; current build and altitude profiles missing |
| Bühlmann / Schreiner / altitude / multilevel | Core/multilevel covered; end-to-end altitude FAIL |
| CCR / Rebreather | Reference-only flows covered; external validation pending |
| Apnea | Dedicated lifecycle/settings/logbook/sync; physical underwater/recovery QA pending |
| Snorkeling | Dedicated lifecycle/GPS/navigation/logbook/sync; field GPS/privacy QA pending |
| Settings | Activity isolation verified |
| Logbooks | Strict ownership verified; Full Computer environment metadata missing |
| Sync | Namespaces, schema, HMAC/ACK/replay policies present; paired-device QA pending |
| Persistence | Checkpoints/stores/migrations reviewed; imported altitude lost before checkpoint |
| Security/privacy | Software gates and manifests present; paired/field review pending |
| Performance/concurrency/battery | Budgets/signposts present; physical profiling pending |
| Localization/accessibility | EN/IT key parity; physical accessibility and portable scanners pending |
| QA evidence | Extensive historical tests; current commit/macOS and external/physical gaps remain |
| Release/legal claims | Non-certified/reference-only posture present; counsel/App Store review pending |
| Mockups/visual regression | 60 assets inventoried; manual/device pixel evidence pending |
| Complete UI/UX coherence | FAIL due altitude truthfulness plus evidence gaps |

## 3. Most critical findings

### P0 — Watch Full Computer discards imported altitude environment

- **Evidence:** `DivePlanPackageBuilder` writes altitude/salinity; `FullComputerGasProfile.init(importing:)` drops them; `FullComputerImportedPlanStore.activatePendingPlan` imports only the gas profile; `FullComputerPrediveConfigurationStore.runtimePlan()` calls a constructor defaulting to `.seaLevelSaltWater`.
- **Affected:** iOS→Watch plan transfer, Watch predive, live tissues, ceiling/NDL/TTS/schedule, checkpoint provenance, logbook, UI truthfulness.
- **Why it matters:** an accepted altitude plan can run with a different atmospheric pressure and present unsafe or misleading decompression output.
- **Fix:** require a validated frozen environment from exactly one confirmed source: imported iPhone plan, manual Watch Full Computer Settings, or a Watch sensor-measured startup proposal at detected elevation. Never overwrite sources silently; provide no explicit or implicit sea-level option; block missing/invalid/incompatible input; expose and persist the selected source everywhere.
- **Tests:** independent all-16-compartment profiles at required altitudes/water/gases; import, gas switch, restore, clear/re-descent, logbook/sync/export.

### P1 — Independent Watch altitude test/oracle coverage missing

The Watch oracle reuses production pressure conversion. Build a genuinely independent pressure/environment oracle and run the full altitude matrix.

### P1 — Full Computer logbook loses environment provenance

The checkpoint contains the plan, but completed metadata omits altitude, pressure, salinity, density, source, and fallback confidence. Add versioned fields and round-trip tests.

### P1 — External Bühlmann/CCR validation pending

Repository tests cannot substitute for independent reference/certification evidence. Do not strengthen claims until documented comparisons pass.

### P1 — Physical Watch underwater/entitlement validation pending

Depth entitlement, Water Lock, wet/glove interactions, sensor degradation/recovery, and combined critical states are unproven on hardware.

### P1 — Paired Watch/iPhone sync/trust QA pending

Software tests cover signed envelopes, ACK/replay, namespaces, conflicts, and tombstones; two-device behavior and load remain unverified.

### P1 — External legal/App Store review pending

Claims policy is conservative, but counsel/certification/store metadata review has no completed evidence.

### P1 — Current commit lacks Apple build/test evidence

Windows cannot run Xcode/XCTest. All app builds, full schemes, focused altitude/Audit 15 tests, and readiness scripts must pass on macOS at the remediation commit.

## 4. Cross-audit themes

- **Safety-critical algorithm correctness:** mature shared core, but environment provenance must be treated as safety state rather than optional presentation data.
- **Decompression/Bühlmann/Schreiner:** Audit 15 improves timing/multilevel behavior; altitude demonstrates that correct math is insufficient when configuration propagation fails.
- **Altitude/pressure model:** iOS and shared core are aware; Watch product path is sea-level-only without disclosure.
- **Watch runtime timing:** software coverage exists; hardware and current-HEAD validation pending.
- **UI truthfulness:** accepted planner environment must match live authority; missing data must never appear as a valid sea-level calculation.
- **Activity/Logbook/Settings ownership:** current isolation is strong and must not regress.
- **Sync/schema/security:** signed and namespaced infrastructure is present; environment schema propagation and physical pairing evidence remain.
- **Persistence/recovery:** checkpoint design is useful, but cannot recover data discarded before runtime construction.
- **Privacy/GPS/export:** policies exist; field and external interoperability evidence pending.
- **Performance/battery:** software budgets exist; physical evidence pending.
- **Localization/accessibility:** catalog parity is strong; physical QA and cross-platform script path normalization remain.
- **Release/legal:** posture is appropriately non-certified; external review is not complete.
- **Documentation:** current headers are correct, but historical sections contain contradictory scope statements.

## 5. Readiness matrix

| Area | Code readiness | Automated test readiness | Documentation readiness | Physical QA readiness | External validation readiness | Overall readiness | Blockers |
|---|---|---|---|---|---|---|---|
| Gauge | High | High historical | High | Pending | N/A | Conditional | Underwater/device QA |
| Full Computer | **Fail** | **Fail altitude** | Partial | Pending | Pending | **NO-GO** | ORCH-001/002/003/004/005 |
| iOS Planner | High | High historical | High | Pending | Pending | Conditional | External Bühlmann/CCR |
| Apnea | High | High historical | High | Pending | Pending if claims expand | Conditional | Physical lifecycle/accessibility |
| Snorkeling | High | High historical | High | Pending | N/A | Conditional | GPS/privacy/battery field QA |
| Activity ownership | High | High historical | High | Pending | N/A | Conditional | Physical navigation replay |
| Sync/security | High software | High historical | High | Pending | N/A | Conditional | Paired-device QA |
| Persistence/schema | Partial | Partial | High | Pending | N/A | **Fail** | Altitude provenance loss |
| Performance | High software | Medium | High | Pending | N/A | Pending | Device profiling |
| Localization/accessibility | High software | High catalog | High | Pending | N/A | Pending | VoiceOver/Dynamic Type; tooling |
| Mockups/visual | Medium-high | Software contracts | High | Pending | Human review pending | Pending | Device/manual pixel evidence |
| Release/legal | High internal policy | Policy tests | High | Pending | Pending | **Blocked** | P0 plus counsel/store review |

## 6. Top 10 remediation priorities

1. Preserve and require validated `PlannerEnvironment` through Watch activation and live startup.
2. Fail closed and show environment/source/fallback on Watch predive/confirmation.
3. Add an independent altitude-aware Bühlmann oracle and complete required profile matrix.
4. Persist environment provenance in Full Computer logbook, sync, CSV/PDF, and migrations.
5. Rerun both app builds, full test schemes, altitude/Audit 15 suites, and readiness scripts on macOS.
6. Complete Watch Ultra underwater/entitlement/Water Lock/wet interaction QA.
7. Complete paired Watch/iPhone trust/sync/conflict/large-payload QA.
8. Complete independent Bühlmann/CCR and Subsurface validation.
9. Complete VoiceOver/Dynamic Type, visual pixel, PDF render, and device matrix evidence.
10. Complete legal/App Store review and clean contradictory historical documentation/tooling portability.

## 7. Final verdict

```text
INTERNAL_CODE_READINESS: NO-GO
INTERNAL_TEST_READINESS: NO-GO
TESTFLIGHT_READINESS: NO-GO
APP_STORE_READINESS: NO-GO
PHYSICAL_QA_STATUS: PENDING
EXTERNAL_VALIDATION_STATUS: PENDING
P0_EXISTS: YES
P1_EXISTS: YES
```

Audit orchestration complete. No production code was modified. No commit or push was performed.
