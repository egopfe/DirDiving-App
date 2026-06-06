# Apple Watch MAIN — Hardware Algorithm QA Checklist

**Updated:** 2026-06-06  
**Target:** `DIRDiving Watch App` (MAIN only)  
**Baseline:** Post-remediation per [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md)  
**Purpose:** Physical gates that cannot be satisfied by simulator, unit tests, or static analysis alone.

---

## Prerequisites

- [ ] Apple Watch **Ultra** with approved **water submersion** entitlement on App ID `com.egopfe.dirdiving.ios.watch`
- [ ] Paired iPhone with matching TestFlight / debug build
- [ ] Legal acceptance completed on Watch (App Intents gate)
- [ ] Haptics enabled in Watch Settings unless testing disabled path

---

## 1. Depth entitlement and automation

| # | Check | Pass | Notes |
|---:|---|:---:|---|
| 1.1 | Automatic depth on Ultra: submerge past 1 m → dive starts after 2-sample debounce | ☐ | |
| 1.2 | Surface dwell 0.3 m / 8 s → dive ends automatically | ☐ | |
| 1.3 | Manual Start Dive on surface → session begins; submersion handoff note visible | ☐ | WATCH-UX-001 copy |
| 1.4 | Manual end control hidden after handoff; auto surface-end completes session | ☐ | |
| 1.5 | Non-Ultra or missing entitlement → **fallback badge** visible (not silent mock) | ☐ | WATCH-S2-002 |
| 1.6 | Explicit simulation mode → simulation badge distinct from fallback | ☐ | |
| 1.7 | Mock/sim stable 0 m during simulation → **no** false frozen-depth scare | ☐ | WATCH-S2-001 |
| 1.8 | Real dive: unchanged depth > 30 s at depth → frozen/stale warning as designed | ☐ | |
| 1.9 | Callback silence beyond stale threshold → depth-not-updating banner | ☐ | |

---

## 2. Safety thresholds (35 / 38 / 40 m)

| # | Check | Pass | Notes |
|---:|---|:---:|---|
| 2.1 | Exactly **40.0 m** → safety exceeded; ascent band per current policy | ☐ | WATCH-S7-001 intentional |
| 2.2 | **40.01 m** → exceeded + deeper fallback ascent if applicable | ☐ | |
| 2.3 | 38 m critical haptic + delayed secondary pulse | ☐ | WATCH-S15-002 |
| 2.4 | Disable haptics mid-delay → no secondary pulse | ☐ | |
| 2.5 | Re-enable haptics → no stale replay; new warnings per throttle | ☐ | |

---

## 3. GPS lifecycle

| # | Check | Pass | Notes |
|---:|---|:---:|---|
| 3.1 | Entry GPS captured on dive start (green / yellow / red semantics) | ☐ | |
| 3.2 | Exit GPS on dive end | ☐ | |
| 3.3 | Grant location permission **after** dive ended → GPS does **not** restart | ☐ | WATCH-GPS-001 |
| 3.4 | Grant permission during active capture → updates continue | ☐ | |

---

## 4. Lifecycle / draft recovery

| # | Check | Pass | Notes |
|---:|---|:---:|---|
| 4.1 | Kill app during active dive → restore on relaunch | ☐ | |
| 4.2 | Kill during GPS finalization → session completes, no active restore | ☐ | |
| 4.3 | Info shows diagnostic if corrupt finalizing draft detected | ☐ | WATCH-LC-002 |

---

## 5. TTV and Mission Mode

| # | Check | Pass | Notes |
|---:|---|:---:|---|
| 5.1 | TTV displayed as informational (not NDL/TTS/deco) | ☐ | WATCH-TTV-001 |
| 5.2 | Mission Mode: reduced animation only; depth/TTV math identical | ☐ | |
| 5.3 | No OTU/CNS on Watch UI | ☐ | |

---

## 6. Sync and export

| # | Check | Pass | Notes |
|---:|---|:---:|---|
| 6.1 | Watch dive → sync to iPhone | ☐ | |
| 6.2 | Delete on iPhone → no resurrection on Watch | ☐ | |
| 6.3 | CSV export from Watch → Subsurface-compatible columns | ☐ | [`WATCH_CSV_EXPORT_POLICY.md`](WATCH_CSV_EXPORT_POLICY.md) |
| 6.4 | Manual no-depth session: sync badge; export blocked | ☐ | |

---

## 7. App Intents / Action Button

| # | Check | Pass | Notes |
|---:|---|:---:|---|
| 7.1 | Shortcuts blocked until legal acceptance | ☐ | |
| 7.2 | Post-acceptance: Start Dive / Compass intents execute | ☐ | |

---

## Evidence

Record device model, watchOS version, build number, date, and pass/fail per row. Attach screenshots or screen recordings for fallback badge, frozen-warning absence in simulation, and GPS color semantics.

**Related matrices:** [`WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`](WATCH_ULTRA_PHYSICAL_QA_MATRIX.md), [`WATCH_IOS_SYNC_QA_MATRIX.md`](WATCH_IOS_SYNC_QA_MATRIX.md)
