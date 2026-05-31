# Watch ↔ iPhone sync — on-device QA checklist (MAIN)

**Date:** 2026-05-24  
**Branch:** `main`  
**Purpose:** Close device-only sync validation without changing sync code.

---

## Preconditions

- [ ] Physical iPhone + Apple Watch, paired via Watch app
- [ ] Both **DIR DIVING** apps installed (iOS + Watch)
- [ ] iOS **More → Sync Watch** shows supported and activated
- [ ] Note `git rev-parse --short HEAD` in test log

---

## 1. Watch → iPhone (dive upload)

| Step | Pass criteria |
|------|----------------|
| Complete a dive on Watch (auto or manual) | Dive appears in iOS **Logbook** after sync |
| Open iOS app while Watch app in background | Pending count decreases; last sync status updates |
| Airplane mode on both → dive on Watch → restore connectivity | Dive eventually appears on iPhone (offline retry) |

---

## 2. iPhone → Watch (push)

| Step | Pass criteria |
|------|----------------|
| Add/edit session on iPhone that should sync | Watch log reflects change after push |
| Use **Push to Watch** / sync controls in More if applicable | No duplicate rows without conflict UI |

---

## 3. Conflicts

| Step | Pass criteria |
|------|----------------|
| Edit same dive metadata on both devices while offline | Conflict card or resolution path appears on iOS |
| Choose keep-local / merge per UI | Resolution persists after relaunch |

---

## 4. Tombstones (delete propagation)

| Step | Pass criteria |
|------|----------------|
| Delete dive on iPhone | Does not reappear on Watch after sync |
| Delete dive on Watch | Removed or tombstoned on iPhone |

---

## 5. Units application context

| Step | Pass criteria |
|------|----------------|
| Set **metric** on iPhone units | Watch Live/Log depth display uses metric when paired |
| Set **imperial** on iPhone | Watch depth display uses feet where implemented |
| Change language on Watch only | Language local; units still follow sync rules |

Note: CSV export remains metric/Subsurface by design.

---

## 6. Pairing secret (first run)

| Step | Pass criteria |
|------|----------------|
| Fresh install iOS + Watch | Pairing/trust flow completes |
| **Reset Watch pairing trust** in More | Requires re-pairing; push works again after trust restored |

---

## Sign-off

- [ ] Sections 1–6 executed on hardware
- [ ] Failures logged with device models and iOS/watchOS versions

Related: [`INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md) Phase 3
