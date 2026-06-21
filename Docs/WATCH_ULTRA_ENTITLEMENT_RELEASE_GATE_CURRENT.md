# Watch Ultra Entitlement Release Gate (Current)

**Date:** 2026-06-20  
**Evidence:** [`QA_EVIDENCE/HARDWARE_ENTITLEMENT/`](QA_EVIDENCE/HARDWARE_ENTITLEMENT/) — **PENDING_PHYSICAL_QA**

---

## Truthful states (must remain distinguishable)

| State | Meaning | May claim in copy? |
|-------|---------|-------------------|
| Entitlement configured | Apple Developer portal capability present | No — not reliability proof |
| API available | `CMWaterSubmersionManager.waterSubmersionAvailable` | No — device/environment dependent |
| Simulator behavior | Mock/simulation depth | Must be labeled simulation |
| Physical device behavior | Ultra hardware session | Requires signed field evidence |
| Validated field behavior | Completed QA matrix | **Not achieved** — PENDING |

---

## Product copy rules

- Do not state entitlement configuration proves sensor reliability.
- Do not state simulator behavior proves device behavior.
- TestFlight notes must disclose physical validation **PENDING** where applicable.
- Settings/diagnostics must show truthful sensor source (live/simulation/fallback).
- Fallback and stale-depth states must remain visible.

---

## Release gate

| Gate | Software | Field |
|------|----------|-------|
| Internal TestFlight | PASS with simulation disclosure | PENDING |
| External TestFlight | Blocked without field artifact | NOT PASSED |
| App Store | Blocked | NOT PASSED |

---

## Evidence exit criteria

`HARDWARE_QA_MATRIX` QA-002 artifact in `QA_EVIDENCE/HARDWARE_ENTITLEMENT/` with signed build, tester, reviewer, Ultra serial (optional), and depth session log.
