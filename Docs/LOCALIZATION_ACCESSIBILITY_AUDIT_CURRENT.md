# DIR DIVING — Localization & Accessibility Audit (Current)

**Command:** 11 — `11-DIR_DIVING_LOCALIZATION_ACCESSIBILITY_AUDIT_V3.0`  
**Date:** 2026-06-20  
**Branch:** `main`  
**Preflight HEAD:** `8cd51d6`  
**Working tree:** Dirty (security, performance, and prior audit deliverables uncommitted; evaluated as current implementation truth)  
**Task type:** Read-only audit (reports only)

**Not claimed:** Physical VoiceOver walkthrough on all device sizes, Dynamic Type XL layout verification on 41 mm Watch / smallest iPhone, or color-contrast measurement with external tools.

---

## Executive summary

Repository-wide **Italian/English localization** for Watch MAIN and iOS Companion shows **100% catalog key parity** (1,243 Watch keys; 2,548 iOS keys). All semantic keys referenced in production Swift resolve in both locales. Automated gate reports **zero blocking hardcoded Watch MAIN UI strings**.

**Accessibility** is strong at the **software-contract** level: localized VoiceOver labels/hints on critical Diving, Full Computer, Planner, CCR, Apnea, and Snorkeling surfaces; chart/map summary helpers; static identifier contracts in tests. **Physical accessibility QA** (Dynamic Type stress, smallest Watch, Ultra, full VoiceOver field passes) remains **PENDING**.

| Dimension | Score (0–100) | Notes |
|-----------|---------------|-------|
| IT/EN key parity | **100** | Watch + iOS catalogs aligned |
| Semantic key resolution | **100** | 554 Watch + 1,061 iOS keys used in code |
| Hardcoded MAIN UI strings | **98** | 0 blocking on Watch MAIN gate |
| Terminology isolation | **95** | TTV/TTS, dive/dip, CNS/OTU policies enforced |
| VoiceOver label coverage | **88** | Localized; field QA open |
| Dynamic Type / layout | **75** | SwiftUI defaults; physical XL QA pending |
| Reduced motion | **70** | Mission Mode reduces decorative motion; no global `@Environment(\.accessibilityReduceMotion)` audit |
| Chart/map summaries | **90** | Planner + CCR + tissue analytics summaries |
| Export/PDF localization | **92** | Active locale at export; stable JSON field names |
| **Overall static l10n/a11y readiness** | **91** | Strong automation; physical a11y QA is primary gap |

**P0:** 0  
**P1:** 0  
**P2:** 3 open (physical a11y)  
**P3:** 4 open (plural catalogs, legacy keys, experimental UI)  
**INFO:** 6 positive controls

---

## Preflight

| Check | Result |
|-------|--------|
| Branch | `main` |
| HEAD | `8cd51d6` |
| `origin/main` | Aligned at audit start |
| `./Scripts/audit_localization.sh` | **PASS** |
| Physical a11y QA | Not executed |

---

## Localization — key parity

| Target | EN keys | IT keys | Semantic keys in production code |
|--------|--------:|--------:|--------------------------------:|
| Watch MAIN | 1,243 | 1,243 | 554 |
| iOS Companion | 2,548 | 2,548 | 1,061 |
| **Inventory rows** | — | — | 2,237 (merged catalog) |

Inventory: [`LOCALIZATION_KEY_INVENTORY_CURRENT.csv`](LOCALIZATION_KEY_INVENTORY_CURRENT.csv)

---

## Hardcoded strings

| Area | Gate | Result |
|------|------|--------|
| Watch MAIN (`App/`, `Views/`, `Services/`, `Utils/`) | `audit_localization.sh` hardcoded scan | **0 blocking** |
| iOS production (`iOSApp/` excl. experimental lab) | Semantic resolution | **PASS** |
| Experimental Apnea/Snorkeling/Buddy lab views | Excluded from MAIN | Hardcoded reference UI documented |

---

## Plurals & interpolation

- **Plurals:** No `.stringsdict` catalogs; pluralization via `%d` / `%lld` format strings (e.g. `apnea.ready.alarms_count`). **Accepted** for current scope; `.stringsdict` migration is a P3 enhancement.
- **Interpolation:** Placeholder parity verified by `DIRDivingCompleteLocalizationAuditTests`; audit script flags `TODO`/`TBD` placeholders — **none blocking**.

---

## Locale-aware units, dates, numbers

- Depth/pressure/temperature via `Formatters`, `IOSUnitPreference`, planner unit settings.
- Logbook and export formatters use locale-aware `DateFormatter` / `formatted()` where user-facing.
- PDF/export uses active app locale (`DIRIOSLocalizer` / `String(localized:)`).

---

## Terminology isolation (mandatory checks)

| Rule | Status | Evidence |
|------|--------|----------|
| Gauge **TTV** vs Full Computer **TTS** | **PASS** | Separate keys; glossary; `WatchGaugeMathCompletionTests.testTTVRemainsIsolatedFromFullComputerPlan` |
| **Ceiling** vs stop depth | **PASS** | `fc.*`, `deco.*`, `planner.*` keys; stop panel uses stop depth labels |
| Diving **dive** vs Apnea **dive** vs Snorkeling **dip** | **PASS** | Separate key namespaces (`dive.*`, `apnea.*`, `snorkeling.*`) |
| Surface GPS only (Snorkeling) | **PASS** | `settings.a11y.gps_surface.diving` vs `settings.a11y.gps_route.snorkeling` |
| **CNS/OTU** only in Diving planner | **PASS** | Keys under `planner.*`; absent from Apnea/Snorkeling catalogs |

Glossary: [`TERMINOLOGY_GLOSSARY_IT_EN_CURRENT.md`](TERMINOLOGY_GLOSSARY_IT_EN_CURRENT.md)

---

## Accessibility — software coverage

### VoiceOver

- Watch: `DiveLiveView`, Full Computer panels, alarms, settings, Apnea/Snorkeling production views — localized `accessibilityLabel` / `accessibilityHint` / identifiers.
- iOS: `PlannerView` (33+ label sites), CCR result charts, tissue analytics, logbook, checklist, photo transfer panel.
- Chart summaries: `UIUXAccessibilitySummaries`, `planner.buhlmann.tissue_chart.a11y.*`, `ccr.a11y.*.summary`.

### Dynamic Type

- SwiftUI `Text` / system fonts inherit Dynamic Type scaling on iOS and watchOS.
- **Physical verification** at AX5/XL on 41 mm Watch and smallest iPhone: **PENDING** (L10N-A11Y-P2-001).

### Contrast & reduced motion

- Safety banners use theme colors (`DIRTheme`) with existing UI/UX audit baselines.
- `MissionModeRuntimeProfile` disables decorative animations; no app-wide reduced-motion branching audited — **P3**.

### Haptic-only states

- Haptics-off badge exposes visible + VoiceOver text (`a11y.watch.haptics_off_badge.*`); safety alerts remain on-screen.

### Disabled-feature explanations

- Settings and predive surfaces use localized unavailable/degraded copy (GPS, sensor, recovery warnings).

---

## Activity coverage matrix

See [`ACCESSIBILITY_SCREEN_MATRIX_CURRENT.csv`](ACCESSIBILITY_SCREEN_MATRIX_CURRENT.csv).

---

## Findings register

### L10N-A11Y-P2-001 — Physical VoiceOver / Dynamic Type QA pending

**Severity:** P2  
**Status:** OPEN (QA)  
No complete field pass on 41 mm Watch, Watch Ultra, and smallest supported iPhone at largest Dynamic Type.

### L10N-A11Y-P2-002 — Italian string length on smallest Watch

**Severity:** P2  
**Status:** OPEN (QA)  
Catalog parity PASS; truncation/wrapping on 41 mm not physically verified.

### L10N-A11Y-P2-003 — Snorkeling VoiceOver field evidence pending

**Severity:** P2  
**Status:** OPEN (QA)  
`Docs/QA_EVIDENCE/SNORKELING_VOICEOVER/PROCEDURE.md` exists; status **PENDING** per contract test.

### L10N-A11Y-P3-001 — No `.stringsdict` plural catalogs

**Severity:** P3  
**Status:** OPEN  
Plurals via format strings; acceptable for current release scope.

### L10N-A11Y-P3-002 — Legacy sentence-as-key entries

**Severity:** P3  
**Status:** OPEN  
Backward-compatible keys remain in catalogs.

### L10N-A11Y-P3-003 — Experimental lab views hardcoded

**Severity:** P3  
**Status:** ACCEPTED  
Excluded from MAIN target navigation.

### L10N-A11Y-P3-004 — Reduced motion not globally branched

**Severity:** P3  
**Status:** OPEN  
Mission Mode reduces decorative effects; no repository-wide `accessibilityReduceMotion` policy file.

---

## Positive controls (INFO)

| ID | Control |
|----|---------|
| INFO-01 | `audit_localization.sh` — parity + hardcoded gate |
| INFO-02 | `DIRDivingCompleteLocalizationAuditTests` Watch + iOS |
| INFO-03 | `SnorkelingAccessibilityContractTests` — identifier contracts |
| INFO-04 | `UIUXRemediationV3AccessibilityTests` — CCR/chart a11y keys |
| INFO-05 | Activity-owned GPS a11y labels (Diving vs Snorkeling) |
| INFO-06 | Export locale follows active app language |

---

## Tests executed (simulator / static)

- `./Scripts/audit_localization.sh` — **PASS**
- Referenced (not re-run in this pass): `DIRDivingCompleteLocalizationAuditTests`, `SnorkelingAccessibilityContractTests`, `UIUXRemediationV3AccessibilityTests`

---

## Related artifacts

- [`LOCALIZATION_KEY_INVENTORY_CURRENT.csv`](LOCALIZATION_KEY_INVENTORY_CURRENT.csv)
- [`ACCESSIBILITY_SCREEN_MATRIX_CURRENT.csv`](ACCESSIBILITY_SCREEN_MATRIX_CURRENT.csv)
- [`TERMINOLOGY_GLOSSARY_IT_EN_CURRENT.md`](TERMINOLOGY_GLOSSARY_IT_EN_CURRENT.md)
- [`DIR_DIVING_LOCALIZATION_AUDIT_CURRENT.md`](DIR_DIVING_LOCALIZATION_AUDIT_CURRENT.md) (automation output)
- [`DIR_DIVING_LOCALIZATION_KEY_INVENTORY_CURRENT.csv`](DIR_DIVING_LOCALIZATION_KEY_INVENTORY_CURRENT.csv)

---

## Verdict

**CONDITIONAL PASS** at **91/100** static localization/accessibility readiness. Catalog parity and software accessibility contracts are strong; **physical VoiceOver and Dynamic Type QA** remain the primary gaps before claiming production-grade accessibility on hardware.
