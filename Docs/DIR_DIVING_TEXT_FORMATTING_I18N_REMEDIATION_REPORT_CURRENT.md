# DIR DIVING — Text Formatting & i18n Remediation Report

**Date:** 2026-06-10  
**Branch:** `main`  
**Source audit:** `Docs/DIR_DIVING_TEXT_FORMATTING_I18N_AUDIT_CURRENT.md`  
**Scope:** Localization keys, copy, accessibility wiring, test guardrails only.

---

## 1. Executive summary

Implemented P0–P2 remediation from the i18n audit: iOS PDF export keys, semantic Watch sync messages, CCR planner keys, Watch runtime keys, Settings/Checklist copy alignment, Italian translation fixes, chart/unit localization, and accessibility wiring. No algorithm, sync codec, or business-logic changes.

---

## 2. Files modified

| Area | Files |
|------|-------|
| iOS catalogs | `iOSApp/Resources/en.lproj/Localizable.strings`, `iOSApp/Resources/it.lproj/Localizable.strings` |
| Watch catalogs | `Resources/en.lproj/Localizable.strings`, `Resources/it.lproj/Localizable.strings` |
| iOS sync | `iOSApp/Services/WatchSyncService.swift` |
| iOS UI | `MoreView.swift`, `ChecklistView.swift`, `EquipmentView.swift`, `PlannerView.swift`, `CCRPlannerView.swift`, `DiveDetailView.swift`, `AnalysisView.swift`, `CCRPlanResultView.swift`, `DeveloperSettingsView.swift`, `TissueNarcosisAnalyticsView.swift` |
| Watch UI/services | `WatchSyncService.swift`, `CompassManager.swift`, `InfoView.swift`, `UserImageStore.swift`, `WatchCompanionPhotoValidator.swift`, `DiveLogStore.swift`, `DiveSessionPersistenceClass.swift`, `DiveLogListView.swift`, `SettingsView.swift`, `AlarmSettingsView.swift` |
| Tests | `IOSI18nRemediationTests.swift` (**new**), `UIUXLocalizationRemediationTests.swift`, `UIUXRemediationV3AccessibilityTests.swift`, `WatchLocalizationStaticSweepTests.swift` |
| Project | `DIRDiving.xcodeproj` (via `xcodegen generate`) |

---

## 3. iOS catalog changes (+65 keys each locale)

- **34 `pdf.export.*`** keys copied from Watch bundle into iOS bundle.
- **Semantic sync keys:** `sync.dive.*`, `sync.conflict.*`.
- **UI keys:** `planner.calculate`, `common.cancel`, `common.ok`, `equipment.profile.saved_notice`, `checklist.status.ready_badge_format`, `settings.title`, `chart.axis.*`, `common.unit.min`, `chart.axis.date`.

---

## 4. Watch catalog changes (+24 keys each locale)

- `compass.status.calibration_required`, `info.status.available`, `image.error.*`, `log.validation.*`, `log.load.error_format`, `watchsync.*`, `dive.session.*`, `sync.dive.*`, `alarms.a11y.*`.
- IT sync status strings translated (`Sync pending/sent/acknowledged`).

---

## 5. PDF export remediation

All **39** `pdf.export.*` keys referenced by iOS code now resolve from `iOSApp/Resources` EN/IT. Verified by `IOSI18nRemediationTests.testPDFExportKeysUsedByIOSCodeExistInBothCatalogs`.

---

## 6. iOS WatchSyncService semantic-key migration

Replaced Italian sentence keys with:

- `sync.dive.updated_from_watch`, `sync.dive.duplicate_ignored`, `sync.dive.received_from_watch`, `sync.dive.sent_to_watch`
- `sync.dive.queued_send_failed_format`, `sync.dive.queued_transfer_user_info`, `sync.dive.completed_unknown_session`
- `sync.dive.watch_tombstone_applied_format`, `sync.dive.watch_sync_error_format`, `sync.dive.send_error_format`
- `sync.conflict.saved_for_review`, `sync.conflict.resolved_watch_version`
- `sync.status.pending_activation` (replaces `In attesa attivazione`)

---

## 7. CCR key remediation

`CCRPlannerView` now uses `planner.field.max_depth`, `planner.field.avg_depth`, `planner.field.bottom_time`, `planner.calculate`.

---

## 8. Watch runtime key remediation

Migrated compass, info, image, log, session, and sync diagnostics to semantic keys listed in §4.

---

## 9. Checklist / Settings / Equipment copy

- Settings screen title: `settings.title` → Settings / Impostazioni.
- Checklist READY badge: `checklist.status.ready_badge_format` → READY / PRONTA.
- Empty state CTA: Open Equipment / Apri Attrezzatura.
- Cancel/OK: `common.cancel`, `common.ok`.
- Saved toast: `equipment.profile.saved_notice`.
- IT tabs: Pianifica, Registro, Lista controllo.

---

## 10. Italian translation quality

- Fixed EN/hybrid IT values for sync counters, alarms, GPS labels, sync queue message.
- Normalized `profondita` → `profondità` in IT catalog values.
- Preserved brands/acronyms (DIR DIVING, GAS, BAR, PSI, CCR, Watch, iPhone).

---

## 11. Accessibility wiring

- Watch Settings: `settings.a11y.language`, `settings.a11y.units`, `settings.a11y.haptics` on pickers/toggle.
- Watch Alarms: row-level `alarms.a11y.row_format`; stepper decrease/increase labels.

---

## 12. Chart / unit formatting

- Localized chart axes in `DiveDetailView`, `AnalysisView`, `CCRPlanResultView` depth profile.
- `common.unit.min` for iOS duration units; Watch log list uses `dive_reminder.unit.min`.

---

## 13. Test guardrails

**New:** `IOSI18nRemediationTests` (5 tests) — PDF keys, sync semantics, CCR keys, checklist/settings copy, common cancel/OK.

**Extended:** `UIUXLocalizationRemediationTests`, `UIUXRemediationV3AccessibilityTests`, `WatchLocalizationStaticSweepTests` (+runtime keys, legacy key sweep, Compasso guard).

---

## 14. Catalog parity (post-remediation)

| Bundle | EN keys | IT keys | Only EN | Only IT | Format mismatches |
|--------|--------:|--------:|--------:|--------:|------------------:|
| iOS | 1,635 | 1,635 | 0 | 0 | 0 |
| Watch | 799 | 799 | 0 | 0 | 0 |

---

## 15. Validation

| Command | Result |
|---------|--------|
| `xcodegen generate` | OK |
| `DIRDiving iOS` build (iPhone 15 Pro) | **BUILD SUCCEEDED** |
| `DIRDiving Watch App` build (Apple Watch Ultra 3) | **BUILD SUCCEEDED** |
| `IOSI18nRemediationTests` | **TEST SUCCEEDED** (5/5) |
| `UIUXLocalizationRemediationTests` | **TEST SUCCEEDED** |
| `UIUXRemediationV3AccessibilityTests` | **TEST SUCCEEDED** |
| `WatchLocalizationStaticSweepTests` | **TEST SUCCEEDED** (7/7) |

**Simulator note:** Apple Watch Ultra 2 (49mm) unavailable; used **Apple Watch Ultra 3 (49mm)**.

---

## 16. Manual QA checklist

- [ ] EN: Settings tab + screen both “Settings”
- [ ] IT: Settings tab + screen both “Impostazioni”
- [ ] Checklist READY badge localized
- [ ] PDF export/share/errors localized
- [ ] CCR planner labels not raw keys
- [ ] Watch compass calibrate message in correct language
- [ ] VoiceOver on Watch settings pickers and alarm rows

---

## 17. Remaining follow-up (non-blocking)

- Legacy Italian-as-key entries remain in catalogs for backward compatibility (`Bussola attiva`, etc.) — code paths migrated where shipped.
- Some chart axes in tissue analytics / ratio deco still use internal English labels (non-primary user-facing).
- Experimental views excluded from targets — not remediated.
- Orphan `tab.more` key retained for compatibility.

---

## 18. Confirmations

- Decompression algorithms: **not changed**
- Bühlmann math: **not changed**
- Gas planning logic: **not changed**
- CNS/OTU logic: **not changed**
- MOD/PPO₂ logic: **not changed**
- Planner calculation semantics: **not changed**
- Sensor/dive detection/safety thresholds: **not changed**
- WatchConnectivity business logic: **not changed**
- Sync codec semantics: **not changed**
- Persistence semantics: **not changed**
- PDF generation logic: **not changed** (localization lookup only)
- App Intents / Mission Mode / GPS / haptics: **not changed**
- Features: **not removed**
- Changes limited to **text formatting, localization, accessibility copy, tests**
