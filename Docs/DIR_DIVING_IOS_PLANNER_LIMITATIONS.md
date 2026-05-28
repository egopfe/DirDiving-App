# DIR DIVING iOS Planner Limitations

Date: 2026-05-28  
Scope: iOS Companion MAIN only

## Safety Position

DIR DIVING iOS is not a certified dive computer. The planner is a Buhlmann-based planning reference and must be validated against certified instruments, training, tables, team procedures, and instructor guidance.

## Implemented Reference Engine

The iOS planner now includes a ZHL-16C N2+He multigas reference engine:

- Air, nitrox, trimix, and heliox gas compositions.
- Travel, bottom, and decompression gases.
- Gas switches at configured depths.
- GF Low / GF High based ceiling and stop propagation.
- Tissue-state NDL.
- Runtime/TTS schedule generation from profile segments.

## Current Assumptions

- Ambient pressure uses the project-wide `10 m/bar` depth approximation.
- Surface pressure is treated as `1.0 bar`.
- Water vapor pressure is fixed at `0.0627 bar`.
- Stops are rounded to 3 m intervals.
- Default descent rate is 18 m/min.
- Default ascent rate is 9 m/min.
- Gas density, CNS, OTU, END, and EAD remain reference estimates.

## Known Limitations

- Salinity and altitude are stored but do not yet alter ambient pressure.
- Validation fixtures are internal regression fixtures; external validation against a trusted decompression reference is still required.
- The planner does not replace real-time decompression control.
- The planner does not account for individual physiology, workload, thermal stress, repetitive-dive edge cases beyond current tissue-state input, or equipment failures.
- Physical-device QA and App Store/TestFlight review remain required.

## Fail-Closed Policy

The planner must not silently normalize unsafe input into valid-looking output. Invalid gas mixes, invalid gradient factors, MOD violations, hypoxic gas use, invalid switch depths, and impossible profile values must surface as blocking states or unavailable output.

