# Snorkeling Watch P1 — iOS ↔ Watch Integration Audit

**Date:** 2026-07-02  
**Verdict:** **P1_PARTIAL** (pre-remediation)

---

## Summary

Protocol/sync infrastructure was **CONFIRMED** production-grade. UI visibility gaps were **MISSING** or **PARTIAL** on Watch ready panel, battery presentation, and iOS logbook track summary.

---

## Findings matrix

| Area | Verdict | Notes |
|------|---------|-------|
| iOS route sync (planner/dashboard) | **CONFIRMED** | Transfer card + ACK state machine existed |
| iOS route revision/checksum in UI | **MISSING** | Stored but not shown |
| Watch route import pipeline | **CONFIRMED** | `SnorkelingImportedRouteStore` + ACK |
| Watch ready panel route status | **MISSING** | No route name/revision/pending |
| Watch battery in presentation | **MISSING** | `batteryFraction` hardcoded `nil` in runtime store |
| Watch live route reload | **PARTIAL** | Only at session configure |
| iOS logbook track/GPS/marker summary | **PARTIAL** | Runtime summary existed; track quality + marker count card missing |
| Watch→iOS session sync on iOS | **CONFIRMED** | Dashboard session line via `IOSSnorkelingSessionSyncService` |
| Watch session save sync pending UX | **PARTIAL** | `markSessionSyncPending` unused |

---

## Regression risk

| Change | Risk |
|--------|------|
| Presentation-only policies | **Low** |
| Watch ready panel layout | **Medium** |
| Route hot-reload on import | **Medium** |
| No codec / algorithm changes | **Low** |

---

## Low-risk plan (implemented)

1. `SnorkelingWatchReadyPresentationPolicy` + `SnorkelingWatchImportedRoutePresentation`
2. Wire `batteryFraction` through `SnorkelingWatchRuntimeStore`
3. Watch ready panel route / pre-check / battery cells
4. `SnorkelingRouteSyncStatusPresentationPolicy` on iOS planner
5. `SnorkelingLogbookDetailPresentationPolicy` on session detail
6. `SnorkelingWatchSyncStatusPresentationPolicy` on dashboard

**No changes:** Bühlmann, decompression, CCR, diving, apnea runtime algorithms.
