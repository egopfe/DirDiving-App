# 14-DIR_DIVING_MOCKUP_VISUAL_REGRESSION_AUDIT_V3.0

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

Perform a dedicated mockup-path, visual-fidelity and deterministic-state audit.

# SCOPE

Recursively inventory `mockups/**`.

For every mockup verify:

- path existence;
- exact casing;
- dimensions/hash;
- owning platform;
- owning activity;
- screen/state;
- source view;
- presentation model;
- feature flag;
- preview fixture;
- snapshot;
- Italian/English;
- smallest/large device;
- visual fidelity;
- functional fidelity;
- accessibility.

Audit iOS and Watch startup selection, all vertical feature screens, Shared Settings, activity Settings and strict Logbook ownership.

No mockup may be embedded as live UI.

# OUTPUT

Create:

- `Docs/MOCKUP_VISUAL_REGRESSION_AUDIT_CURRENT.md`
- `Docs/MOCKUP_PATH_VALIDATION_CURRENT.csv`
- `Docs/MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv`
- `Docs/VISUAL_REGRESSION_COVERAGE_MATRIX_CURRENT.csv`
- `Docs/UI_UX_REMEDIATION_PLAN_CURRENT.md`
