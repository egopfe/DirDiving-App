# TestFlight & device QA — MAIN branch blockers (external)

**Date:** 2026-05-25
**Branch:** `main`  
**Purpose:** Track items that **cannot** be closed in code alone. Do **not** mark complete until performed on real hardware / Apple Developer.

---

## 1. Apple Developer — Water Submersion entitlement

| Item | Value |
|------|--------|
| Watch bundle ID | `com.egopfe.dirdiving.ios.watch` |
| iOS bundle ID | `com.egopfe.dirdiving.ios` |
| Entitlement key | `com.apple.developer.coremotion.water-submersion` |
| Reference in repo | `Config/DIRDiving.entitlements` |

**Steps (human):**

1. [Apple Developer](https://developer.apple.com) → Identifiers → **App ID** `com.egopfe.dirdiving.ios.watch`.
2. Enable **Water Submersion** (or equivalent capability name in portal).
3. Regenerate provisioning profiles for Watch + iOS embedded pair.
4. In Xcode: **Signing & Capabilities** on **DIRDiving Watch App** — confirm capability present, no signing errors.
5. Archive Watch + iOS; install on **physical Apple Watch Ultra** (depth automation target).

**Validation criteria (device only):**

- [ ] Submersion session starts without `lastErrorMessage` entitlement denial.
- [ ] Depth readout updates underwater (not only manual dive).
- [ ] Depth safety banners 35 / 38 / 40 m behave per [`DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md`](DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md).

**Not validated in CI/simulator:** automatic depth from submersion API.

---

## 2. Physical Watch ↔ iPhone sync QA

| Check | Pass criteria |
|-------|----------------|
| Pairing | iOS **More → Sync Watch** shows supported + activated |
| Watch → iPhone | New dive on Watch appears in iOS logbook after sync |
| iPhone → Watch | `syncUnpushedSessionsToWatch` delivers sessions to Watch log |
| Conflict | Duplicate edit surfaces conflict card; resolution persists |
| Offline | Airplane mode dive on Watch; sync completes when both online |
| Tombstone | Delete on one side respects tombstone on other (playbook Phase 3) |

Playbook: [`INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md)  
Detailed checklist: [`WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md)

---

## 2b. App Intents (Watch hardware)

| Check | Pass criteria |
|-------|----------------|
| Shortcuts visibility | DIR DIVING intents listed in watchOS Shortcuts |
| Toggle / reset stopwatch | Live stopwatch responds |
| Manual dive start/end | Session state changes on Live |
| Bearing set/clear | Compass bearing updates |
| Acknowledge alarm | Banner dismisses when alarm active |
| Action Button | User-mapped intent runs (app cannot bind Side Button directly) |

Checklist: [`APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md)

---

## 3. TestFlight internal QA (minimum)

- [ ] Legal onboarding (depth-limits checkbox) on fresh install — Watch + iOS.
- [ ] CSV import from **Logbook** and **More** with non-empty logbook.
- [ ] Export latest dive CSV on Watch; open in iOS / Subsurface.
- [ ] Planner: mode labels honest; result tabs switch content.
- [ ] Ascent alarm + acknowledge on Watch (reference: `Docs/ReferenceUI/` ascent mockup).
- [ ] English UI: no obvious Italian in primary flows (Settings, Live manual, More, Planner).

---

## 4. App Store (still blocked after TestFlight)

- Store listing, screenshots, privacy nutrition labels.
- Field proof of depth limits + legal copy review.
- Marketing claims aligned with **NOT A DIVE COMPUTER**.

---

*This checklist does not assert entitlement approval or underwater validation unless checkboxes are signed by a tester with date and device model.*
