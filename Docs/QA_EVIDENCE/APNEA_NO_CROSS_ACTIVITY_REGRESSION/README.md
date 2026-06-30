# Physical QA — APNEA_NO_CROSS_ACTIVITY_REGRESSION

| Field | Value |
|-------|-------|
| **QA ID** | APN-QA-011 |
| **Priority** | P1 / P2 / P3 |
| **Command category** | APNEA_IOS_WATCH_P1_P2_P3 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Apnea P1/P2/P3 changes do not regress Diving, Snorkeling, Gauge, Full Computer |
| **Required device** | Paired iPhone + Apple Watch |
| **Tester** | |
| **Reviewer** | |
| **Execution date** | |
| **iPhone model** | |
| **iOS version** | |
| **Apple Watch model** | |
| **watchOS version** | |
| **App build** | |
| **Test environment** | |
| **Rollback required** | YES |

## Preconditions

- Same build with Apnea features enabled
- Smoke access to Diving, Snorkeling, Gauge, Full Computer on iOS and Watch

## Test steps

1. Install build at recorded commit SHA.
2. **Diving:** open planner/logbook; confirm unchanged core flow.
3. **Snorkeling:** route planner, map, Watch GPS route — smoke test unchanged.
4. **Gauge / Full Computer:** start/stop session smoke on Watch.
5. **Apnea:** complete brief session; confirm no Snorkeling route UI in Apnea.
6. Verify dive logbook ownership unchanged; Apnea logbook separate.
7. Verify location policy: Apnea no background location; Snorkeling unchanged.
8. Record any regressions with screenshots/logs.

## Expected results

No cross-activity breakage. Apnea scope isolated. No Snorkeling map/route in Apnea runtime.

## Observed results

**PENDING** — no physical evidence recorded yet.

## Evidence artifacts

- (none — add `evidence-YYYYMMDD.ext` after capture)

## Signatures

| Role | Name | Date |
|------|------|------|
| Tester | | |
| Reviewer | | |

## Tester signature

(pending)

## Reviewer signature

(pending)

## Verdict

**PENDING** — PASS requires completed steps, artifacts, and signatures. Do not mark PASS without real device execution.
