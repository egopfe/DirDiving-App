# R09 — WAO Routing Test Alignment Remediation Report (Current)

**Branch:** `main`  
**Baseline HEAD (before):** `0d3a26b`  
**Remediation HEAD (after):** `cc0efc6`  
**Scope:** Software-only Batch-6 / R09 per `MASTER_CURSOR_REMEDIATION_COMMAND_SEQUENCE_CURRENT.md`  
**Excluded:** Physical QA, wet/field QA, legal, App Store, external Bühlmann validation

---

## Summary

Closed **CONS-050 / WFC-P2-005** by aligning Watch water-auto-open routing tests with current `DepthCapabilityPolicy` + shallow-entitlement developer-toggle policy. Fixed **Snorkeling route progress** at route entry (production bug: progress counted `traversed` before current position). Repaired **CONS-053** legacy claim docs and **CONS-054** README baseline truthfulness.

**Full Computer safety P0:** **0** (unchanged; all FC algorithm tests remain PASS).

---

## Root cause — CONS-050 / WFC-P2-005

| Failure group | Count | Root cause | Fix type |
|---------------|------:|------------|----------|
| `WatchWaterAutoOpenPolicyTests` | 9 | Tests called `resolveWaterAutoLaunchStep()` without shallow entitlement + developer gauge/FC testing toggles; `DepthCapabilityPolicy.current` blocked gauge/FC → returned `.divingModeSelection` | **Test harness** |
| `WatchLaunchRoutingPolicyTests` | 3 | Same depth-capability test environment gap | **Test harness** |
| `SnorkelingRouteProgressCalculatorTests` | 1 | Progress loop credited `traversed` distance for segments not yet reached by current position | **Production** (minimal) |

Production routing policy in `DIRStartupSelectionPolicy.resolveAutomaticStep` was **correct**; tests were stale relative to post-remediation depth-capability gates.

---

## Files changed

| File | Change |
|------|--------|
| `Tests/WatchAlgorithmTests/WatchRoutingTestSupport.swift` | **New** — shared shallow entitlement + developer toggle setup |
| `Tests/WatchAlgorithmTests/WatchWaterAutoOpenPolicyTests.swift` | setUp/tearDown use test support |
| `Tests/WatchAlgorithmTests/WatchLaunchRoutingPolicyTests.swift` | setUp/tearDown use test support |
| `Shared/Utils/SnorkelingRouteProgressCalculator.swift` | Skip progress credit for segments before current position |
| `Docs/WATCH_LOW_POWER_MISSION_MODE_IMPLEMENTATION_REPORT.md` | CONS-053 superseded header + demoted App Store claims |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260609.md` | CONS-053 CCR claim corrected to PENDING |
| `README.md` | CONS-054 baseline aligned to orchestrator PARTIAL verdict |
| `Docs/R09_WAO_ROUTING_TEST_ALIGNMENT_REMEDIATION_REPORT_CURRENT.md` | This report |

**No changes** to Bühlmann, decompression math, HMAC, sync contracts, or production WAO routing logic.

---

## Tests run

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
bash Scripts/validate_commands_for_cursor_integrity.sh
bash Scripts/check_main_target_isolation.sh
bash Scripts/check_secrets.sh
```

| Gate | Result |
|------|--------|
| Watch Algorithm Tests | **1152/1152 PASS** |
| iOS Algorithm Tests | **PASS** (full suite) |
| Command integrity V1.5 | **PASS** |
| Target isolation | **PASS** |
| Secrets scan | **PASS** |

---

## Remaining open items

### Software / code
- None blocking from CONS-050 (closed)

### Documentation truthfulness
- `Docs/INDEX.md` — may need CONS-050 closure entry (post-commit)
- Feature matrix rows (WAO/GF/shallow) — P2 doc alignment per audit 06

### Physical QA — **PENDING (not addressed)**
- CONS-010, CONS-021, CONS-022, CONS-042, CONS-048, Apnea wet QA — 0% executed

### External validation — **PENDING (not addressed)**
- CONS-009 / WFC-P1-001 external Bühlmann validation

### Legal / App Store — **PENDING (not addressed)**
- CONS-044 legal/marketing sign-off

---

## Non-regression notes

- Watch FC forensic tests (Audit-15, Schreiner, oracle, multilevel) unchanged PASS
- Apnea / Snorkeling / Diving activity isolation preserved
- WAO routing production code unchanged; only test environment + snorkeling progress math fixed

---

## Verdict

```text
CONS-050: FIXED_SOFTWARE
WFC-P2-005: CLOSED
WATCH_TEST_SUITE: 1152/1152 PASS
IOS_TEST_SUITE: PASS
FC_SAFETY_P0: 0
INTERNAL_TESTFLIGHT_SOFTWARE: READY (conditional on disclosure)
PHYSICAL_QA: PENDING
EXTERNAL_VALIDATION: PENDING
LEGAL_APP_STORE: PENDING
```

---

## Next recommended step

Per `Docs/MASTER_AUDIT_RERUN_PLAN_CURRENT.md`:

1. Run **audit 07** post-remediation verification @ remediation HEAD
2. Refresh orchestrator consolidation if audit 07 outputs change
3. Execute physical QA Batch-8 (out of software scope)
