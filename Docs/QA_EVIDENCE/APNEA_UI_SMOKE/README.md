# Apnea UI Smoke — Physical QA Evidence

**Status:** PENDING  
**Scope:** Watch Apnea UI smoke after Command 04 MAIN promotion (ready, active, surface/recovery, end session).  
**Prerequisites:** `ApneaView.swift` compiled into MAIN Watch target **only after** Command 04 promotion review.  
**App commit:** _fill on execution_  
**Device model:** _  
**watchOS version:** _  
**Tester:** _  
**Date:** _

## Rule

Do **not** mark PASS without attached evidence. Until Command 04 promotion, all rows remain PENDING.

## Test matrix

| ID | Step | Expected | Observed | Evidence | PASS/FAIL |
|----|------|----------|----------|----------|-----------|
| UI-01 | Activity selection | Apnea reachable per navigation spec | | | PENDING |
| UI-02 | Ready screen | Buddy + reference-only disclaimer | | | PENDING |
| UI-03 | Active immersion | Depth/time visible | | | PENDING |
| UI-04 | Surface/recovery | Recovery informational copy | | | PENDING |
| UI-05 | End session | Returns to mode shell safely | | | PENDING |
| UI-06 | No medical/blackout claims | Copy review PASS | | | PENDING |
