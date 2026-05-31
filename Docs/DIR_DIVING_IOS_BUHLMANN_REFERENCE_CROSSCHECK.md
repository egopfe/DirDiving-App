# DIR DIVING iOS Buhlmann Reference Cross-Check

Date: 2026-05-28  
Scope: iOS Companion MAIN only

DIR DIVING iOS remains a non-certified informational planning reference. This document records the external reference-envelope cross-check used to harden the in-repository Buhlmann ZHL-16C N2+He planner.

## External Reference Tool

Reference envelope generated locally with:

- `decotengu 0.14.1`
- `ZH_L16C_GF`
- GF Low / High: `30 / 70`
- descent rate: `18 m/min`
- ascent rate: `9 m/min`
- metric seawater approximation

The values below are not certification data. They are regression envelopes used to detect gross algorithmic regressions and to avoid purely self-referential validation.

## Reference Outputs

| Profile | External Runtime | External TTS From Bottom-Time Marker | External Stops |
|---|---:|---:|---|
| Air 21%, 30 m, 20 min | `32.33 min` | `12.33 min` | 12 m x 1, 9 m x 1, 6 m x 2, 3 m x 5 |
| EAN32, 30 m, 20 min | `26.33 min` | `6.33 min` | 9 m x 1, 6 m x 1, 3 m x 1 |
| TX 18/45, 50 m, 30 min, EAN50 + O2 | `78.56 min` | `48.56 min` | 27 m x 1, 24 m x 2, 21 m x 1, 18 m x 2, 15 m x 3, 12 m x 4, 9 m x 6, 6 m x 9, 3 m x 15 |

## In-Repo Test Mapping

`BuhlmannReleaseHardeningTests.testExternalReferenceEnvelopeForAirNitroxAndTrimixProfiles` checks broad expected envelopes rather than exact equality because DIR DIVING uses its own pressure approximation, stop propagation, runtime semantics, and reference-only product positioning.

The purpose of the test is to fail if:

- valid Air/Nitrox/Trimix profiles stop returning finite reference plans;
- Nitrox becomes less favorable than air for the same depth/time;
- Trimix multigas stops disappear;
- TTS/runtime values become obviously nonphysical;
- fake `999`-style NDL/runtime values reappear.

## Remaining External QA

Before stronger release claims, run the iOS Algorithm Tests on macOS and compare a larger fixture set against at least one independent implementation with documented tolerances.
