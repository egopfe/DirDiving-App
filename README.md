# DIR DIVING

Copyright Federico Lombardo di Monte Iato 2026

**Canonical project documentation** lives in [`Docs/README.md`](Docs/README.md).

Quick links:

| Topic | Document |
|-------|----------|
| Documentation index | [`Docs/INDEX.md`](Docs/INDEX.md) |
| Branch strategy | [`Docs/README.md`](Docs/README.md#strategia-dei-rami-branch-strategy) |
| Build / XcodeGen | [`Docs/BUILD_AND_XCODEGEN_WORKFLOW.md`](Docs/BUILD_AND_XCODEGEN_WORKFLOW.md) |
| Safety disclaimer | [`Docs/SAFETY_DISCLAIMER.md`](Docs/SAFETY_DISCLAIMER.md) |
| Feature matrix (CSV) | [`Docs/DIR_DIVING_Feature_Comparison.csv`](Docs/DIR_DIVING_Feature_Comparison.csv) |
| Release / TestFlight | [`Docs/RELEASE_CHECKLIST.md`](Docs/RELEASE_CHECKLIST.md) |

**Full Computer on `main`:** Bühlmann ZH-L16C decompressive runtime on Watch — **not certified**. See [`Docs/FULL_COMPUTER_ARCHITECTURE.md`](Docs/FULL_COMPUTER_ARCHITECTURE.md), `./Scripts/validate_full_computer_release_readiness.sh` and `./Scripts/validate_watch_complete_algorithm_readiness.sh`.

**Localization:** run `./Scripts/audit_localization.sh` for EN/IT parity gate. See [`Docs/DIR_DIVING_LOCALIZATION_AUDIT_CURRENT.md`](Docs/DIR_DIVING_LOCALIZATION_AUDIT_CURRENT.md).

**Release baseline (`main`):** `origin/main` @ **`0d3a26b`** — orchestrator V1.5 audit @ `2c30412`: **PARTIAL** overall · **INTERNAL_TESTFLIGHT_SOFTWARE_READY** (conditional) · **EXTERNAL_TESTFLIGHT NOT READY** · **APP_STORE NOT READY** · **PHYSICAL_QA_PENDING**. See [`Docs/INDEX.md`](Docs/INDEX.md) and [`Docs/MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md`](Docs/MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md). Run `xcodegen generate` before opening `DIRDiving.xcodeproj`.
