# iCloud Two-Device QA — Evidence Folder

**Status: PENDING** — Do not mark PASS without attached files.

**Matrix:** [`Docs/ICLOUD_TWO_DEVICE_QA_MATRIX.md`](../../ICLOUD_TWO_DEVICE_QA_MATRIX.md)

---

## Scope

Two physical iOS devices on the same iCloud account: planner persistence, logbook create/edit/delete, CCR plan JSON round-trip, tombstone/delete propagation, conflict resolution UI, malformed payload handling, and offline queue recovery. XCTest merge fixtures do not substitute for this folder.

---

## Required device / simulator matrix

| Device | Role | iOS version | iCloud |
|--------|------|-------------|--------|
| Device A | Primary editor | Release target | Same Apple ID; KVS opt-in confirmed |
| Device B | Sync observer | Release target | Same Apple ID; KVS opt-in confirmed |

Both devices must run the same DIR DIVING build / commit under test.

---

## Required evidence files

- [ ] iCloud backup opt-in screenshot (both devices)
- [ ] IC-01…IC-12 scenario evidence per matrix (screenshot / video / notes)
- [ ] Planner persistence across devices (if in scope)
- [ ] Manual dive logbook sync
- [ ] CCR plan input JSON persistence
- [ ] Tombstone / delete propagation
- [ ] Conflict resolution UI capture
- [ ] Malformed payload behavior logs (if tested)

---

## Sign-off

| Field | Value |
|-------|-------|
| Device A model / iOS version | |
| Device B model / iOS version | |
| Same Apple ID / iCloud confirmed | yes/no (do not paste credentials) |
| App build / commit | |
| Tester | |
| Date | |
| Pass/Fail | **PENDING** |

**iCloud two-device QA is not passed until files are attached here.**
