# Apnea APNEA AIRPLANE MODE — physical QA evidence

**Status:** PENDING  
**Rule:** PASS requires attached evidence (screenshots/video/logs). Do not mark PASS without execution.

| Field | Value |
|-------|-------|
| Scope | See matrix in Docs/APNEA_RELEASE_HARD_TEST_MATRIX.md |
| Prerequisites | Paired devices, Apnea enabled, valid plan on iOS |
| App commit | _(fill at test time)_ |
| iPhone model | |
| Apple Watch model | |
| iOS version | |
| watchOS version | |
| Tester | |
| Date | |
| Result | PENDING |

## Steps
1. Pair iPhone and Watch; confirm reachability in Apnea dashboard.
2. Send valid plan from iOS planner; confirm Watch receives and can activate explicitly.
3. Complete Watch session offline; reconnect; confirm session appears once in iOS logbook.
4. Confirm signed ACK clears Watch pending queue only after valid import.

## Expected
- No duplicate sessions; namespaces isolated; invalid ACK does not clear queue.

## Observed
_(pending)_

## Evidence files
- `screenshots/`
- `video/`
- `logs/`
