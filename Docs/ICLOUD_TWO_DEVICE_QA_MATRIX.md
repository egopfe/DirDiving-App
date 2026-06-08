# iCloud Two-Device QA Matrix — DIR DIVING MAIN

**Owner:** ________ **Date:** ________ **Build:** ________ **Commit:** ________

**Status:** Manual execution **PENDING** unless Pass/Fail filled with evidence.

**Evidence folder:** `Docs/QA_EVIDENCE/ICLOUD_TWO_DEVICE/`

---

## Preconditions (all cases)

- Two physical iOS devices (A, B) signed into **same iCloud account** with DIR DIVING installed from same build.
- Note device models, iOS versions, and whether KVS sync enabled in app settings.

---

| ID | Scenario | Preconditions | Steps | Expected result | Observed | Pass/Fail | Evidence | Reviewer |
|---|---|---|---|---|---|---|---|---|
| IC-01 | Clean A upload | Empty B | Create dive on A; wait sync | B receives dive | | **PENDING** | | |
| IC-02 | Clean B download | A has data | Install fresh on B | B matches A | | **PENDING** | | |
| IC-03 | Same dive edited both | Dive on both | Edit title on A and B offline; reconnect | Conflict UI; no silent merge | | **PENDING** | | |
| IC-04 | Divergent sample profile | Recorded dive | Different sample edits A/B | Divergent profile detected | | **PENDING** | | |
| IC-05 | Manual CCR dive metadata | CCR manual dive on A | Sync to B | Setpoint/diluent/bailout preserved | | **PENDING** | | |
| IC-06 | Planner CCR input round-trip | CCR plan saved | Sync planner state | CCR JSON fields intact | | **PENDING** | | |
| IC-07 | Tombstone delete A | Dive on both | Delete on A | B removes dive | | **PENDING** | | |
| IC-08 | Deleted dive no resurrect | Tombstoned dive | Edit stale copy on B | Tombstone wins | | **PENDING** | | |
| IC-09 | KVS payload too large | Large profile | Upload | Graceful rejection/message | | **PENDING** | | |
| IC-10 | No iCloud account | Signed out | Open app | No crash; skip sync | | **PENDING** | | |
| IC-11 | Offline queue | Airplane mode | Edit; reconnect | Eventually consistent | | **PENDING** | | |
| IC-12 | Malformed cloud payload | Test fixture | Inject bad JSON | Safe error; no corrupt local | | **PENDING** | | |

---

## Automated unit coverage (local merge logic)

Verified in XCTest (not a substitute for two-device QA):

- CCR plan JSON encode/decode round-trip
- Cloud conflict / tombstone fixtures where present in `CloudSyncStoreTests` / `CloudSessionMergeTests`

---

## Release gate

**External TestFlight / App Store:** IC-01…IC-08 minimum **PASS** required.
