# Apnea Watch Ultra — Physical QA Evidence

**Status:** PENDING  
**Scope:** Real submersion lifecycle on Apple Watch Ultra (automatic immersion/surface, recovery, multi-dive).  
**Prerequisites:** Apnea Command 04 UI promoted to MAIN (or TestFlight build with Apnea enabled).  
**App commit:** _fill on execution_  
**Device model:** Apple Watch Ultra (generation: _)  
**watchOS version:** _  
**Tester:** _  
**Date:** _

## Rule

Do **not** mark PASS without attached evidence files (screen recording, exported session JSON, log excerpt).

## Test matrix

| ID | Step | Expected | Observed | Evidence | PASS/FAIL |
|----|------|----------|----------|----------|-----------|
| WU-01 | Surface arming | Ready phase, buddy/disclaimer visible | | | PENDING |
| WU-02 | Automatic descent | Dive starts without manual tap | | | PENDING |
| WU-03 | Active immersion | Depth/time update at depth | | | PENDING |
| WU-04 | Ascent | Phase transitions to ascent | | | PENDING |
| WU-05 | Surface dwell | Dive not closed by oscillation | | | PENDING |
| WU-06 | Recovery | Informational recovery timer | | | PENDING |
| WU-07 | Multiple dives | Second dive after recovery | | | PENDING |
| WU-08 | Surface oscillation | No premature dive close | | | PENDING |
| WU-09 | Depth spike | Spike rejected / no false phase | | | PENDING |
| WU-10 | Sensor loss | Degraded phase | | | PENDING |
| WU-11 | Sensor recovery | Returns operational | | | PENDING |
| WU-12 | Manual fallback | Controlled descent/surface only | | | PENDING |
| WU-13 | Checkpoint restore | Session resumes after relaunch | | | PENDING |
| WU-14 | Crash/relaunch | No silent session reset | | | PENDING |
| WU-15 | Session persistence | Logbook entry on iOS | | | PENDING |

## Evidence filenames

- `WU-##_recording.mov`
- `WU-##_session_export.json`
- `WU-##_notes.md`
