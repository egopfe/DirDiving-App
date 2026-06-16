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

**Full Computer (`integration/full-computer`):** experimental Watch decompressive runtime — **not certified**. See [`Docs/FULL_COMPUTER_ARCHITECTURE.md`](Docs/FULL_COMPUTER_ARCHITECTURE.md), run `./Scripts/validate_full_computer_release_readiness.sh` before FC TestFlight builds.

**Release baseline (`main`):** `origin/main` @ **`99ea74a`** — UI/UX remediation V1.0 (`7c79105`), deep-code audit @ `7c79105` (`009855e`), deep-code remediation V1.0 MAIN-DCA-011…031 (`99ea74a`). See [`Docs/INDEX.md`](Docs/INDEX.md) and [`Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md). Run `xcodegen generate` before opening `DIRDiving.xcodeproj`.
