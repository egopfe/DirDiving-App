# App Intents — on-device QA checklist (MAIN)

**Date:** 2026-05-24  
**Branch:** `main`  
**Targets:** DIRDiving Watch App only (intents run on Watch)  
**Purpose:** Verify each published App Intent on **physical Apple Watch** with watchOS Shortcuts / Action Button mapping configured by the tester.

---

## Important constraints (by design)

- DIR DIVING exposes **App Intents**; it does **not** intercept the Apple Watch **Side Button** directly.
- **Action Button** (Ultra) and **Shortcuts** must be configured by the user in **watchOS Settings → Action Button** or the **Shortcuts** app.
- The app cannot force a Side Button mapping; on-screen controls on **Live** remain the reliable primary path.

Reference implementation: `Services/ActionButtonIntents.swift`

---

## Preconditions

- [ ] Watch and iPhone paired; DIR DIVING Watch app installed from Xcode or TestFlight.
- [ ] At least one intent visible in Shortcuts when searching **DIR DIVING** (or app name).
- [ ] For Action Button tests: user has assigned a DIR DIVING intent in system settings.

---

## Intent matrix

| Intent | Suggested trigger | Pass criteria |
|--------|-------------------|---------------|
| Toggle stopwatch | Shortcut / Action Button | Stopwatch state on Live toggles start/stop without opening another app |
| Reset stopwatch | Shortcut / Action Button | Stopwatch returns to zero **immediately** (use intentionally) |
| Start manual dive | Shortcut | Manual dive session starts; Live shows active dive UI |
| End manual dive | Shortcut | Manual dive ends; log entry created or session cleared per current behavior |
| Set bearing | Shortcut | Saved bearing set; compass/toast reflects change |
| Clear bearing | Shortcut | Saved bearing cleared |
| Acknowledge alarm | Shortcut | Active depth/time/battery banner on Live dismisses when alarm shown |

---

## Test procedure (per intent)

1. Open **Live** (or Compass for bearing intents) and note baseline UI state.
2. Run intent from **Shortcuts** (tap run) or trigger **Action Button** if mapped.
3. Confirm UI/state change matches table above within ~2 s.
4. Repeat once after ending any active dive (surface state).

---

## Failure logging template

```markdown
- Intent:
- watchOS version:
- Watch model:
- Trigger: Shortcut / Action Button / other
- Expected:
- Actual:
- Screenshot or screen recording:
```

---

## Sign-off

- [ ] All seven intents exercised on hardware at least once
- [ ] No crash when invoking intents during active dive
- [ ] Side Button **not** expected to work without user Shortcuts mapping (document if tester assumed otherwise)

Related: [`INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md) · [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md)
