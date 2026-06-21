# Orchestrated Audit Remediation Roadmap — Current

**Planning baseline:** `main` @ `6cbba649` · audit-only · no fixes implemented

## Phase A — Freeze and safety gate

- Freeze feature expansion and keep `main` stable.
- Reproduce ORCH-001 on a macOS worktree with a signed 1,500 m plan.
- Add failing tests before implementation: package activation, explicit environment requirement, Watch predive truthfulness, checkpoint/logbook propagation, and independent altitude profiles.
- Confirm target membership and current full-suite baselines.
- Preserve the multi-activity architecture, activity-owned Settings/Logbooks, and all existing sync trust invariants.

Exit: deterministic failing evidence exists and remediation scope is reviewed.

## Phase B — P0 safety and data integrity

1. Introduce a versioned Watch Full Computer predive configuration that contains gas profile plus validated frozen `PlannerEnvironment` and source/confidence state.
2. Support exactly three live sources: environment imported from an iPhone plan, altitude/environment entered manually in Watch Full Computer Settings, or a Watch sensor-measured value proposed for confirmation when Full Computer starts at detected elevation.
3. Convert `DivePlanEnvironmentPayload` to the canonical environment during import; reject invalid/future/missing data.
4. Add the Watch manual Altitude/Environment setting and the startup sensor proposal. Never silently overwrite an imported or manual source; require explicit confirmation when sources disagree.
5. Remove implicit `.seaLevelSaltWater` defaults and prohibit a separate explicit sea-level option. A validated source may resolve to near-zero altitude, but missing or unavailable input must block live start.
6. Show environment values and source on imported-plan/predive confirmation and block incompatible altitude plans.
7. Freeze the confirmed environment at dive start and propagate it to tissues, solver, gas eligibility, PPO2/MOD, schedule, checkpoint, restore, UI, and diagnostics.
8. Prove no calculation failure becomes optimistic no-decompression.

Exit: ORCH-001 closed with independent altitude evidence; rerun audits 0, 0W, 01W, 1, 2, 3, 4, 8, 12, 13, 15, 16.

## Phase C — P1 release blockers

- Build a truly independent altitude oracle; do not call production ambient/depth functions.
- Cover all 16 N2/He compartments, Air/Nitrox/Trimix, fresh/salt, gas switches, timing faults, restore, deco clear, and re-descent.
- Version Full Computer logbook metadata to preserve altitude, local surface pressure, water density/salinity, source, and confidence; migrate legacy sessions as unknown, not sea level.
- Run XcodeGen, both app builds, both full algorithm suites, all focused safety suites, and all readiness scripts on macOS.
- Execute physical Watch Ultra/entitlement/Water Lock/wet/glove and paired-device sync/trust matrices.
- Complete external Bühlmann/CCR, legal, and App Store reviews.

Exit: no P0/P1; internal and external evidence signed and retained.

## Phase D — P2 functional hardening

- Complete physical battery/thermal/GPS/low-power profiling.
- Complete VoiceOver, Dynamic Type, contrast, reduced-motion, and haptics-off device QA.
- Populate manual visual fidelity, device pixel, and PDF render baselines.
- Validate Subsurface round trips and Snorkeling GPS/privacy behavior.
- Normalize scanner paths and test tooling on Windows/macOS.
- Mark historical README/INDEX architecture blocks as historical or archive them.

Exit: all external TestFlight gates pass or are explicitly accepted by named owners.

## Phase E — P3/P4 polish

Only after safety/release gates: spacing, icons, copy refinements, optional telemetry, extra diagnostics, and performance tuning.

## Dependency rules

- Canonical environment propagation before UI copy, exports, or optimization.
- Schema/persistence before sync/export/import.
- Target membership/build health before reachability claims.
- Watch timing/math before performance tuning.
- Localization keys before new screenshot baselines.
- Security validation before retry/idempotency tuning.
- Physical/external gates remain pending until evidence exists.

## No-regression constraints

Every remediation must preserve:

- `main` and the current multi-activity architecture;
- activity-owned Settings and Logbooks;
- Gauge vs Full Computer and TTV vs TTS separation;
- iOS Planner and Watch briefing cards as reference-only;
- Watch live runtime independence from planner presentation cards;
- CCR reference-only/non-controller posture;
- Apnea recovery non-medical posture;
- Snorkeling return guidance non-guaranteed posture;
- HMAC, signed ACK, nonce/replay, trust-reset, schema, revision, and activity namespace protections;
- no unsupported certification claims;
- physical/external QA marked pending until demonstrated.
