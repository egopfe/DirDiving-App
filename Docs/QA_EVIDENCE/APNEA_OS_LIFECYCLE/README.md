# Apnea OS Lifecycle — Physical QA Evidence

**Status:** PENDING  
**Scope:** Background suspend, foreground resume, force termination, wall-clock change during Apnea session.  
**Prerequisites:** Watch build with Apnea session active; companion optional.  
**App commit:** _fill on execution_  
**Device model:** _  
**watchOS version:** _  
**Tester:** _  
**Date:** _

## Rule

Do **not** mark PASS without attached evidence. Simulator checkpoint tests do **not** substitute for this matrix.

## Test matrix

| ID | Step | Expected | Observed | Evidence | PASS/FAIL |
|----|------|----------|----------|----------|-----------|
| OS-01 | Background during ready | Session ID preserved on resume | | | PENDING |
| OS-02 | Background during descent | Active dive continues conservatively | | | PENDING |
| OS-03 | Background at depth | No duplicate dive | | | PENDING |
| OS-04 | Background during ascent | Ascent continues | | | PENDING |
| OS-05 | Background during recovery | Recovery interval preserved | | | PENDING |
| OS-06 | Foreground resume | Monotonic elapsed does not regress | | | PENDING |
| OS-07 | Force termination | Checkpoint restore on relaunch | | | PENDING |
| OS-08 | Relaunch | No silent new session | | | PENDING |
| OS-09 | Wall-clock change | Elapsed time stable | | | PENDING |
| OS-10 | Low Power Mode | Degraded handling acceptable | | | PENDING |

## Evidence filenames

- `OS-##_screen_recording.mov`
- `OS-##_checkpoint_before.json` / `OS-##_checkpoint_after.json`
