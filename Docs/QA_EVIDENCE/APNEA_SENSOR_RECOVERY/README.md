# Apnea Sensor Recovery — Physical QA Evidence

**Status:** PENDING  
**Scope:** Real sensor loss and recovery on device (submersion sensor / depth feed).  
**App commit:** _fill on execution_  
**Device model:** _  
**watchOS version:** _  
**Tester:** _  
**Date:** _

## Rule

Do **not** mark PASS without attached evidence.

## Test matrix

| ID | Step | Expected | Observed | Evidence | PASS/FAIL |
|----|------|----------|----------|----------|-----------|
| SR-01 | Sensor loss at surface | Degraded phase | | | PENDING |
| SR-02 | Sensor loss during dive | Degraded; no fabricated depth | | | PENDING |
| SR-03 | Recovery with valid samples | Operational phase | | | PENDING |
| SR-04 | Manual fallback enable | Explicit user control | | | PENDING |
| SR-05 | Manual fallback descent/surface | No auto lifecycle conflict | | | PENDING |
