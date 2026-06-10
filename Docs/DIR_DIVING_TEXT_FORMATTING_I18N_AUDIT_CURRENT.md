# DIR DIVING — Text Formatting & Internationalization Audit

**Date:** 2026-06-10  
**Branch:** `main` @ `9029667` (`feat(ios): split Attrezzatura and Checklist into separate tabs.`)  
**Scope:** iOS Companion + Apple Watch (shipped UI), localization catalogs, accessibility copy, text formatting consistency  
**Languages in scope:** English (`en`), Italian (`it`)

---

## 1. Executive summary

DIR DIVING has **strong catalog parity** between English and Italian (zero missing keys, zero format-specifier mismatches), and existing automated localization tests pass. However, **internationalization is not complete** for production-quality bilingual UX:

| Area | Status |
|------|--------|
| EN/IT key parity (iOS) | ✅ 1,570 / 1,570 keys aligned |
| EN/IT key parity (Watch) | ✅ 775 / 775 keys aligned |
| Format argument parity | ✅ 0 mismatches |
| Shipped main UI localization | ⚠️ Mostly complete; **critical gaps remain** |
| Italian translation quality | ⚠️ **57+ iOS** and **32+ Watch** user-facing IT strings still English or hybrid |
| Runtime keys missing from iOS bundle | 🔴 **34 PDF export keys** + **~15 sync/CCR keys** |
| Italian-as-key anti-pattern | 🔴 Still used in sync services and legacy lookups |
| Tab split copy consistency | ⚠️ Settings tab vs screen title mismatch; stale “Gear” in EN empty states |
| Experimental / excluded views | 🔴 Hardcoded English (not in main nav) |
| Automated test guardrails | ✅ Pass; coverage gaps documented below |

**Overall verdict:** Catalog structure is mature, but **runtime string resolution, translation completeness, and copy consistency need a focused remediation pass** before calling i18n “complete.”

---

## 2. Methodology

1. Synced repository to latest `origin/main` (`9029667`).
2. Parsed and diffed `Localizable.strings` for:
   - `iOSApp/Resources/{en,it}.lproj/`
   - `Resources/{en,it}.lproj/` (Watch bundle)
3. Scanned Swift sources for:
   - `String(localized:)`, `Label("…")`, hardcoded `Text("…")`, alerts, placeholders
   - Keys referenced in code but absent from the target bundle
4. Cross-checked identical EN/IT values, hybrid strings, accent/spelling issues.
5. Reviewed accessibility keys (`a11y.*`) and VoiceOver composition patterns.
6. Ran existing localization test suites (see §14).

---

## 3. Catalog health scorecard

### iOS Companion (`iOSApp/Resources`)

| Metric | EN | IT |
|--------|---:|---:|
| Total keys | 1,570 | 1,570 |
| Keys only in one locale | 0 | 0 |
| Format specifier mismatches | 0 | — |
| Identical EN/IT values | 146 (57 likely need IT review) | — |
| `a11y.*` keys | 95 | 95 (full parity) |

### Apple Watch (`Resources/`)

| Metric | EN | IT |
|--------|---:|---:|
| Total keys | 775 | 775 |
| Keys only in one locale | 0 | 0 |
| Format specifier mismatches | 0 | — |
| Identical EN/IT values | 87 (32 likely need IT review) | — |

### Bundle separation (important)

| Bundle | Used by | Entries |
|--------|---------|--------:|
| `iOSApp/Resources/` | iOS Companion app target | 1,570 |
| `Resources/` | Watch app target | 775 |

The iOS app target **does not** embed root `Resources/`. Keys present only in the Watch bundle are **invisible to the iOS app at runtime**.

---

## 4. Critical findings (ship-blocking for bilingual quality)

### 4.1 PDF export keys missing from iOS bundle

**34** `pdf.export.*` keys are referenced from iOS PDF builders and share sheets but exist **only** in Watch `Resources/`, not in `iOSApp/Resources/`.

Examples:

- `pdf.export.briefing.overview`, `pdf.export.briefing.gas_plan`, …
- `pdf.export.share.plan`, `pdf.export.share.briefing`, `pdf.export.error.*`
- `pdf.export.section.dive_pack`, `pdf.export.checklist.yes/no`

**Impact:** English and Italian users exporting PDFs from iOS may see **raw key names** in PDF sections, share sheets, and error alerts.

**Fix:** Copy all `pdf.export.*` keys into both `iOSApp/Resources/en.lproj` and `it.lproj` (or consolidate bundles with explicit target membership).

---

### 4.2 iOS Watch sync — Italian sentences used as localization keys

`iOSApp/Services/WatchSyncService.swift` still uses Italian display text as lookup keys (not in iOS catalog):

| Key used in code | Line area | EN user impact |
|------------------|-----------|----------------|
| `Immersione aggiornata dal Watch` | ~538 | Italian text or raw key in Settings → Sync |
| `Immersione duplicata ignorata` | ~543 | Same |
| `Immersione ricevuta dal Watch` | ~554 | Same |
| `Immersione inviata al Watch` | ~667 | Same |
| `Invio Watch in coda non completato: %@` | ~683, ~1021 | Same |
| `Invio Watch in coda (transferUserInfo)` | ~694 | Same |
| `Invio Watch completato ma sessione non identificabile` | ~1026 | Same |
| `Tombstone Watch applicata (%lld)` | ~508 | Same |

**Note:** `UIUXLocalizationRemediationTests.testIOSWatchSyncServiceUsesSemanticSyncStatusKeys` passes because it only guards against two legacy keys (`Non sincronizzato`, `Attivo`). **Extend tests** to cover dive-transfer status messages.

**Fix:** Add semantic keys (`sync.dive.updated_from_watch`, etc.) to both iOS catalogs; migrate `WatchSyncService` call sites.

---

### 4.3 CCR planner — missing semantic keys in iOS catalog

`iOSApp/Views/CCR/CCRPlannerView.swift` references keys **not defined** in `iOSApp/Resources`:

- `planner.max_depth` (semantic equivalent exists: `planner.field.max_depth`)
- `planner.avg_depth`
- `planner.calculate`

**Impact:** CCR planner depth labels and calculate button may show **raw key names**.

**Fix:** Use existing `planner.field.*` keys or add missing keys to both locales.

---

### 4.4 Watch — keys missing from both catalogs

**13** runtime lookups in Watch main/services code have **no catalog entry** in either locale:

| Key / pattern | File |
|---------------|------|
| `Bussola da calibrare` | `Services/CompassManager.swift` |
| `Disponibile` | `Views/InfoView.swift` |
| `Nome file immagine non valido` | `Services/UserImageStore.swift` |
| `Dimensione immagine non valida` | `Utils/WatchCompanionPhotoValidator.swift` |
| `%lld sessioni non valide escluse dal log.` | `Services/DiveLogStore.swift` |
| `Errore import iPhone: log store non disponibile` | `Services/WatchSyncService.swift` |
| `Sessione non valida: dati immersione incoerenti.` | `Utils/DiveSessionPersistenceClass.swift` |
| Mixed sync diagnostics (`Failed: ack firmato…`, `Sent: transferUserInfo…`) | `Services/WatchSyncService.swift` |

**Impact:** English-mode Watch shows **Italian text** for compass, battery, image errors, log validation.

---

## 5. High-severity findings

### 5.1 iOS — broken or fragile lookups

| Issue | Location | Detail |
|-------|----------|--------|
| `"Cancel"` key missing | `MoreView.swift:189` | Catalog has `"Annulla" = "Cancel"` only → **Italian UI shows “Cancel”** |
| `"OK"` key informal | Multiple views | Works in EN by accident; not in catalog formally |
| `"Calcola Piano"` as key | `PlannerView.swift:1030` | Italian sentence as key; a11y always Italian-framed |
| `"Profilo attrezzatura salvato."` as key | `EquipmentView.swift`, `ChecklistView.swift` | Anti-pattern; use `equipment.profile.saved_notice` |
| Hardcoded `"READY"` badge | `ChecklistView.swift:146` | English regardless of locale |

### 5.2 Tab split copy inconsistencies (Attrezzatura / Checklist / Settings)

| Element | EN | IT | Issue |
|---------|----|----|-------|
| Tab label | `tab.settings` → Settings | Impostazioni | ✅ |
| Screen title | `more.title` → **More** | **Altro** | ⚠️ Tab says Settings; screen says More/Altro |
| Tab: Checklist | Checklist | Checklist | ⚠️ Untranslated in IT |
| Tab: Planner / Logbook | Planner / Logbook | Planner / Logbook | ⚠️ Untranslated in IT |
| Empty state CTA | `checklist.empty.open_gear` → **Open Gear** | Apri Attrezzatura | ⚠️ EN still says “Gear” after tab rename |
| Orphan key | `tab.more` | More / Altro | Unused after six-tab split |

### 5.3 Italian catalog — English or hybrid values (user-visible)

Representative issues in **IT** bundle (value still English or mixed):

| Key | IT value (problem) | Recommended IT |
|-----|-------------------|----------------|
| `%lld inviati o in transito` | `%lld sent or in transit` | `%lld inviati o in transito` |
| `%lld confermati da iPhone` | `%lld confirmed by iPhone` | `%lld confermati da iPhone` |
| `ALLARME TEMPO > %lld min` | `TIME ALARM > %lld min` | `ALLARME TEMPO > %lld min` |
| `Coda sync cancellata su richiesta` | `Sync queue cleared on request` | Full Italian |
| `detail.gps.start` / `.end` | Start / End | Partenza / Fine |
| `more.no` | No | No / Non |
| Sync `Failed: …` keys | English prefix + Italian tail | Consistent Italian diagnostics |

**Watch-only examples:** `Sync pending`, `Sync sent`, `Sync acknowledged`, `TTV sessione %@, runtime %@`, tombstone messages — IT values are English.

---

## 6. Medium-severity findings

### 6.1 Text formatting & typography

| Category | Examples | Recommendation |
|----------|----------|----------------|
| Missing accents in IT | 18 keys use `profondita` instead of `profondità` | Normalize spelling in IT catalog |
| Mixed casing | Watch `live.metric.runtime` EN `"RunTime"` vs IT `"Durata"`; compass `"RUNTIME"` | Document style guide: ALL CAPS = live metrics; sentence case = settings |
| Ellipsis inconsistency | `...` vs `…` in legacy vs semantic keys | Standardize on Unicode ellipsis |
| Unit suffixes hardcoded | `"min"` in `DiveLogListView`, `DiveDetailView`, tissue charts | Route through localized unit keys |
| Chart axis labels | `"Data"`, `"Max"`, `"Time"`, `"Depth"`, `"Profondita"` in chart `.value()` | Localize or mark as non-user-facing |

### 6.2 Localization API inconsistency

| Pattern | Usage |
|---------|-------|
| `String(localized: "semantic.key")` | Dominant (~1,100+ iOS refs) — preferred |
| `Label("tab.planner", …)` | Tab bar — SwiftUI auto-localizes string keys |
| Italian/English **display text as key** | ~20+ call sites — high maintenance risk |
| `NSLocalizedString` / `L10n` enum | Not used |

**Recommendation:** Standardize on semantic keys; eliminate display-text-as-key pattern.

### 6.3 Orphan & legacy catalog entries

- **114** semantic keys in iOS catalog appear unused by iOS Swift (includes orphaned `tab.more`, legacy import error keys, unused a11y entries).
- Duplicate `watch.nav.back` entry in both catalogs.
- Legacy Italian-sentence keys retained for backward compatibility (`Avvia una nuova sessione…`, etc.).

---

## 7. Low-severity / acceptable

| Item | Notes |
|------|-------|
| Brand strings `DIR DIVING`, `DIR`, `CROWN` | Intentional; optional centralization |
| Dive-computer tokens `GAS`, `BAR`, `PSI`, `MOD`, `CCR`, `SMB`, `BOV` | Technical abbreviations; acceptable in both locales |
| `Button("-")` / `Button("+")` steppers | Symbols; partial a11y coverage exists |
| Numeric-only displays | `%`, depths, counts — format via `Formatters` |
| Experimental views excluded from targets | `BuddyExperimentalView`, `ExplorationCenterView`, `ExperimentalFutureConceptsView`, Watch Apnea/Snorkeling/Buddy — hardcoded English/IT mix; **not shipped** |

---

## 8. Accessibility text audit

### Strengths

- Full **95/95** `a11y.*` key parity (iOS EN/IT).
- Watch live dive, compass, depth safety, legal toggles, log delete — good coverage.
- Recent tab split: checklist setup card, image transfer panel — accessibility extended.

### Gaps

| Severity | Area | Issue |
|----------|------|-------|
| High | Watch `SettingsView` | `settings.a11y.language/units/haptics` defined but not wired to pickers |
| High | Watch `AlarmSettingsView` | Toggle rows hidden labels; no row-level a11y |
| Medium | iOS interpolated a11y | `DIRMetricTile`, `DiveDetailView`, `PlannerView` concatenate English-centric `"."` separators |
| Low | 12 unused `a11y.*` keys in iOS catalog | Wire or remove |

**VoiceOver order (Checklist tab):** title → subtitle → setup card → groups → GAS/BAR/PSI → actions — structurally correct; fix `READY` badge language.

---

## 9. Shipped feature areas — per-area status

| Feature area | iOS EN | iOS IT | Watch EN | Watch IT |
|--------------|--------|--------|----------|----------|
| Planner (Base/Deco/Tech) | ✅ | ⚠️ tab label EN | — | — |
| CCR Planner | ⚠️ missing keys | ⚠️ | — | — |
| Logbook | ✅ | ⚠️ tab label EN | ✅ | ⚠️ sync strings |
| Analisi / Analysis | ✅ | ✅ | — | — |
| Attrezzatura / Equipment | ✅ | ✅ | — | — |
| Checklist (tab split) | ⚠️ READY badge, Gear CTA | ⚠️ setup anglicisms | — | — |
| Settings / More | ⚠️ title mismatch | ⚠️ Altro vs Impostazioni | ✅ | ⚠️ a11y gaps |
| Watch sync status | ⚠️ Italian-as-key | ⚠️ hybrid IT values | ⚠️ missing keys | ⚠️ English IT values |
| PDF export/share | 🔴 34 keys missing iOS | 🔴 | ✅ in Watch bundle | ✅ |
| Legal onboarding | ✅ | ✅ | ✅ | ✅ |
| Import (CSV/Subsurface) | ✅ semantic keys | ✅ | — | — |
| Photo transfer / inventory | ✅ | ✅ | ⚠️ error keys | ⚠️ |

---

## 10. Text formatting style guide (recommended)

Document and enforce:

1. **Live dive metrics (Watch):** ALL CAPS labels (`PROFONDITÀ ATTUALE`, `RUNTIME`).
2. **Settings & prose:** Sentence case (`Ascent rate`, `Impostazioni legali`).
3. **Tabs (iOS):** Short localized nouns — translate Planner/Logbook/Checklist in IT or document intentional anglicisms.
4. **Units:** Never hardcode `"min"`, `"m"`, `"ft"` in views; use catalog keys or `Formatters` with locale.
5. **Ellipsis:** Use `…` (U+2026) consistently.
6. **Italian diacritics:** Always `profondità`, `velocità`, `Sì`, `disponibilità`.
7. **Sync diagnostics:** Full sentences per locale; no `Failed:` English prefix in IT bundle.
8. **Keys:** Semantic dot-notation only; never user-visible sentences as keys.

---

## 11. Prioritized remediation roadmap

### P0 — Critical (before calling i18n complete)

1. Add **34 `pdf.export.*` keys** to `iOSApp/Resources` (EN + IT).
2. Migrate **iOS `WatchSyncService`** dive-transfer messages to semantic keys.
3. Fix **CCR planner** missing keys (`planner.calculate`, depth labels).
4. Add **13 missing Watch keys** (`compass.status.*`, `info.available`, image/log validation errors).

### P1 — High (bilingual UX quality)

5. Fix `"Cancel"` → `"Annulla"` / `manual_dive.cancel` in `MoreView`.
6. Localize Checklist **`READY`** progress badge.
7. Align **Settings tab** label with screen title (`more.title` → Settings / Impostazioni).
8. Update EN **`checklist.empty.open_gear`** to “Open Equipment”.
9. Translate **IT tab labels** and top **sync counter** strings still in English.

### P2 — Medium (polish)

10. Replace Italian-as-key lookups (`Calcola Piano`, saved profile toast, etc.).
11. Fix **18 `profondita` → `profondità`** IT entries.
12. Wire Watch **settings/alarm a11y** keys.
13. Localize chart axis labels and hardcoded `"min"` suffixes.
14. Clean orphan catalog keys (`tab.more`, duplicates).

### P3 — Low (housekeeping)

15. Localize or remove experimental views from repo.
16. Extend automated tests (see §12).
17. Document intentional identical EN/IT tokens (brands, acronyms).

---

## 12. Recommended automated test extensions

Existing suites pass but do not cover all gaps:

| New test | Purpose |
|----------|---------|
| `IOSPDFExportLocalizationTests` | Every `pdf.export.*` used in iOS code exists in `iOSApp/Resources` EN+IT |
| `IOSWatchSyncSemanticKeysTests` | No Italian-sentence keys in `iOSApp/Services/WatchSyncService.swift` |
| `IOSCatalogParityNoEnglishInITTests` | Flag IT values identical to EN except allowlist (brands, acronyms) |
| `IOSCCRLocalizationKeysTests` | CCR planner keys resolve in both locales |
| Extend `WatchLocalizationStaticSweepTests` | Cover compass/info/image error keys |
| `IOSChecklistCopyConsistencyTests` | No hardcoded `"READY"`; Settings tab/title alignment |

---

## 13. Manual QA checklist (i18n)

Run on **iPhone 15 Pro** simulator with **Settings → Language** = English, then Italian.

- [ ] All six tab labels readable; no truncation at default Dynamic Type.
- [ ] Settings tab label matches screen title (currently **fails**: Settings vs More/Altro).
- [ ] Checklist progress badge localized (currently **fails**: shows “READY” in EN layout).
- [ ] Checklist empty state CTA: EN says Equipment not Gear.
- [ ] Settings → Sync status messages in correct language during Watch transfer.
- [ ] CCR planner: depth fields and Calculate button show words, not raw keys.
- [ ] PDF export (plan, checklist, briefing, dive pack): section titles localized in PDF body.
- [ ] PDF share sheet and error alerts localized.
- [ ] Logbook gas filters, equipment GAS/BAR/PSI toggles — labels correct both locales.
- [ ] VoiceOver: checklist items, setup card, tab bar order sensible.
- [ ] Watch (Italian): compass calibrate message, battery `n/d`, alarm labels in Italian.
- [ ] Watch Settings pickers announce language/units/haptics in VoiceOver.

---

## 14. Validation performed for this audit

| Check | Result |
|-------|--------|
| Git HEAD | `9029667` on `main`, up to date with `origin/main` |
| Catalog key parity script | iOS 1570/1570, Watch 775/775, 0 format mismatches |
| `UIUXLocalizationRemediationTests` | **TEST SUCCEEDED** |
| `PlannerLocalizationTests` | **TEST SUCCEEDED** |
| `IOSLegalSettingsLocalizationTests` | **TEST SUCCEEDED** |
| `WatchLocalizationStaticSweepTests` | **TEST SUCCEEDED** |
| `WatchMainUILocalizationTests` | **TEST SUCCEEDED** |

---

## 15. Conclusion — is internationalization complete?

**No — not yet complete**, though the **foundation is solid**:

✅ **Complete today:** catalog parity, format arguments, legal/planner core keys, tab-split Attrezzatura/Checklist semantic keys, import error keys, a11y key parity, automated regression tests for prior remediation work.

❌ **Incomplete:** iOS PDF export bundle gap (34 keys), iOS Watch sync legacy Italian keys, CCR missing keys, Watch missing runtime keys, ~90 iOS + ~36 Watch IT strings still English or hybrid, Settings/More title mismatch, hardcoded Checklist “READY”, and accessibility wiring gaps on Watch settings/alarms.

**Estimated remediation:** P0 items are a **1–2 day** focused pass; full P0–P2 polish is **3–5 days** including test extensions and manual QA on both locales.

---

## 16. Files referenced

| Path | Role |
|------|------|
| `iOSApp/Resources/en.lproj/Localizable.strings` | iOS English catalog |
| `iOSApp/Resources/it.lproj/Localizable.strings` | iOS Italian catalog |
| `Resources/en.lproj/Localizable.strings` | Watch English catalog |
| `Resources/it.lproj/Localizable.strings` | Watch Italian catalog |
| `iOSApp/Services/WatchSyncService.swift` | iOS sync status messages |
| `iOSApp/Views/ChecklistView.swift` | Checklist tab copy |
| `iOSApp/Views/ContentView.swift` | Tab bar |
| `iOSApp/Views/MoreView.swift` | Settings screen |
| `iOSApp/Views/CCR/CCRPlannerView.swift` | CCR missing keys |
| `iOSApp/Services/PDF/*.swift` | PDF export key usage |
| `Services/CompassManager.swift` | Watch compass status |
| `Tests/iOSAlgorithmTests/UIUXLocalizationRemediationTests.swift` | iOS guardrails |
| `Tests/WatchAlgorithmTests/WatchLocalizationStaticSweepTests.swift` | Watch guardrails |

---

*Report generated from static analysis and automated catalog comparison on `main` @ `9029667`. No product code was modified for this audit.*
