# Ratio Deco — comparative heuristic (iOS Planner)

**Product position:** DIR DIVING is a **non-certified, reference-only** diving companion. **Bühlmann ZHL-16C** remains the **primary decompression engine**. **Ratio Deco is not a decompression algorithm.**

---

## What Ratio Deco is

Ratio Deco in DIR DIVING iOS is a **comparative planning heuristic** that estimates a **reference deco schedule** from bottom time using simple ratios, then validates that schedule against Bühlmann tissue/ceiling replay **without modifying** Bühlmann output.

Use cases:

- Side-by-side comparison with the Bühlmann schedule (Comparison mode)
- Educational exploration of “ratio-style” stop timing
- PDF/export of the comparative schedule with explicit disclaimers

## What Ratio Deco is not

- Not a certified decompression algorithm
- Not a replacement for Bühlmann TTS/stops shown as the primary plan
- Not real-time dive-computer behavior
- Not validated against external Ratio Deco implementations
- Not used on Apple Watch MAIN

---

## Bühlmann remains primary

| Output | Primary engine |
|--------|----------------|
| Deco stops, TTS, ascent table | **Bühlmann ZHL-16C** |
| CNS/OTU (planner) | Bühlmann-linked exposure model |
| Gas ledger / MOD validation | Bühlmann planner pipeline |
| Ratio Deco stops | **Heuristic only** — validated comparatively |

Selecting Ratio Deco or Comparison **does not change** Bühlmann schedule math.

---

## Presets (1:1, 2:1, custom)

| Preset | Heuristic total deco time (V1) |
|--------|--------------------------------|
| **1:1** | ≈ bottom time |
| **2:1** | ≈ bottom time ÷ 2 |
| **Custom** | ≈ bottom time ÷ custom denominator |

Stop depths come from preset first-stop depth and step (default 21 m / 3 m). Gas assignment follows planner cylinders (deco/travel/bottom); **bailout is excluded**.

---

## Balanced vs Linear vs Shallow-weighted

Distribution modes split the **target total deco minutes** across stops (respecting minimum stop time):

| Mode | Behavior |
|------|----------|
| **Balanced** | Even weight per stop |
| **Linear** | Ramp — shallow stops receive progressively more time |
| **Shallow-weighted** | Deep stops receive more time |

Total target deco time is preserved within rounding tolerance.

---

## Warnings and incompatibility

`RatioDecoValidator` replays Bühlmann tissue at end of bottom and checks GF-low ceiling at each heuristic stop.

| Warning | Meaning |
|---------|---------|
| **Ceiling violation** | Heuristic stop shallower than required Bühlmann ceiling — **NOT a validated plan** |
| **MOD exceeded** | Gas switch exceeds MOD rules at a stop |
| **Unavailable in Base** | Base mode is NDL-only |
| **No deco gases** | No deco cylinder configured (informational planner warning) |
| **Deco depth limit** | Deco mode depth cap exceeded |

When **not Bühlmann-compatible**, UI and PDF state clearly: **NOT a validated decompression plan — comparative heuristic only.**

---

## PDF / export behavior

| Export | Ratio Deco section |
|--------|-------------------|
| Plan PDF | Yes, when Ratio Deco / Comparison selected |
| Briefing PDF | Yes (existing) |
| **Dive Pack PDF** | Yes, with disclaimer + incompatibility warning when applicable |
| Bühlmann schedule in same PDF | Unchanged primary output |

Bailout cylinders: schedule-only note in plan/Dive Pack when configured.

---

## Limitations

- Heuristic ratios are not agency tables or validated Ratio Deco procedures
- No external cross-validation against Subsurface/MultiDeco Ratio Deco modes
- Comparison overlay chart is illustrative
- Logbook tissue analytics for recorded dives remains **simulated/informational** (separate from planner)

---

## Reference-only disclaimer

DIR DIVING does **not** present itself as a certified dive computer. All planner outputs — including Ratio Deco — are **informational and reference-only**. Verify with certified equipment and training before diving.

See also: [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md), [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md), [`IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md).
