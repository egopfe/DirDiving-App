# Documentation Update Report — 2026-06-06

**Branch:** `main` @ `90dc3f5`  
**Type:** Docs-only alignment (Phases 1–10 of CURSOR documentation command)  
**Backup:** `backup/docs-alignment-20260606`

## Summary

Aligned MAIN documentation with current architecture: Diving + iOS Companion, legal onboarding, depth safety (35/38/40 m), inline ascent banners, compact GPS overlays, **BUSSOLA**, sync/tombstones, App Intents / Action Button (Shortcuts), Watch photo transfer **with ACK and iOS management UI**, and experimental branch isolation (Snorkeling, Apnea, Buddy).

## Files touched

| Action | Path |
|--------|------|
| Create | `README.md` (root stub) |
| Create | `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md` |
| Create | `Docs/DOCUMENTATION_UPDATE_REPORT_20260606.md` |
| Create | `Docs/PR_STATUS_20260606.md` |
| Update | `Docs/README.md` |
| Update | `Docs/INDEX.md` |
| Update | `Docs/CHANGELOG.md` |
| Update | `Docs/ROADMAP.md` |
| Update | `Docs/BRANCH_AND_TARGET_ISOLATION_POLICY.md` |
| Update | `Docs/ReferenceUI/README.md` |
| Append rows | `Docs/DIR_DIVING_Feature_Comparison.csv` |

## Runtime commits reflected (not modified)

| Commit | Area |
|--------|------|
| `fc311be` | Watch photo import staging fix; iOS manual send + manage sheet; transfer verification |
| `90dc3f5` | iOS localization `watch_photo.send_to_watch`, `watch_photo.manage.open` |

## Terminology preserved

- **BUSSOLA** (never COMPASSO)
- Inline underwater warnings (no full-screen blocking)
- GPS surface-only
- Planner / Bühlmann **indicative**, not certified decompression authority

## Not done (out of scope / follow-up)

- PNG captures into `Docs/ReferenceUI/` (placeholders documented)
- Merging experimental PRs #8 / #9
- Physical QA evidence packs
- Code changes of any kind

## Verification

```bash
xcodegen generate
# DIRDiving Watch App — BUILD SUCCEEDED
# DIRDiving iOS — BUILD SUCCEEDED
# DIRDiving iOS Algorithm Tests — TEST SUCCEEDED
```

(last run on `90dc3f5` before this doc pass)
