# 10-DIR_DIVING_PERFORMANCE_CONCURRENCY_BATTERY_AUDIT_V3.0

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

Audit runtime performance, numerical workload, concurrency, memory, thermal and battery behavior across Watch and iOS.

# SCOPE

## Watch

- one-second Full Computer tissue updates;
- sensor sampling;
- GPS;
- haptics;
- reminders;
- Mission Mode invariants;
- Apnea lifecycle;
- Snorkeling GPS/navigation;
- timers/tasks;
- background transitions;
- WatchConnectivity;
- image/card decoding;
- small-screen rendering.

## iOS

- planner recomputation;
- charts;
- maps;
- large Logbooks;
- large GPS tracks;
- tissue histories;
- exports;
- backup;
- sync import;
- SwiftUI invalidation;
- cancellation/stale result publication.

Audit actor isolation, Sendable correctness, retain cycles, uncancelled tasks, timer duplication, race conditions and main-thread blocking.

# OUTPUT

Create:

- `Docs/PERFORMANCE_CONCURRENCY_BATTERY_AUDIT_CURRENT.md`
- `Docs/PERFORMANCE_BUDGET_MATRIX_CURRENT.csv`
- `Docs/CONCURRENCY_RISK_MATRIX_CURRENT.csv`
- `Docs/PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md`

Separate simulator evidence from physical Watch/iPhone evidence.
