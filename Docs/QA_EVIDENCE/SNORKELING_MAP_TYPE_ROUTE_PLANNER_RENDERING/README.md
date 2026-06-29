# Physical QA — SNORKELING_MAP_TYPE_ROUTE_PLANNER_RENDERING

| Field | Value |
|-------|-------|
| **QA ID** | SNK-QA-024 |
| **Command category** | SNORKELING_MAP_TYPE_ROUTE_PLANNER_RENDERING |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Confirm iOS Snorkeling Route Planner map style follows map type preference |
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

- Location permission granted for Route Planner.
- At least one waypoint or route segment visible on map.

## Test steps

1. Install the build at the recorded commit SHA.
2. Open Settings → Snorkeling → Map Type → select **Satellite**.
3. Open Snorkeling Route Planner; verify hybrid/satellite basemap with route polyline.
4. Return to settings; select **Explore**.
5. Reopen Route Planner; verify standard cartographic basemap.
6. Capture before/after screenshots or video.

## Expected results

Route Planner map style updates to match Snorkeling map type preference. Waypoint and polyline rendering unchanged.

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
