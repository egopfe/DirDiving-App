# Physical QA — SNORKELING_MAP_TYPE_DEFAULT_SATELLITE

| Field | Value |
|-------|-------|
| **QA ID** | SNK-QA-022 |
| **Command category** | SNORKELING_MAP_TYPE_DEFAULT_SATELLITE |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Confirm Snorkeling map type defaults to Satellite (hybrid basemap) |
| **Required device** | iPhone |
| **Tester** | |
| **Reviewer** | |
| **Execution date** | |
| **iPhone model** | |
| **iOS version** | |
| **Watch model** | |
| **watchOS version** | |
| **App build** | |
| **Test environment** | |
| **Rollback required** | NO |

## Preconditions

- Fresh install or reset Snorkeling map type UserDefaults key `dirdiving.snorkeling.mapType`.
- Location permission granted for Route Planner if map centering is required.

## Test steps

1. Install the build at the recorded commit SHA.
2. Do not change Snorkeling map type settings.
3. Open Snorkeling Route Planner.
4. Confirm Satellite (hybrid) basemap is shown by default.
5. Capture screenshot or video evidence.

## Expected results

Default map style is Satellite (hybrid/imagery with labels). No Explore/standard basemap unless user selects it.

## Observed results

**PENDING** — no physical evidence recorded yet.

## Evidence artifacts

- (none — add `evidence-YYYYMMDD.ext` paths after capture)

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

**PENDING** — PASS requires completed steps, attached artifacts, tester signature, and reviewer signature.
Do not mark PASS without real device execution.
