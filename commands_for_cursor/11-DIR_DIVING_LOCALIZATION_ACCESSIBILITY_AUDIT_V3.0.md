# 11-DIR_DIVING_LOCALIZATION_ACCESSIBILITY_AUDIT_V3.0

**Command version:** 3.0  
**Updated for MAIN:** 2026-06-19  
**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Task type:** audit-only

## ABSOLUTE EXECUTION RULE

This is a read-only audit. Do not modify production code, tests, project configuration, assets, mockups, localization resources or runtime documentation. Generate only the requested audit reports. Do not commit or push.

Run preflight:

```bash
git branch --show-current
git rev-parse --short HEAD
git status
git fetch origin
git status -sb
```

STOP if the branch is not `main`. Record environmental limitations. Do not fix failures.


# OBJECTIVE

Audit complete Italian/English localization and accessibility for every activity, setting, Logbook, alert, chart, map, export and error state.

# SCOPE

- key parity;
- hardcoded strings;
- plurals;
- interpolation;
- locale-aware units/dates/numbers;
- activity-specific terminology;
- no cross-activity labels;
- VoiceOver;
- Dynamic Type;
- contrast;
- reduced motion;
- chart summaries;
- map summaries;
- arrow semantics;
- haptic-only states;
- disabled-feature explanations;
- smallest Watch;
- Ultra;
- supported iPhones;
- PDF/export localization.

Mandatory terminology checks:

- Gauge TTV vs Full Computer TTS;
- Ceiling vs stop depth;
- Diving dive vs Apnea dive vs Snorkeling dip;
- surface GPS only;
- CNS/OTU only in Diving.

# OUTPUT

Create:

- `Docs/LOCALIZATION_ACCESSIBILITY_AUDIT_CURRENT.md`
- `Docs/LOCALIZATION_KEY_INVENTORY_CURRENT.csv`
- `Docs/ACCESSIBILITY_SCREEN_MATRIX_CURRENT.csv`
- `Docs/TERMINOLOGY_GLOSSARY_IT_EN_CURRENT.md`
