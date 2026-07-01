# iOS Unified Logbook — No Contamination Policy

## Prohibited

- Moving logs between stores
- Duplicating logs into other logbooks
- Merging persistent models
- Creating unified storage
- Writing Snorkeling/Apnea data into Diving store (or cross-writes)
- Modifying Watch → iOS sync for unified presentation
- Aggregated export presented as a single logbook

## Required

- `IOSUnifiedLogbookPresentationBuilder.build` is read-only over source sessions
- Unified list has no delete/edit actions
- Demo/fake entries excluded from real unified view (`includeDemo: false`)
- Activity-specific OFF logbook behavior unchanged
- `ensureStoresForUnifiedLogbook()` only loads stores for presentation; does not change `selectedMode`

## Verification

Tests: `IOSUnifiedLogbookNoContaminationTests`, `IOSUnifiedLogbookPresentationBuilderTests`.
