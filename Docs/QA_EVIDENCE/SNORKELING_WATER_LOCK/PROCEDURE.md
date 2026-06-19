# Snorkeling Water Lock — Physical Procedure

**QA ID:** SNK-QA-004 (`SNORKELING_WATER_LOCK`)  
**Status:** PENDING — simulator behavior is not proof.

## Platform note

Water Lock is a watchOS system feature. This procedure validates Snorkeling session integrity around lock/unlock; it does not substitute for Apple platform QA.

## Devices

- Physical Apple Watch (41 mm minimum; Ultra recommended for one matrix row)
- Paired iPhone when sync scenarios are included

## Scenarios

| ID | Step | Expected | Observed | PASS/FAIL |
|----|------|----------|----------|-----------|
| WL-01 | Arm Water Lock before session start | Ready UI remains truthful; start gated per sensor policy | | PENDING |
| WL-02 | Start session, then enable Water Lock | No duplicate session or dip; lifecycle state consistent | | PENDING |
| WL-03 | Navigate with Water Lock on | Critical metrics remain visible where platform allows | | PENDING |
| WL-04 | Digital Crown unlock | UI resumes without corrupting navigation state | | PENDING |
| WL-05 | Save marker after unlock | Marker persisted once; confirmation shown | | PENDING |
| WL-06 | End session after unlock | Single summary; no duplicate logbook entry | | PENDING |
| WL-07 | Force-quit during locked session | Recovery banner on relaunch if checkpoint exists | | PENDING |

## Rollback

If session corruption or duplicate dip is observed, file blocking issue and set verdict **FAIL**.

## Artifacts

- Video of crown unlock sequence
- Screenshot of summary screen
- Optional sync log from paired iPhone
