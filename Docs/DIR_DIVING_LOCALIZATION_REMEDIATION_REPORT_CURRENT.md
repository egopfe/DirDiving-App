# DIR DIVING — Localization Remediation Report (Current)

**Date:** 2026-06-02  
**Command:** 13 — Complete IT/EN localization audit and remediation  
**Branch:** `integration/full-computer`  
**Audit:** [`DIR_DIVING_LOCALIZATION_AUDIT_CURRENT.md`](DIR_DIVING_LOCALIZATION_AUDIT_CURRENT.md)

---

## Summary

Focused remediation closed all **blocking** localization gaps in Watch MAIN and iOS Companion production code. Added repository-wide audit automation, bilingual inventory export, and deterministic tests.

**Result:** `CONDITIONAL PASS`

---

## Code changes

| File | Change |
|------|--------|
| `Resources/{en,it}.lproj/Localizable.strings` | Sync legacy warning, FC imported plan formats |
| `Views/FullComputerImportedPlanView.swift` | Localized technical header + runtime minutes |
| `iOSApp/Resources/{en,it}.lproj/Localizable.strings` | Logbook gas, planner metrics, sync replay error |
| `iOSApp/Views/PlannerView.swift` | `Planner` → `tab.planner` |
| `iOSApp/Views/CCR/*.swift` | Semantic key remapping |
| `Scripts/audit_localization.sh` | New audit gate |
| `Tests/.../DIRDivingCompleteLocalizationAuditTests.swift` | Watch + iOS tests |

---

## Tests executed

- `./Scripts/audit_localization.sh` — PASS
- `DIRDivingCompleteLocalizationAuditTests` (Watch + iOS) — PASS
- Watch + iOS builds — PASS

---

## Exemptions

| Exemption | Reason |
|-----------|--------|
| `DIR DIVING` brand | Product name |
| `CROWN` | Hardware control label |
| Experimental Apnea/Snorkeling/Buddy views | Not in MAIN target |
| Legacy sentence-as-key entries | Backward compatibility |

---

## Remaining work

1. Experimental activity UIs when features ship on MAIN.
2. Physical bilingual layout on 41 mm Watch + iPhone SE.
3. Optional `.stringsdict` plural migration.
