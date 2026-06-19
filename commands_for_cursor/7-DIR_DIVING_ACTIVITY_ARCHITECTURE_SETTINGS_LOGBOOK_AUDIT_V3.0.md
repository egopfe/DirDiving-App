# 7-DIR_DIVING_ACTIVITY_ARCHITECTURE_SETTINGS_LOGBOOK_AUDIT_V3.0

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

Audit the complete multi-activity architecture:

```text
Diving → Gauge / Full Computer
Apnea
Snorkeling
```

Verify startup selection on iOS and Watch, activity-owned roots, vertical features, Settings ownership and strict Logbook ownership.

# REQUIRED CHECKS

## Root flow

- onboarding/legal gate;
- iOS activity selection;
- Watch activity selection;
- Diving mode selection;
- preference persistence;
- migration;
- feature flags;
- active-session lock;
- deep links;
- state restoration.

## Settings

Audit:

- `SharedSettingsStore`;
- `DivingSettingsStore`;
- `ApneaSettingsStore`;
- `SnorkelingSettingsStore`;
- namespaces;
- migrations;
- target membership;
- Watch/iOS sync policy.

Negative tests:

- CNS/PPO2/GF/gas/deco absent from Apnea/Snorkeling;
- Apnea recovery/targets absent from Diving/Snorkeling;
- GPS/route/return absent from Diving/Apnea.

## Logbooks

Verify:

```text
Diving section → Diving Logbook only
Apnea section → Apnea Logbook only
Snorkeling section → Snorkeling Logbook only
```

Test all six forbidden cross-activity routes.

# OUTPUT

Create:

- `Docs/ACTIVITY_ARCHITECTURE_SETTINGS_LOGBOOK_AUDIT_CURRENT.md`
- `Docs/ACTIVITY_FEATURE_OWNERSHIP_MATRIX_CURRENT.csv`
- `Docs/ACTIVITY_SETTINGS_COHERENCE_MATRIX_CURRENT.csv`
- `Docs/LOGBOOK_OWNERSHIP_ROUTING_MATRIX_CURRENT.csv`

Score each activity and cross-activity isolation from 0–100. Any wrong Logbook or Settings exposure is P0/P1 depending on data/safety impact.
