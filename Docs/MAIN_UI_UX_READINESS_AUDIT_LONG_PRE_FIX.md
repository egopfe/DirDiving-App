# DIR DIVING — MAIN UI/UX Readiness Long Pre-Fix Audit

**Date:** 2026-05-31  
**Branch:** `main` @ `02eb9d8` (baseline before remediation)  
**Source:** [`MAIN_UI_UX_READINESS_AUDIT_CURRENT.md`](MAIN_UI_UX_READINESS_AUDIT_CURRENT.md)  
**Type:** Read-only confirmation before implementation

---

## A. Scope Confirmation

| Item | Value |
|------|-------|
| Branch | `main` |
| Commit | `02eb9d8` |
| Working tree | Clean before edits |
| Watch target | `DIRDiving Watch App` |
| iOS target | `DIRDiving iOS` |
| Experimental | Excluded per `project.yml` — confirmed |
| Visual refs | `Docs/ReferenceUI/Watch_LIVE_reference.png`, `iOS_Companion_reference.png` — present |
| Build | Watch + iOS BUILD SUCCEEDED @ pre-fix |
| Tests | Watch + iOS algorithm suites PASS @ pre-fix |

---

## B. Apple Watch Re-Audit Summary

All W-UX issues from CURRENT audit **confirmed present** at `02eb9d8`:

| ID | Confirmed | Key files |
|----|-----------|-----------|
| W-UX-001 | Yes | `DiveLiveView.swift` — fixed VStack, no scroll |
| W-UX-002 | Yes | `ContentView.swift` — settings lock banner unreachable |
| W-UX-003 | Yes | `ActionButtonIntents.swift` — reset without confirmation |
| W-UX-005 | Yes | `InfoView.swift` — battery always green |
| W-UX-006 | Yes | `ContentView.swift` — no Crown hint |
| W-UX-007 | Yes | `SettingsView.swift` — export dead row |
| W-UX-009 | Yes | `ExportView.swift` — no ShareLink |
| W-UX-011 | Yes | `AscentGaugeView.swift` — orange tick mismatch |
| W-UX-012 | Yes | `CompassView.swift` — missing a11y |
| W-UX-014 | Yes | `UserImagesView.swift` — missing a11y |
| W-UX-017 | Yes | `WatchLegalOnboardingView.swift` — hardcoded EN |
| W-UX-018/019 | Yes | `DiveDetailView`, `ExportView` — hardcoded IT |
| W-UX-020/021 | Yes | `AlarmSettingsView`, `AscentRateSettingsView` |
| W-UX-013/022/023 | Yes | Mission mode, ModeSelection, CLEAR button |

**Safety UX verified intact:** depth/TTV/runtime/gauge remain visible during inline alarms; no full-screen takeover.

---

## C. iOS Re-Audit Summary

| ID | Confirmed | Key files |
|----|-----------|-----------|
| I-UX-009 | Yes | `ManualDiveEditorView.swift` — fabricates samples on no-depth edit |
| I-UX-021 | Yes | `LogbookView.swift` — no DEMO badge |
| I-UX-013 | Yes | `DiveLogStore` — conflicts never in UI |
| I-UX-005 | Yes | `PlannerView.swift` — team preview misleading |
| I-UX-025/033 | Yes | `AnalysisView`, `MoreView` — hardcoded IT |
| I-UX-027/028/029 | Yes | Custom tabs / pickers missing a11y |
| I-UX-003/010/014–016/022/034 | Yes | Planner mode, disclosure, sync, demo mix, salinity |
| I-UX-002/031 | Yes | Dead ellipsis, card a11y |

---

## D. Cross-App Re-Audit Summary

| ID | Confirmed | Notes |
|----|-----------|-------|
| X-UX-001 | Yes | Policy A broken on iOS edit |
| X-UX-004 | Yes | Watch ascent bands metric-only in imperial |
| X-UX-005 | Yes | Watch legal onboarding mixed locale |
| X-UX-007 | Yes | iCloud conflicts silent |
| X-UX-008 | Yes | Demo cards unlabeled |
| X-UX-010 | Yes | Shortcut errors hardcoded IT |

Export policy, TTV semantics, GPS no-fix copy — **aligned** pre-fix (display only).

---

## E. Issue Confirmation Matrix (excerpt)

| ID | Sev | Still present @ 02eb9d8 | Priority | Fix class |
|----|-----|-------------------------|----------|-----------|
| W-UX-001 | HIGH | Yes | P0 | UI-only |
| W-UX-017 | HIGH | Yes | P0 | localization |
| I-UX-009 | CRITICAL | Yes | P0 | small functional + UI |
| I-UX-021 | HIGH | Yes | P0 | UI-only |
| W-UX-006 | HIGH | Yes | P1 | UI-only |
| W-UX-002 | HIGH | Yes | P1 | UI-only |
| W-UX-003 | MEDIUM | Yes | P1 | small functional |
| I-UX-013 | HIGH | Yes | P1 | UI-only |
| I-UX-005 | HIGH | Yes | P1 | copy-only |
| … | … | All 71 IDs confirmed | P0–P3 | per CURRENT audit |

---

## F. Implementation Plan (executed)

1. P0 Watch: W-UX-001, W-UX-017  
2. P0 iOS: I-UX-009, I-UX-021  
3. P1 Watch: W-UX-002, W-UX-003, W-UX-006, W-UX-018/019  
4. P1 iOS: I-UX-013, I-UX-005, I-UX-025/033, I-UX-027–029  
5. Cross-app P0/P1: X-UX-001, X-UX-004–010  
6. P2 Watch: W-UX-005, W-UX-007, W-UX-009, W-UX-011, W-UX-012, W-UX-014, W-UX-020, W-UX-021  
7. P2 iOS: I-UX-003, I-UX-010, I-UX-014–016, I-UX-022, I-UX-034  
8. P3 cleanup: W-UX-013/023, I-UX-002/031  
9. Build/tests  
10. Post-fix audit + QA report  

---

*Pre-fix baseline: Watch 83%, iOS 86%, Cross-app 81%. Remediation proceeded immediately after this confirmation.*
