# UI/UX Gap Remediation Plan — Current

**Baseline:** `main` @ `6cbba649` · planning only · no fixes applied

## Immediate P0

### 1. Make Full Computer environment explicit and fail closed

Preserve the signed `DivePlanEnvironmentPayload` through Watch activation into a confirmed predive configuration and `FullComputerRuntimePlan`. Remove implicit `.seaLevelSaltWater` defaults from live safety paths. Validate altitude/salinity and freeze environment at dive start. Display altitude, surface pressure, salinity, source, and fallback/compatibility status on imported-plan and predive confirmation surfaces. Reject unsupported or corrupt environment data.

Acceptance requires:

- identical environment in iOS package, Watch activation, live engine, checkpoint, restore, logbook, sync, and export;
- no live start without an explicit validated snapshot;
- independent 16 N2/He altitude suites at 0/500/1,000/1,500/2,000/4,500 m plus invalid values;
- Air, Nitrox, Trimix, fresh/salt, gas switch, deco clear, re-descent, and restore;
- accessible/localized UI for environment and blocking state.

Rerun audits 0, 0W, 01W, 1, 2, 3, 4, 8, 11, 12, 13, 15, and 16.

## P1 before internal TestFlight

1. Add Watch altitude-aware independent oracle/profile tests; do not reuse production pressure conversion in the oracle.
2. Extend Full Computer logbook metadata/schema with frozen altitude, surface pressure, salinity, density, source, and confidence/fallback state; validate migration and round trips.
3. Run XcodeGen, both app builds, both full algorithm suites, focused altitude/Audit 15 suites, and all readiness scripts on macOS at the remediation commit.
4. Complete physical Watch Ultra depth-entitlement, Water Lock, wet/glove, combined banner, sensor degradation, recovery, and battery/thermal QA.
5. Complete paired Watch/iPhone trust, sync, conflict, large payload, retry, and activity-isolation QA.
6. Complete VoiceOver, Dynamic Type, PDF rendering, iOS device matrix, and physical screenshot evidence.

## P2 before external TestFlight

1. Normalize validation-script paths with POSIX separators before exclusions/allowlists; add Windows/macOS scanner tests.
2. Explicitly mark or archive historical `Docs/README.md`/`Docs/INDEX.md` sections that contradict current multi-activity scope.
3. Populate manual visual fidelity scores and 41/45/49 mm plus supported-iPhone pixel baselines in both locales.
4. Complete physical Snorkeling GPS/navigation/privacy and Apnea lifecycle/recovery evidence.
5. Validate external Subsurface import/export and independent Bühlmann/CCR reference vectors.

## P3 before App Store polish

After all blockers close, review spacing, icon consistency, copy, chart summaries, map summaries, and optional accessibility refinements. Obtain external legal/App Store claim review before submission.

## Non-regression constraints

Preserve activity-owned Settings and Logbooks; Gauge/Full Computer and TTV/TTS separation; iOS Planner and briefing cards as reference-only; CCR as non-controller; Apnea recovery as non-medical; Snorkeling return guidance as non-guaranteed; HMAC/signed ACK/nonce/replay protections; and pending physical/external gates until evidence exists.

