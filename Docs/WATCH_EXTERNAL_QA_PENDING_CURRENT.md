# Watch External QA — Still Pending

**Updated:** 2026-06-19  
**Branch:** `main`  
**Software gate:** PASS (856 Watch Algorithm Tests, 0 skipped, 0 failed)

These gates **must not** be closed by simulator tests, fabricated evidence, or automated software validation alone.

| Gate ID | Description | Status | Evidence Required |
|---|---|---|---|
| WATCH-PHY-001 | Apple Watch Ultra physical depth/ascent/haptic validation | **PENDING** | Completed rows in `Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` |
| WATCH-PHY-002 | Real paired iPhone/Watch sync round-trip | **PENDING** | Completed rows in `Docs/WATCH_IOS_SYNC_QA_MATRIX.md` |
| WATCH-EXT-001 | External Bühlmann reference validation | **PENDING** | Independent reference vectors; see `Docs/QA_EVIDENCE/RATIO_DECO_EXTERNAL/README.md` |
| WATCH-PERF-001 (physical) | Long-dive real-device battery and thermal profiling | **PENDING** | Field battery/thermal logs on Ultra hardware |
| UNDERWATER-QA | Real underwater validation | **PENDING** | Field dive logs |
| ENTITLEMENT-QA | Apple entitlement validation | **PENDING** | Device entitlement verification |
| LEGAL-QA | External legal/certification review | **PENDING** | Legal sign-off |

## Software vs physical classification

| Category | Count | Notes |
|---|---:|---|
| Software-only skipped tests (before remediation) | 19 | 6 Keychain peer-secret + 13 environment/feature |
| Software-only skipped tests (after remediation) | **0** | All Watch Algorithm Tests execute |
| Physical/integration skips allowed | 0 in unit suite | Physical tests documented in QA matrices only |

## External release posture

```text
EXTERNAL_WATCH_RELEASE_GATE: PENDING_EXTERNAL_EVIDENCE
```

Simulator/unit tests passing does **not** imply TestFlight or App Store readiness for certified dive-computer claims.
