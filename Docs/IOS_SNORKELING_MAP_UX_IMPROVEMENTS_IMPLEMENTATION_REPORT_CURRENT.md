# iOS Snorkeling Map UX — Implementation Report

**Date:** 2026-06-17  
**Verdict:** INTERNAL_READY · PHYSICAL_QA_PENDING

## Summary

Added center-on-location button, reset-map with confirmation, and section reorder (Map → Route points → Profiles) in iOS Snorkeling Route Planner.

## Files changed

| File | Change |
|------|--------|
| `IOSSnorkelingRoutePlannerView.swift` | UI buttons, reorder, alerts |
| `SnorkelingRoutePlannerDraft.swift` | `hasRoutePoints`, `resetMapPoints()` |
| `IOSSnorkelingRoutePlannerStore.swift` | `resetMapPoints()` |
| `IOSLocationPermissionService.swift` | One-shot location read for map center |
| `SnorkelingRoutePlannerMapCenterPolicy.swift` | Pure center-map policy |
| Localization EN/IT | 8 new keys |
| Tests | 3 new test files |

## Location service

Extended existing `IOSLocationPermissionService` with `currentCoordinate`, `lastKnownCoordinate`, `requestCurrentLocationForMapCenter()` — no second manager, When In Use only.

## Known limitations

- Physical QA not executed
- Auto-center after async location fix requires second tap if GPS slow (pending flag handles async update)
