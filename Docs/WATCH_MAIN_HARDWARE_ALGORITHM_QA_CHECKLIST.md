# Apple Watch MAIN — Hardware Algorithm QA Checklist

**Purpose:** Physical validation of dive algorithms and sensors on real Apple Watch Ultra hardware.  
**Status:** Template — **not completed** until signed rows exist below.  
**Target:** `DIRDiving Watch App` (Watch MAIN) only  
**Note:** watchOS Simulator does **not** prove underwater CoreMotion depth, entitlement behavior, or real GPS fixes.

---

## A. Depth sensor / CoreMotion

| # | Check | Pass | Fail | N/A | Notes |
|---|--------|:----:|:----:|:---:|-------|
| A1 | Submersion entitlement active on device build | ☐ | ☐ | ☐ | |
| A2 | Depth callback delivers readings in water | ☐ | ☐ | ☐ | |
| A3 | Automatic start at **> 1.0 m** (not on first sample alone) | ☐ | ☐ | ☐ | |
| A4 | Two-sample debounce before auto start | ☐ | ☐ | ☐ | |
| A5 | Stale-depth banner after **8 s** without accepted callback during active dive | ☐ | ☐ | ☐ | |
| A6 | Frozen-depth rejection (sensor stuck ~same depth ≥ 30 s) | ☐ | ☐ | ☐ | |
| A7 | Spike rejection on implausible depth jump | ☐ | ☐ | ☐ | |

## B. Dive lifecycle

| # | Check | Pass | Fail | N/A | Notes |
|---|--------|:----:|:----:|:---:|-------|
| B1 | Automatic dive start in water | ☐ | ☐ | ☐ | |
| B2 | Manual dive start (no duplicate session) | ☐ | ☐ | ☐ | |
| B3 | Automatic end at **≤ 0.3 m** for **≥ 8 s** surface dwell | ☐ | ☐ | ☐ | |
| B4 | Relaunch restores active draft without duplicate finalize | ☐ | ☐ | ☐ | |
| B5 | No duplicate logbook entry on single dive | ☐ | ☐ | ☐ | |

## C. GPS

| # | Check | Pass | Fail | N/A | Notes |
|---|--------|:----:|:----:|:---:|-------|
| C1 | Entry fix captured at dive start (or documented fallback) | ☐ | ☐ | ☐ | |
| C2 | Exit fix captured at dive end | ☐ | ☐ | ☐ | |
| C3 | Last-known fallback when fresh fix unavailable | ☐ | ☐ | ☐ | |
| C4 | No-fix warning presentation (red/warning) | ☐ | ☐ | ☐ | |

## D. Alarms / haptics

| # | Check | Pass | Fail | N/A | Notes |
|---|--------|:----:|:----:|:---:|-------|
| D1 | Ascent over-limit alarm + haptic (if enabled) | ☐ | ☐ | ☐ | |
| D2 | Depth safety **35 / 38 / 40 m** states and haptics | ☐ | ☐ | ☐ | |
| D3 | Runtime alarm (if enabled) | ☐ | ☐ | ☐ | |
| D4 | Battery alarm (if enabled) | ☐ | ☐ | ☐ | |
| D5 | Haptics disabled → no unwanted pulses | ☐ | ☐ | ☐ | |
| D6 | Re-enable haptics while still over limit → pulses resume | ☐ | ☐ | ☐ | |

## E. Export / sync

| # | Check | Pass | Fail | N/A | Notes |
|---|--------|:----:|:----:|:---:|-------|
| E1 | Normal profile Subsurface CSV export | ☐ | ☐ | ☐ | |
| E2 | Manual no-depth session: sync allowed, export disabled | ☐ | ☐ | ☐ | |
| E3 | Watch → iPhone signed sync | ☐ | ☐ | ☐ | |
| E4 | Tombstone / delete propagation | ☐ | ☐ | ☐ | |

## F. Mission Mode invariant

| # | Check | Pass | Fail | N/A | Notes |
|---|--------|:----:|:----:|:---:|-------|
| F1 | Mission Mode **ON** vs **OFF**: same depth samples / TTV / ascent / alarms | ☐ | ☐ | ☐ | |
| F2 | Only UI / decorative / animation profile changes | ☐ | ☐ | ☐ | |

## G. Evidence capture (per test session)

| Field | Value |
|-------|--------|
| Date | |
| Tester | |
| Device model | e.g. Apple Watch Ultra 2 |
| watchOS version | |
| App build (CFBundleVersion) | |
| Entitlement / depth API | Available / unavailable |
| Water type | Pool / open water |
| Overall result | Pass / Fail / Partial |
| Notes | |

---

**Product reminders (do not change during QA):**

- DIR DIVING is a **non-certified informational** diving companion, **not** a certified dive computer.
- No NDL / TTS / decompression claims.
- TTV = informational index (`average depth + runtime minutes`).
- Mission Mode must **not** affect depth, GPS, alarm, haptic, or math behavior.
