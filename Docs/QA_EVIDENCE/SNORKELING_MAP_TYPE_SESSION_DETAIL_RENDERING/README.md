# Physical QA — SNORKELING_MAP_TYPE_SESSION_DETAIL_RENDERING

| Field | Value |
|-------|-------|
| **QA ID** | SNK-QA-025 |
| **Command category** | SNORKELING_MAP_TYPE_SESSION_DETAIL_RENDERING |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Confirm iOS Snorkeling session detail map uses Snorkeling-only map type preference |
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

- At least one completed Snorkeling session with GPS track in logbook.
- Location permission granted.

## Test steps

1. Install the build at the recorded commit SHA.
2. Open Settings → Snorkeling → Map Type → select **Satellite**.
3. Open a Snorkeling session with GPS track; verify hybrid/satellite basemap on session map.
4. Change map type to **Explore** in settings.
5. Reopen the same session detail; verify standard cartographic basemap.
6. Confirm Diving/Apnea maps (if accessible) are unaffected.
7. Capture screenshot or video evidence.

## Expected results

Session detail map style follows Snorkeling map type preference only. No cross-activity map style leakage.

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
