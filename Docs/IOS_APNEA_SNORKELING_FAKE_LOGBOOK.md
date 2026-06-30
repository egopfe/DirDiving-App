# iOS Apnea & Snorkeling Fake Logbook

**Status:** INTERNAL_READY · PHYSICAL_QA_PENDING  
**Scope:** iOS companion only  
**Default:** OFF for both toggles

## Purpose

Provide separate demo/fake logbook sessions for Apnea and Snorkeling on iOS for App Store review, QA, and onboarding demos — without writing to real storage, syncing to Watch, exporting as real logs, or affecting Diving.

## Settings location

| Activity | Path | Toggle key |
|----------|------|------------|
| Apnea | Settings → Apnea → Demo logbook | `dirdiving.ios.apnea.fakeLogbook.enabled` |
| Snorkeling | Settings → Snorkeling → Demo logbook | `dirdiving.ios.snorkeling.fakeLogbook.enabled` |

Toggles are independent. Default is **false**.

## Architecture

```
Real Apnea Logbook Store + Fake Apnea Logbook Provider → Apnea presentation (IOSLogbookDisplayComposer)
Real Snorkeling Logbook Store + Fake Snorkeling Logbook Provider → Snorkeling presentation
```

- `IOSActivityDemoLogbookSettingsStore` — UserDefaults toggles only
- `FakeApneaLogbookProvider` / `FakeSnorkelingLogbookProvider` — in-memory demo sessions
- `IOSApneaLogbookDisplayEntry` / `IOSSnorkelingLogbookDisplayEntry` — presentation wrappers with `origin: .real | .demo`
- `DemoLogbookBadge` — visible DEMO marker in list, detail, map overlay, banners

## Display rules

- Toggle **OFF:** only real sessions from the real store
- Toggle **ON:** demo sessions from provider; real sessions unchanged
- When both exist: separate **Real logs** and **Demo logs** sections
- When only demo: banner “You are viewing demo logs.”
- Statistics on list views filter out demo catalog IDs
- Export/share disabled on demo detail views

## Non-goals / isolation

| Area | Impact |
|------|--------|
| Diving fake logbook (`DiveLogStore` / `DemoDiveCatalog`) | Unchanged |
| Apnea runtime | Unchanged |
| Snorkeling runtime / route planner | Unchanged |
| Watch runtime & sync | Demo sessions never written to real stores or transferred |
| CloudKit / real export | Demo excluded |
| Bühlmann, GF, planner, Full Computer | Unchanged |

## Demo session IDs

Stable catalog UUIDs (`DemoApneaSessionCatalog`, `DemoSnorkelingSessionCatalog`) — not persisted as real logs.

## QA

Physical QA templates under `Docs/QA_EVIDENCE/IOS_*_FAKE_LOGBOOK_*` — all **PENDING** until device evidence is recorded.
