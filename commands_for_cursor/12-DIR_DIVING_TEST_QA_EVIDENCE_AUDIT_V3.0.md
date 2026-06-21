# 12-DIR_DIVING_TEST_QA_EVIDENCE_AUDIT_V3.0

**Command version:** 3.0  
**Updated for MAIN:** 2026-06-21
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

Audit automated tests, simulator QA, physical-device QA, external validation and evidence traceability.

# SCOPE

Create a requirement-to-test matrix covering:

- startup and activity selection;
- Gauge;
- Full Computer;
- Bühlmann;
- gas switching;
- deco stop state machine;
- Apnea lifecycle/recovery;
- Snorkeling GPS/dips/navigation;
- Settings isolation;
- Logbook ownership;
- sync/schema;
- migration;
- backup/restore;
- localization/accessibility;
- security;
- performance;
- exports.
- Watch Full Computer pre-dive absolute-altitude acquisition and proposal acceptance.

Classify evidence:

- automated unit;
- integration;
- UI/snapshot;
- simulator;
- physical Watch;
- physical iPhone;
- paired-device;
- underwater;
- external reference;
- legal/compliance review.

No evidence means not passed.

## Mandatory Watch altimeter evidence gate

Trace the production Watch path from `CMAltimeter.startAbsoluteAltitudeUpdates(to:withHandler:)` through `CMAbsoluteAltitudeData` sample validation to the pending pre-dive environment proposal. Evidence must prove that the sample is acquired immediately before Full Computer start, is fresh, sufficiently accurate and stable, remains non-authoritative until explicit diver acceptance, and cannot silently replace an imported iPhone Plan or manual Watch setting.

Require automated injected-provider coverage for unavailable/error/timeout/inaccurate/unstable/stale/near-zero/elevated samples, acceptance, rejection, and cancellation. Require physical Apple Watch evidence for a real Core Motion sample; simulator-only evidence is insufficient. Treat cached `CLLocationManager.location.altitude`, hard-coded altitude, implicit sea-level fallback, missing sensor metadata, or an unretained asynchronous provider as a failed safety requirement.

# OUTPUT

Create:

- `Docs/TEST_QA_EVIDENCE_AUDIT_CURRENT.md`
- `Docs/REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv`
- `Docs/PHYSICAL_DEVICE_QA_MATRIX_CURRENT.csv`
- `Docs/EXTERNAL_VALIDATION_GAPS_CURRENT.md`
- `Docs/READINESS_TO_100_PLAN_CURRENT.md`
