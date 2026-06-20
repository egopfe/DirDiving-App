# Watch Mathematical Functions — External QA Pending

**Updated:** 2026-06-19 (post software remediation)  
**Branch:** `main` @ `79e242e` + uncommitted remediation  
**Software evidence:** 880 Watch Algorithm Tests, 0 failed, 0 skipped (Apple Watch Series 11 46mm simulator)

These gates **cannot** be closed by simulator/unit tests alone. No fabricated field evidence is claimed.

| Gate ID | Description | Status | Required evidence |
|---|---|---|---|
| WATCH-EXT-001 | Independent external Bühlmann reference validation on Watch hardware | **PENDING** | Third-party reference vectors; field or lab comparison |
| WATCH-PHY-001 | Apple Watch Ultra physical depth/ascent/haptic accuracy | **PENDING** | Completed `Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` rows |
| WATCH-PHY-002 | Paired iPhone/Watch mathematical sync round-trip | **PENDING** | Completed `Docs/WATCH_IOS_SYNC_QA_MATRIX.md` rows |
| WATCH-PERF-001 (physical) | Long-dive battery/thermal impact on math sampling cadence | **PENDING** | Ultra field battery/thermal logs |
| UNDERWATER-QA | Real underwater Gauge/FC validation | **PENDING** | Signed field dive logs |
| GPS-FIELD-QA | Real-world Snorkeling GPS distance/bearing validation | **PENDING** | Measured course comparison |

## Software vs physical classification

| Category | Audit baseline | After remediation |
|---|---:|---:|
| Watch Algorithm Tests executed | 856 | **880** |
| Skipped (software-only) | 0 | **0** |
| Failed | 0 | **0** |
| Software findings open | 3 | **0** |

## Audit-15 mandatory profile (Air 39 m)

Software gate **PASS**: `testAudit15Air39MultilevelProfile` with independent oracle second-by-second tissue comparison. Physical Watch underwater validation: **PENDING**.

## Release posture

```text
WATCH_MATH_SOFTWARE_GATE: PASS (880/880)
WATCH_MAIN_MATH_SOFTWARE_READINESS: 100%
WATCH_MATH_EXTERNAL_VALIDATION: PENDING
WATCH_MATH_PHYSICAL_ULTRA_QA: PENDING
EXTERNAL_WATCH_MATH_RELEASE_GATE: PENDING_EXTERNAL_EVIDENCE
```

Simulator mathematical tests passing does **not** certify the Watch as a dive computer.
