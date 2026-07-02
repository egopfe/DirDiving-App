# MASTER FEATURE MATRIX REPAIR PLAN (V1.7)

## Objective
Align feature matrices with current MAIN architecture and latest remediation wave without overclaiming physical/external readiness.

## Required matrix edits (planned)

1. `Docs/DIR_DIVING_Feature_Comparison.csv`
   - Add row: unified iOS logbook is presentation-only, default OFF, no merged persistence
   - Add row: GPS ownership by activity (Diving surface points, Apnea surface points, Snorkeling tracks)
   - Add row: location policy When-In-Use only, no Always Location claim
   - Add row: CCR acknowledgement independent toggle (reference-only policy)
   - Add row: equipment gas/cylinder dedicated section with no generic GAS toggle regression
   - Add row: demo/fake log isolation from real logbooks

2. `Docs/MASTER_UI_UX_*` matrices
   - Add explicit planner send-order truthfulness row (route safety and incomplete-state messaging before transfer actions)
   - Add unified-logbook manual UI QA pending row

3. `Docs/MASTER_RELEASE_*` matrices
   - Add cross-links to V1.7 CCR/equipment/demo remediation audits
   - Preserve external/physical pending gates as pending, not pass

4. `Docs/MASTER_MAIN_*` matrices
   - Add no-contamination and no-sync-mutation assertions for unified logbook presentation mode

## Acceptance criteria
- No matrix claims full physical/open-water/paired-device validation without evidence
- No matrix claims certification/medical/live CCR controller authority
- Activity isolation and ownership visible in one top-level matrix row set
