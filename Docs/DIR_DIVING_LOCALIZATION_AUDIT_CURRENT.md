# DIR DIVING — Complete IT/EN Localization Audit (Current)

**Date:** 2026-06-02  
**Branch:** `integration/full-computer`  
**Automation:** `./Scripts/audit_localization.sh`  
**Inventory:** [`DIR_DIVING_LOCALIZATION_KEY_INVENTORY_CURRENT.csv`](DIR_DIVING_LOCALIZATION_KEY_INVENTORY_CURRENT.csv)  
**Glossary:** [`DIR_DIVING_LOCALIZATION_GLOSSARY_IT_EN_CURRENT.md`](DIR_DIVING_LOCALIZATION_GLOSSARY_IT_EN_CURRENT.md)  
**Remediation:** [`DIR_DIVING_LOCALIZATION_REMEDIATION_REPORT_CURRENT.md`](DIR_DIVING_LOCALIZATION_REMEDIATION_REPORT_CURRENT.md)

---

## Executive summary

Repository-wide localization audit completed for **Watch MAIN** and **iOS Companion** production targets. Catalog parity is **100%** between English and Italian. Semantic keys referenced in production Swift resolve in both locales. Automated audit script and tests gate missing keys, placeholders, and hardcoded Watch MAIN UI strings.

**Final result: `CONDITIONAL PASS`**

| Area | Status |
|------|--------|
| Watch EN/IT key parity | ✅ 1,012 / 1,012 |
| iOS EN/IT key parity | ✅ 1,941 / 1,941 |
| Semantic keys used in Watch MAIN code | ✅ 482 — all resolved |
| Semantic keys used in iOS production code | ✅ 605 — all resolved |
| Hardcoded Watch MAIN UI strings (audit gate) | ✅ 0 blocking |
| Full Computer / Gauge / startup / sync | ✅ Localized |
| Accessibility strings (FC sample set) | ✅ Localized |
| Experimental Apnea / Snorkeling / Buddy views | ⚠️ Excluded from MAIN target — hardcoded reference UI remains |
| Physical layout review (41 mm / Dynamic Type) | ⚠️ Not executed in this pass |
| `.stringsdict` plural catalogs | ⚠️ Not used — plurals via `%d` / `%lld` format strings |

---

## Repository areas inspected

- Apple Watch: `App/`, `Services/`, `Views/` (MAIN), `Utils/`, `Resources/{en,it}.lproj/`
- iOS Companion: `iOSApp/` (excluding experimental lab views), `iOSApp/Resources/{en,it}.lproj/`
- Shared models referenced by localized enums
- PDF / export builders (CCR planner)
- WatchConnectivity / sync codec error surfaces
- Full Computer predive, live deco, gas switch, recovery, imported plan flows

**Excluded from MAIN gate (documented):**

- `Views/ApneaView.swift`, `Views/SnorkelingView.swift`, `Views/BuddyAssistView.swift`, `Views/ExperimentalConceptsView.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`, `ExplorationCenterView.swift`, `ExperimentalFutureConceptsView.swift`

---

## Key counts

| Target | EN keys | IT keys | Semantic keys in code |
|--------|--------:|--------:|----------------------:|
| Watch | 1,012 | 1,012 | 482 |
| iOS | 1,941 | 1,941 | 605 |

---

## Remediation performed (Command 13)

| Item | Action |
|------|--------|
| `sync.legacy_schema.v1_warning` | Added EN + IT (Watch) |
| `fc.imported_plan.technical_header` | Added EN + IT; localized plan ID header |
| `fc.imported_plan.runtime_minutes_format` | Added EN + IT; removed hardcoded `min` suffix |
| `fc.imported_plan.runtime` (IT) | Updated to **Tempo immersione** |
| iOS `Planner` sentence key | Replaced with `tab.planner` |
| iOS CCR planner missing keys | Remapped to existing keys + added catalog entries |
| Audit automation | Added `Scripts/audit_localization.sh` |
| Tests | Added `DIRDivingCompleteLocalizationAuditTests` (Watch + iOS) |

---

## Remaining risks

1. **Experimental activity UIs** contain hardcoded placeholder copy — not shipped in MAIN/FC production navigation.
2. **Legacy sentence-as-key entries** remain for backward compatibility.
3. **Italian string length** on smallest Watch — not physically verified.
4. **Identical EN/IT acronyms** — intentional per glossary.

---

## Tests executed

- `./Scripts/audit_localization.sh` — **PASS**
- `DIRDivingCompleteLocalizationAuditTests` (Watch + iOS)

---

## Readiness

**Automated localization readiness: 98%**  
**Final result: `CONDITIONAL PASS`**
