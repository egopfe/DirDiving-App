# Apple Watch MAIN — Algorithm & Mathematical Functions Audit (Current)

**Date:** 2026-06-01  
**Branch:** `main` @ `3154719`  
**Target:** `DIRDiving Watch App` only  
**Mode:** Read-only static audit (no code changes)  
**Related:** [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) (remediation @ `ac47480`), [`WATCH_MISSION_MODE_UX_SAFETY_VERIFICATION_REPORT.md`](WATCH_MISSION_MODE_UX_SAFETY_VERIFICATION_REPORT.md) (Mission Mode is **UI-only**, not dive math)

---

## A. Executive Summary

| Metric | Estimate | Notes |
|--------|----------|--------|
| **Watch MAIN algorithm readiness** | **~88%** | Core math centralized in `DiveAlgorithm` + validators; strong unit tests; hardware QA still required |
| **Mathematical robustness** | **~90%** | Sanitization, finite checks, caps on ascent rate and depth; time-weighted average well defined |
| **Safety algorithm confidence** | **~86%** | Depth 35/38/40 m, ascent bands, alarms, stale-depth watchdog present; one duplicate-sample path on auto-start |
| **TestFlight (algorithm)** | **Ready with caveats** | Prior HIGH blockers addressed in code; validate on Ultra hardware |
| **App Store (algorithm)** | **Ready with caveats** | Non-certified positioning preserved; physical validation mandatory |

### Critical blockers (algorithm)

**None at CRITICAL severity** for a non-certified companion app with existing disclaimers.

### TestFlight algorithm blockers

| ID | Severity | Topic |
|----|----------|--------|
| WMATH-MED-015 | MEDIUM | Duplicate `addSample` on automatic dive start may reject second identical-timestamp sample and surface spurious depth error |
| — | Process | Apple Watch Ultra underwater CoreMotion + GPS + WC sync not replaceable by simulator |

### App Store algorithm blockers

- Same as TestFlight process blockers  
- Marketing must not claim certified dive-computer / NDL / TTS behavior  
- TTV must remain described as informational index (`avgDepth + runtimeMinutes`)

### Quick answers (product rule)

| Domain | Affected by algorithms? |
|--------|-------------------------|
| Depth sampling / display meaning | Core pipeline in `DiveManager` + `DepthSampleValidation` — **not** Mission Mode |
| Ascent / alarms / haptics | **Independent** of Mission Mode |
| GPS / sync / export | Metric storage internal; display may be imperial |
| TTV | `DiveAlgorithm.ttvIndex` — **not** decompression |

---

## B. Scope Confirmation

### Phase 0 — Preflight

| Check | Result |
|-------|--------|
| Branch | `main` |
| `git status` | Clean @ audit time (`3154719`) |
| Watch target | `DIRDiving Watch App` |
| Experimental excluded | Yes (`project.yml` lines 15–34) |
| iOS | Inspected only for shared `DiveSession` / sync codec compatibility |

### Watch MAIN algorithm source map (core)

| Layer | Primary files |
|-------|----------------|
| Configuration | `Utils/DiveAlgorithmConfiguration.swift` |
| Pure math | `Utils/DiveAlgorithm.swift` (in same file as configuration) |
| Validation | `Utils/DepthSampleValidation.swift` |
| Lifecycle | `Utils/DiveLifecycleAlgorithm.swift` |
| Depth safety | `Utils/DepthSafetyConfiguration.swift` |
| Runtime clock | `Utils/MonotonicElapsedClock.swift` |
| Orchestration | `Services/DiveManager.swift` |
| Ascent limits | `Models/AscentRateLimits.swift`, `Models/AscentStatus.swift`, `Services/AscentRateSettingsStore.swift` |
| Haptics | `Services/HapticService.swift`, `Services/AscentSafetyHapticCoordinator.swift`, `Services/DepthLimitHapticCoordinator.swift` |
| GPS | `Services/GPSManager.swift`, `Utils/GPSFallbackPolicy.swift` (in `GPSManager.swift`) |
| Compass | `Services/CompassManager.swift`, `DiveAlgorithm.normalizedDegrees` |
| Persistence | `Services/DiveLogStore.swift`, `Models/DiveSession.swift` |
| Sync | `Services/WatchDiveSyncCodec.swift`, `Utils/DiveSessionMerge.swift`, `Utils/DiveSessionAlgorithmValidator.swift` |
| Export | `Services/SubsurfaceExportService.swift` |
| Units / display | `Utils/DIRUnitConversions.swift`, `Utils/DIRUnitPreference.swift`, `Utils/WatchDepthFormatting.swift`, `Utils/Formatters.swift` |
| UI (displays math) | `Views/DiveLiveView.swift`, `Views/AscentGaugeView.swift`, `Views/DepthSafetyLiveViews.swift`, `Views/AlarmSettingsView.swift` |
| Tests | `Tests/WatchAlgorithmTests/*.swift` |

**Mission Mode** (`Utils/MissionModeRuntimeProfile.swift`, `DiveManager` lifecycle flags): **excluded from algorithm inventory** — verified UI/runtime only; does not alter formulas (see Mission Mode UX audit).

---

## C. Algorithm Inventory (by family)

### 1. Depth sensor / underwater state

| Symbol | File | Inputs | Outputs | Units | Thresholds / assumptions |
|--------|------|--------|---------|-------|---------------------------|
| `sanitizedDepthMeters` | `DiveAlgorithm` | Raw depth | m or nil | m | ≥0, ≤350, finite |
| `DepthSampleValidationState.validate` | `DepthSampleValidation.swift` | Raw depth, timestamps | `ValidatedDepthSample` | m, s | Stale ±8s skew; frozen 30s @ 0.001m; spike 90 m/min |
| `processDepthMeasurement` | `DiveManager` | CoreMotion depth (m), temp | Live depth, samples | m, °C | Uses entitlement `CMWaterSubmersionManager` |
| Submersion delegate | `DiveManager` | `CMWaterSubmersionEvent` | Manual/auto lifecycle hints | — | Submerged clears manual-only surface end block |

**Persistence:** Samples in memory + `ActiveDiveDraft` JSON.  
**Safety:** High — gates all dive math.

### 2. Dive lifecycle

| Symbol | File | Behavior |
|--------|------|----------|
| `DiveLifecycleAlgorithm.evaluate` | `DiveLifecycleAlgorithm.swift` | Start: depth > **1.0 m**, **2** consecutive samples; stop: ≤ **0.3 m** for **8 s** dwell |
| `beginDiveIfNeeded` / `endDiveIfNeeded` | `DiveManager.swift` | Guards duplicate start (`!isDiveActive`, `!isFinalizingDive`); GPS 6s best-effort capture |
| Manual lifecycle | `DiveManager` | `startManualDive`; auto-end blocked until submersion observed if manual |

**Assumptions:** Validated samples only; manual no-depth when sensor unavailable (`isManualNoDepthSession`).

### 3. Time / runtime / stopwatch

| Symbol | File | Behavior |
|--------|------|----------|
| `MonotonicElapsedClock.elapsed` | `MonotonicElapsedClock.swift` | Blends wall clock + `systemUptime`; forward skew cap 120s; non-decreasing |
| `updateRuntimeFromClock` | `DiveManager` | 1 Hz timer; updates `runtime`, `ttv`, alarms |
| Stopwatch | `DiveManager` | Separate `stopwatchClock`; persisted UserDefaults |

### 4. Depth statistics

| Symbol | Formula | Notes |
|--------|---------|-------|
| `timeWeightedAverageDepth` | Σ(depth×Δt)/ΣΔt | Tail to `endDate` on finalize; empty→0 |
| `maxDepthMeters` | max(samples) | Live + session |
| `currentDepthMeters` | Last accepted sample | Stale flag if no callback >8s |

### 5. Ascent rate

| Symbol | Formula | Notes |
|--------|---------|-------|
| `ascentRateMetersPerMinute` | max(0, (refDepth−currentDepth)/Δt×60) | 5s window; min Δt **1s**; cap **90 m/min**; **descent → 0** |
| `AscentRateLimits.limit(for:)` | Depth bands | 40–30:10; 30–20:5; 20–6:3; 0–6:1; >40: min(surface,fallback) |

### 6. Ascent gauge / zones

| Symbol | Behavior |
|--------|----------|
| `AscentStatus.zone` | Green ≤70% limit; yellow ≤100%; red > limit |
| `AscentGaugeView.pointerOffset` | rate/limit clamped 0…1 |
| Display | Imperial via `DIRUnitPreference.ascentRateDisplay` |

### 7. Alarms

| Alarm | Default (UI / engine) | Threshold | Cooldown |
|-------|----------------------|-------------|----------|
| Ascent | ON / ON | Zone red + `ascentAlarmEnabled` | Haptic repeat **1.75s** |
| Depth | OFF / OFF | max depth > stored m (default **40**) | 30s between triggers |
| Runtime | OFF / OFF | runtime > stored min (default **30**) | 30s |
| Battery | ON / ON | level < stored % (default **20**) | 30s |
| Acknowledge | — | Suppresses new alarms **15s** | — |
| Blink | — | 0.45s timer; sources: ascent/depth/runtime/battery | Independent sets |

### 8. Depth safety limits

| Depth (m) | State |
|-----------|--------|
| < 35 | normal |
| ≥ 35 | caution |
| ≥ 38 | critical |
| ≥ 40 | exceeded |

Haptics: caution 30s; critical 15s; exceeded 10s (`DepthLimitHapticCoordinator`).  
`exceeded` suppresses positive depth reinforcement in UI (`DepthSafetyState.suppressesPositiveDepthReinforcement`).

### 9. TTV / live metric

| Symbol | Formula |
|--------|---------|
| `ttvIndex` | `max(0, avgDepthM) + max(0, durationSeconds/60)` |

**Semantics:** Informational load index — **not** NDL/TTS/deco. Live `ttv` recomputed each second from live average + runtime.

### 10. Compass / bearing

| Symbol | Behavior |
|--------|----------|
| Heading | `trueHeading` if ≥0 else `magneticHeading`; normalized 0…360 |
| `setBearing` | Stores normalized heading as bearing |
| Cardinal | 8-point from heading+22.5° |

### 11. GPS entry/exit

| Symbol | Behavior |
|--------|----------|
| `GPSFallbackPolicy.assess` | Age ≤300s; accuracy ≤50m; valid lat/lon |
| Capture | 6s best-effort window; fix vs fallback vs noFix sources |
| UI | `.fix` green; `.fallback` yellow; `.noFix` **red** (`DiveLiveView` + `GPSConfirmationPresentation`) |

### 12. Unit conversion / formatting

| API | Storage | Display |
|-----|---------|---------|
| `DIRUnitConversions` | — | m↔ft, °C↔°F, m/min↔ft/min |
| `WatchDepthFormatting` | meters | `Formatters.one` + unit label |
| Export CSV | **meters** | `%.2f` depth, `%.1f` temp |

### 13. Haptic timing

| Service | Throttle |
|---------|----------|
| `warnIfNeeded` | 2s |
| Ascent repeat | 1.75s |
| Depth limit | 30/15/10s by state |
| Buddy pulses | 8s / 12s (not Watch MAIN dive path) |

### 14–16. Export / sync / persistence

| Path | Behavior |
|------|----------|
| `finalizeDive` | Recomputes avg/max/ttv from sanitized samples |
| `SubsurfaceExportService` | `time_seconds` = sample−`startDate`; requires non-empty exportable samples |
| `WatchDiveSyncCodec` | Validates session; max 20k samples, 350m, signed payload |
| `DiveSessionPersistenceClass` | Manual no-depth: sync allowed, export disabled (policy) |
| Draft restore | 12h expiration; restores samples + `applyMissionMode` (UI only) |

---

## D. Findings by Family

### Resolved HIGH (verified in code @ `3154719`)

| ID | Title | Status | Evidence |
|----|-------|--------|----------|
| WMATH-HIGH-001 | Depth callback silence watchdog | **Fixed** | `evaluateDepthCallbackFreshness()` in `updateRuntimeFromClock`; `isDepthDataStale`, `depthStaleBanner` |
| WMATH-HIGH-002 | GPS no-fix green success | **Fixed** | `gpsConfirmationColor`: `.noFix` → `DiveUI.red`; localized no-fix titles |
| WMATH-HIGH-003 | Manual/no-depth sync rejection | **Fixed** | `DiveSession.isManual` + `hasDepthProfile`; validator allows empty samples when manual; `WatchReadinessAlgorithmTests` |

### Open / new findings

| ID | Sev | Family | Location | Title | Safety | Proposed fix | Impact |
|----|-----|--------|----------|-------|--------|--------------|--------|
| WMATH-MED-015 | MED | Depth pipeline | `DiveManager.processDepthMeasurement` | Duplicate `addSample` on auto dive start | Low — second call likely **rejected** (`deltaTime==0`); may flash error string | Remove unconditional trailing `addSample` or `return` after start branch | Small functional |
| WMATH-LOW-016 | LOW | Depth input | `didUpdate measurement` | Temperature not passed into depth measurement path | Low — depth samples may lack contemporaneous temp | Pass sanitized temp from measurement when available | Small functional |
| WMATH-LOW-017 | LOW | Ascent UI | `AscentGaugeView` | Gauge keeps SwiftUI animation when Mission Mode disables Live animations | None | INFO — gauge animation independent by design | UI-only |
| WMATH-INFO-018 | INFO | Mission Mode | `DiveLiveView` | Mission Mode disables blink/banner **animations** only | Low visual | Documented in UX audit; optional keep blink animation when alarms active | UI-only |
| WMATH-INFO-019 | INFO | Product | TTV copy | TTV is not deco | N/A | Maintain disclaimers in legal/README | Copy-only |
| WMATH-INFO-020 | INFO | Ascent bands | `AscentRateLimits` | At exactly 40.0 m, limit 10 m/min; >40 uses 1 m/min | By design | Document boundary table (already in code comments) | INFO |

No **CRITICAL** or unfixed **HIGH** algorithm issues identified in static review.

---

## E. Phase Reports (PASS/FAIL)

### Phase 2 — Depth sensor / underwater (PASS)

| Check | Result |
|-------|--------|
| Units from API | `measurement.depth?.converted(to: .meters)` |
| Sign | Negative raw clamped to 0 in validation |
| nil/NaN/out of range | Rejected with validity enum |
| Simulator / manual | `isDepthAutomationAvailable`; manual no-depth session |
| Start/stop thresholds | 1.0 m ×2 samples; 0.3 m ×8 s |

**Risk:** MED-015 spurious error on first callback after start.

### Phase 3 — Dive lifecycle (PASS)

Duplicate session prevented; `isFinalizingDive` gate; draft restore; submersion unblocks manual auto-end.

### Phase 4 — Time / runtime / stopwatch (PASS)

Monotonic clock tested; 1s runtime timer; stopwatch independent.

### Phase 5 — Depth statistics (PASS)

Time-weighted average matches tests; finalize uses same `DiveAlgorithm` paths as live.

### Phase 6 — Ascent rate / gauge (PASS)

Positive ascent only; imperial display via preference; zone boundaries unit-tested.

### Phase 7 — Alarm logic (PASS)

Defaults: ascent/battery ON in UI; depth/runtime OFF — matches engine nil-coalescing for ascent/battery. Settings keys used in `DiveManager`.

### Phase 8 — Depth safety (PASS)

35/38/40 thresholds tested; exceeded flag persisted on session; max depth cards hidden when exceeded (UI policy).

### Phase 9 — TTV (PASS)

Formula consistent live and finalize; not presented as NDL in algorithm layer.

### Phase 10 — Compass (PASS)

Normalization and bearing delta in `DiveAlgorithm`; true heading preferred.

### Phase 11 — GPS (PASS)

No-fix red; fallback yellow; 6s capture; coordinates validated before store.

### Phase 12 — Units (PASS)

Internal metric; Live/Log/Gauge use `DIRUnitPreference`; export metric by design.

### Phase 13 — Haptics (PASS)

Global toggle respected; ascent repeat decoupled from generic warn throttle; depth coordinator re-checks preference on delayed pulses.

### Phase 14 — Export / sync (PASS)

CSV uses sanitized samples; sync validator aligned with manual no-depth policy; merge recomputes ttv/avg.

---

## F. Edge Case Matrix (selected)

| Edge case | Expected (code) | Tested? |
|-----------|-----------------|---------|
| depth nil | Reject `.missing` | Unit yes |
| depth NaN | `.nonFinite` | Unit yes |
| depth < 0 | Clamped to 0 | Unit yes |
| start 0.9 m | No start | Unit yes |
| start 1.1 m ×2 | Start dive | Unit yes |
| spike 10→30 in 1s | `.spikeRejected` | Unit yes |
| frozen 30s | `.frozen` | Unit yes |
| sensor silent 8s+ active dive | Stale banner | Unit threshold; runtime manual QA |
| auto start double addSample | 2nd rejected | **Not tested** — MED-015 |
| TTV at 0 depth | avg+0 | Partial |
| ascent descent | rate 0 | Unit yes |
| GPS no fix | Red banner | Unit presentation |
| manual no-depth sync | Allowed | `WatchReadinessAlgorithmTests` |
| draft >12h | Discarded | Code only |
| Mission Mode on | Math unchanged | UX audit |

---

## G. Unit / Integration Test Plan (add — audit does not implement)

| Priority | Test | Input | Expected |
|----------|------|-------|----------|
| P0 | Auto-start single sample | One valid start sample after lifecycle | Exactly **1** sample in array; no error message |
| P0 | Stale depth 8s | Active dive, no callbacks | `isDepthDataStale == true` |
| P1 | Runtime monotonic | Clock skew simulation | Non-decreasing runtime |
| P1 | finalize vs live TTV | End dive | Session TTV == formula(avg, duration) |
| P1 | GPS presentation | nil/fix/fallback | Colors map fix/fallback/noFix |
| P2 | Alarm threshold boundary | depth 40.0 vs 40.01 | Alarm only when enabled and >threshold |
| P2 | Sync round-trip | Manual no-depth session | Codec encode/decode succeeds |
| P2 | Export time_seconds | Known samples | Seconds from startDate |

Existing coverage: `DiveAlgorithmTests`, `WatchReadinessAlgorithmTests`, `MissionModeTests` (lifecycle only), `UserImageStorePolicyTests`.

---

## H. Physical Watch Ultra Test Plan

1. Automatic dive start at ~1–2 m — verify runtime, TTV, samples in log.  
2. Surface 8+ s — auto end; exit GPS banner color truthful.  
3. Fast ascent — red zone, inline banner, haptic cadence ~1.75s (haptics ON).  
4. Depth 35/38/40 m — caution/critical/exceeded visuals + depth haptics.  
5. Kill app mid-dive — draft restore; depth/TDV continuity.  
6. Manual start on simulator/no sensor — no-depth session; sync to iPhone.  
7. Imperial mode — Live depth ft, gauge ft/min, export still metric.  
8. Mission Mode ON — confirm depth/ascent/GPS unchanged (UX audit).  
9. Background 2+ min — runtime monotonic; stale depth if callbacks stop.

---

## I. Underwater Validation Plan

- Shallow pool: start/stop thresholds, ascent gauge stability.  
- 30–40 m profile (if site permits): depth safety transitions only within supported API range; **not** certification.  
- Compare max/avg depth vs reference device — informational only.  
- GPS at surface entry/exit — expect no underwater fix.  
- Document callback rate vs battery.

---

## J. Prioritized Roadmap

### 1. Must fix before compile/use

None identified (project builds).

### 2. Must fix before internal TestFlight

- WMATH-MED-015 duplicate `addSample` on auto start (avoid spurious error / sample confusion)

### 3. Must fix before external TestFlight

- Complete Ultra test plan §H  
- Confirm stale-depth banner underwater

### 4. Must fix before App Store

- Evidence log for HIGH fixes + manual/no-depth sync  
- Legal copy for TTV and depth limits unchanged

### 5. Post-release

- WMATH-LOW-016 temperature on depth callback  
- Integration tests for `DiveManager` orchestration  
- Optional Mission Mode: preserve alarm blink animation (UX)

---

## K. Final Verdict

| Question | Answer |
|----------|--------|
| **Mathematically ready?** | **Yes** for defined non-certified semantics, ~88–90% static confidence |
| **Safe enough for internal test?** | **Yes**, after fixing or accepting MED-015 and completing device QA |
| **Ready for TestFlight?** | **Yes with caveats** (hardware + MED-015) |
| **Ready for App Store?** | **Yes with caveats** (physical validation + copy discipline) |
| **Blocks 100% algorithmic readiness?** | Hardware QA; MED-015; broader `DiveManager` integration tests; entitlement-dependent depth on real water |

### Domain checklist

| Domain | Affected by Mission Mode? | Algorithm verdict |
|--------|----------------------------|-------------------|
| Depth sampling/display | No | PASS |
| Ascent/alarms/haptics | No | PASS |
| GPS/logging/sync/export | No | PASS |
| TTV semantics | No | PASS (informational index) |

---

*End of audit. No source files were modified.*
