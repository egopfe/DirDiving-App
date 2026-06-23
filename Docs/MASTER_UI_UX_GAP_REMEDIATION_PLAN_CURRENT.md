# Master UI/UX Gap Remediation Plan — Current

**Audit:** Command 03 — Master UI/UX Full Deep Comprehensive Audit V2.0  
**Date:** 2026-06-22  
**Branch:** `main`  
**Commit:** `1f62235`  
**Open findings:** P0 0 · P1 5 · P2 5 · P3 3 · P4 2

Prior P0 **UI16-P0-001** (altitude environment silently discarded on Watch) is **CLOSED** at `1f62235` via `OrchestratedAltitudeEnvironmentTests` and predive environment UI. No P0 UI/UX blockers remain in source.

---

## P0 — Must fix before any safety-critical use

**None open.**

| ID | Status | Notes |
|----|--------|-------|
| UI16-P0-001 | **CLOSED @ 1f62235** | Imported altitude/salinity propagate to `runtimePlan()`; invalid packages rejected |

---

## P1 — Must fix before internal TestFlight

### MUIUX-P1-001 — Physical Watch and iPhone UI QA pending

- **Affected:** All live surfaces, smallest Watch layout, Apnea underwater, Snorkeling GPS, multi-banner density.
- **Remediation:** Execute scenarios in `WATCH_ULTRA`, `APNEA_WATCH_ULTRA`, `SNORKELING_WATCH_LAYOUTS`, `IOS_ACCESSIBILITY`, `IOS_PLANNER` evidence folders.
- **Acceptance:** Signed artifacts per `EVIDENCE_TEMPLATE.md`; no clipping of safety-critical metrics on 41 mm.
- **Tests:** Manual QA only; retain existing `SmallestWatchLayoutContractTests`.
- **Physical QA:** **Required**
- **Rerun audits:** Master UI/UX (03), Audit 12, Audit 16

### MUIUX-P1-002 — Paired Watch↔iOS sync UI QA pending

- **Affected:** Briefing card transfer states, image delete ACK, sync conflict UI, iCloud restore messaging.
- **Remediation:** Paired-device journeys documented in `WATCH_IOS_SYNC`, `ICLOUD_TWO_DEVICE`.
- **Acceptance:** UI shows pending/failed/stale truthfully; iOS never shows delete success before Watch ACK.
- **Physical QA:** **Required** (paired devices)
- **Rerun audits:** 8, 9, 12, Master UI/UX

### MUIUX-P1-003 — Accessibility manual QA pending

- **Affected:** Planner tabs, CCR controls, gas ledger, charts, checklist, Watch live overlays, Settings mode switch.
- **Remediation:** VoiceOver + Dynamic Type XL passes on physical iPhone and Watch.
- **Acceptance:** Safety-critical states not color-only; chart summaries audible.
- **Physical QA:** **Required**
- **Rerun audits:** 11, Master UI/UX

### MUIUX-P1-004 — PDF render and external release evidence pending

- **Affected:** Planner PDF, checklist PDF, briefing card PNG, export/share sheets.
- **Remediation:** Populate `PDF_RENDER`, `LEGAL_REVIEW`, `APP_STORE_MARKETING`.
- **Acceptance:** Rendered values match UI; disclaimers present; no certification implication.
- **Physical QA:** Device PDF preview required
- **Rerun audits:** 13, Master UI/UX

### MUIUX-P1-005 — Executable build/test evidence @ HEAD inconclusive

- **Affected:** Release confidence for commit `1f62235`.
- **Remediation:** Sequential macOS build: iOS app, Watch app, both algorithm test schemes; `./Scripts/validate_ui_ux_readiness.sh`.
- **Acceptance:** BUILD SUCCEEDED + tests green @ HEAD.
- **Rerun audits:** 12, Master UI/UX

---

## P2 — Must fix before external TestFlight

### MUIUX-P2-001 — Physical pixel-diff baselines absent (0/59)

- **Remediation:** Capture device screenshots; optional snapshot PNG baselines for 20 iOS raster entries.
- **Acceptance:** `MASTER_VISUAL_REGRESSION_COVERAGE_MATRIX` Physical_Pixel_Diff = captured for primary screens.
- **Rerun audits:** 14, Master UI/UX

### MUIUX-P2-002 — Manual on-device visual fidelity not scored

- **Remediation:** Score all 59 mockups NOT_SCORED_DEVICE → PASS/PARTIAL/FAIL on reference devices.
- **Acceptance:** Documented scores in visual regression matrix.
- **Physical QA:** Required

### MUIUX-P2-003 — Historical documentation contradicts current multi-activity scope

- **Affected:** `Docs/README.md`, `Docs/INDEX.md` historical sections still mention Apnea/Snorkeling as experimental.
- **Remediation:** Mark historical sections explicitly or archive; align INDEX baseline to `1f62235`.
- **Acceptance:** No reader path from current INDEX to obsolete scope without warning.
- **Rerun audits:** 6, Master UI/UX

### MUIUX-P2-004 — Ascent speed settings discoverability

- **Affected:** `PlannerAscentSpeedSettingsView` reachable only via Diving `MoreView`.
- **Remediation:** Add Planner header link or inline disclosure (UX-only).
- **Acceptance:** User can discover ascent speeds from Planner without searching More.
- **Rerun audits:** Master UI/UX

### MUIUX-P2-005 — iOS dashboard last-session card mockup partial fidelity

- **Affected:** `APNEA_IOS_01`, `SNORKELING_IOS_01` dashboard cards.
- **Remediation:** Pixel review vs mockups; adjust layout if needed.
- **Acceptance:** Functional links + visual parity on reference iPhone.
- **Rerun audits:** 14, Master UI/UX

---

## P3 — App Store polish

| ID | Item | Remediation |
|----|------|-------------|
| MUIUX-P3-001 | `mockups/README.md` states assets maintained outside repo | Update README — all 59 PNGs exist locally |
| MUIUX-P3-002 | 2 legacy PNGs in `Docs/ReferenceUI/` | Archive or index as non-canonical |
| MUIUX-P3-003 | Watch dive detail dates not locale-adaptive | Use locale-aware formatting in `DiveDetailView` |

---

## P4 — Optional enhancements

| ID | Item |
|----|------|
| MUIUX-P4-001 | Mission Mode discoverability on Watch Live |
| MUIUX-P4-002 | Reminder suppression policy copy in Settings |

---

## Full Computer remediation rule

Any future change affecting Watch Full Computer live decompression UI or environment propagation must rerun:

1. Watch Full Computer forensic audit (Audit 15 / 01W)
2. Master UI/UX audit (Command 03)

---

## Recommended execution order

1. **MUIUX-P1-005** — Confirm builds/tests @ HEAD (unblocks evidence claims)
2. **MUIUX-P1-001 + P1-002 + P1-003** — Physical and paired QA campaigns
3. **MUIUX-P1-004** — PDF/legal/marketing evidence
4. **MUIUX-P2-001 + P2-002** — Visual regression baselines
5. **MUIUX-P2-003** — Documentation clarity
6. P3/P4 polish before App Store

**Release blockers for external TestFlight:** MUIUX-P1-001, MUIUX-P1-002, MUIUX-P1-003, MUIUX-P1-004  
**Release blockers for App Store:** all P1 + P2 + legal/marketing gates

No production code was modified by this audit.
