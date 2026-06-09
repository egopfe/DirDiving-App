# CCR / Rebreather Safety Disclaimer — DIR DIVING iOS MAIN

**Last updated:** 2026-06-09  
**Applies to:** CCR planner surfaces on iOS Companion MAIN only  
**Global disclaimer:** [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) also applies.

---

## Not a CCR controller

DIR DIVING is **not** a certified closed-circuit rebreather controller, loop monitor, or manufacturer-approved CCR software. The CCR planner is a **reference companion tool** for pre-dive planning and post-dive review.

## No live loop authority

DIR DIVING does **not**:

- monitor live loop PPO₂, CO₂, or scrubber status
- replace manufacturer CCR checklists, procedures, or training
- authorize setpoint changes underwater
- simulate validated OC bailout switches using certified decompression math

Bailout reserve estimates use **heuristic SAC models** — they are order-of-magnitude planning aids, not certified gas planning.

## Reference-only math

CCR deco schedules, tissue traces, narcosis/END estimates, and CNS/OTU presentations are **indicative** and may diverge from manufacturer tables, third-party planners, or your CCR handset.

## Watch boundary

Apple Watch DIR DIVING logs open-circuit style dives with depth/ascent awareness and **BUSSOLA**. Synced dive data must **not** be interpreted as live CCR loop state on Watch.

## User responsibility

You are solely responsible for:

- verifying all plans with certified tools and manufacturer guidance
- carrying appropriate bailout gas and following trained procedures
- not diving beyond your certification, equipment limits, or local regulations

## External validation

CCR external validation evidence is **PENDING** — see [`CCR_REBREATHER_VALIDATION_EVIDENCE.md`](CCR_REBREATHER_VALIDATION_EVIDENCE.md). Do not treat CCR planner output as validated until evidence rows are explicitly **PASS** or **WAIVED** with written rationale.

## Release gates

External TestFlight or App Store marketing that references CCR planning is **BLOCKED** until CCR validation disclosure requirements in [`CCR_REBREATHER_VALIDATION_PLAN.md`](CCR_REBREATHER_VALIDATION_PLAN.md) are satisfied and physical QA matrices are executed.
