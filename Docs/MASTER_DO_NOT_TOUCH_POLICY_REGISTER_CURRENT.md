# Master Do-Not-Touch Policy Register — Current

**Orchestrator:** V1.2 @ `7dfefe2`  
**Date:** 2026-06-28  
**Purpose:** Policies remediation must not violate. See also `MASTER_NON_REGRESSION_GATE_MATRIX_CURRENT.csv`.

---

## Product architecture

| Policy ID | Area | Do not touch until | Reason |
|-----------|------|-------------------|--------|
| DNTP-001 | Multi-activity isolation | Never without Batch-3 audit rerun | Diving / Apnea / Snorkeling data, Settings, Logbooks must not leak |
| DNTP-002 | Gauge vs Full Computer semantics | Never | Gauge: depth/runtime/TTV informational only — no NDL/TTS/ceiling/deco |
| DNTP-003 | iOS Planner → Watch live mutation | **Never** | Planner must not mutate active Watch dive; briefing cards reference-only |

---

## Safety-critical Watch Full Computer

| Policy ID | Area | Do not touch until | Reason |
|-----------|------|-------------------|--------|
| DNTP-010 | Bühlmann / Schreiner / GF core math | Batch-1 complete + oracle rerun | Live decompression safety; P0 FC count must stay 0 |
| DNTP-011 | Watch FC live runtime timer / degraded policy | Batch-1 evidence | 1Hz tick + degraded = safe posture; no silent reset on overlap |
| DNTP-012 | Altitude environment propagation | Never without Batch-1 full matrix | import→runtime→logbook chain; prior P0 FIXED @ 7dfefe2 |
| DNTP-013 | CMAltimeter accept/reject flows | Batch-1 + physical QA | Environment sensor gating |
| DNTP-014 | GF preset locked iosPlan import contract | Batch-4 complete + tests | Predive snapshot integrity; CONS-002 fix must preserve fail-closed |

---

## Sync / security / data integrity

| Policy ID | Area | Do not touch until | Reason |
|-----------|------|-------------------|--------|
| DNTP-020 | HMAC / nonce / replay / tombstone sync | Batch-2 complete | CONS-003..005 fixes must not weaken integrity |
| DNTP-021 | Activity sync payload routing keys | Batch-2 complete | Cross-activity isolation |
| DNTP-022 | Planner briefing cards reference-only | **Never** | `referenceOnlyKey` always true; no live planner state on Watch |
| DNTP-023 | Legacy unsigned tombstone expansion | Never | Do not add unsigned fallbacks beyond documented compat |

---

## CCR / Rebreather

| Policy ID | Area | Do not touch until | Reason |
|-----------|------|-------------------|--------|
| DNTP-030 | CCR live controller semantics | **Never** (separate program) | Reference-only until implemented, tested, externally validated, legally positioned |

---

## June 2026 wave — preserve SOFTWARE_READY posture

| Policy ID | Area | Do not touch until | Reason |
|-----------|------|-------------------|--------|
| DNTP-040 | Water auto-open predive gate | Batch-6 policy fix only | Must not auto-start live FC runtime; legal gate on intents |
| DNTP-041 | Crown underwater navigation clamp | Batch-6 + physical QA | Do not re-enable Settings/Logbook during active session |
| DNTP-042 | Action Button / App Intents router | Batch-6 + physical QA | Legacy intents must route through `WatchIntentSafetyPolicy` |
| DNTP-043 | Shallow depth signing default | Batch-7 + physical QA | `WithShallowDepth` entitlements; do not ship full-depth FC on App Store shallow build |
| DNTP-044 | Developer shallow Gauge/FC toggles | Batch-7 process only | Default OFF; internal-only labeling; TestFlight process discipline |

---

## Physical / external validation honesty

| Policy ID | Area | Do not touch until | Reason |
|-----------|------|-------------------|--------|
| DNTP-050 | Simulator → physical conversion | Never | Do not mark WAO/HW/shallow/depth matrices PASS without artifacts |
| DNTP-051 | Unit tests → external validation conversion | Never | CONS-009 requires third-party or chamber evidence |
| DNTP-052 | SOFTWARE_READY → PENDING_PHYSICAL downgrade | Never in docs | Preserve both facts per orchestrator V1.2 §0C |

---

## UI / UX truthfulness

| Policy ID | Area | Do not touch until | Reason |
|-----------|------|-------------------|--------|
| DNTP-060 | Critical FC state visibility | Never | Do not hide ceiling/TTS/stop state in remediation |
| DNTP-061 | Mockup PNG in production UI | Never | Visual regression uses SwiftUI fixtures only |
| DNTP-062 | Apnea/Snorkeling placeholder appearance | Never without product decision | First-class activities on MAIN |

---

## Security / privacy / platform

| Policy ID | Area | Do not touch until | Reason |
|-----------|------|-------------------|--------|
| DNTP-070 | Privacy manifests / Info.plist usage strings | Batch-7 + audit rerun | App Store rejection risk |
| DNTP-071 | Entitlement declarations | Batch-7 | Shallow/full depth separation |
| DNTP-072 | TOFU peer secret bootstrap | Documented accepted risk only | WC boundary; no bypass for convenience |

---

## Documentation / release

| Policy ID | Area | Do not touch until | Reason |
|-----------|------|-------------------|--------|
| DNTP-080 | App Store / legal certification wording | Batch-9 + evidence gates | Unsupported claims liability; CONS-044 |
| DNTP-081 | Documentation INDEX baseline SHAs | Batch-9 truth | False readiness reporting; CONS-034 |
| DNTP-082 | `commands_for_cursor/01`–`04` bodies | Batch-9 repair only | CONS-001 P0 — wrong audit execution |
| DNTP-083 | Performance generation tokens / background planner | Batch-5 verified | Recently remediated; regression tests required |

---

## Recently verified fixed — do not regress

| Area | Evidence @ 7dfefe2 |
|------|-------------------|
| Altitude P0 environment propagation | `OrchestratedAltitudeEnvironmentTests` |
| Water auto-open cold-launch probe wiring | `WatchSubmersionLaunchProbe`, `WatchLaunchRoutingPolicyTests` |
| Crown clamp + intent router | `WatchUnderwaterNavigationClampPolicyTests` |
| Activity-scoped signed tombstones (Apnea/Snorkeling) | `ActivitySyncTombstoneTests` |
| Legal gate on App Intents | `ActionButtonIntents` tests |

---

**POLICY_REGISTER_STATUS: ACTIVE · 28 policies · Baseline 7dfefe2**
