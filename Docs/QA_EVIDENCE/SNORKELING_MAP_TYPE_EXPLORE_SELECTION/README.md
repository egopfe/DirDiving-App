# Physical QA — SNORKELING_MAP_TYPE_EXPLORE_SELECTION

| Field | Value |
|-------|-------|
| **QA ID** | SNK-QA-023 |
| **Command category** | SNORKELING_MAP_TYPE_EXPLORE_SELECTION |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Confirm Explore map type selection persists across Snorkeling screens |
| **Required device** | iPhone (+ Watch for settings parity if applicable) |
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

- Snorkeling map type not previously set to Explore, or UserDefaults reset.
- Location permission granted if map preview requires GPS.

## Test steps

1. Install the build at the recorded commit SHA.
2. Open Settings → Snorkeling → Map Type.
3. Select **Explore**.
4. Open Snorkeling Route Planner and Session Detail map (if track available).
5. Confirm standard cartographic basemap on both screens.
6. Force-quit and relaunch app; confirm Explore persists.
7. Capture screenshot or video evidence.

## Expected results

Explore selection persists in UserDefaults and renders standard map style on Snorkeling maps only.

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
