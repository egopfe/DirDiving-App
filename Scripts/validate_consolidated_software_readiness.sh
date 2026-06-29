#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== Consolidated software readiness validation =="

bash Scripts/validate_commands_for_cursor_integrity.sh
bash Scripts/validate_depth_capability_runtime_authority.sh
bash Scripts/validate_developer_shallow_testing_release_gate.sh
bash Scripts/validate_no_fake_physical_evidence_claims.sh
bash Scripts/validate_no_fake_external_validation_claims.sh
bash Scripts/validate_release_claims_against_evidence.sh

xcodegen generate >/dev/null
bash Scripts/check_main_target_isolation.sh
bash Scripts/check_secrets.sh
bash Scripts/audit_localization.sh

IOS_DEST='platform=iOS Simulator,name=iPhone 17'
WATCH_DEST='platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)'

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination "$IOS_DEST" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build >/dev/null
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination "$WATCH_DEST" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build >/dev/null

export XCTestDisableAutomaticTestTimeouts=1
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination "$IOS_DEST" \
  -only-testing:'DIRDiving iOS Algorithm Tests/DivePlanPackageBuilderTests' \
  -only-testing:'DIRDiving iOS Algorithm Tests/PlannerGFPresetDisplayTests' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test >/dev/null

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination "$WATCH_DEST" \
  -only-testing:'DIRDiving Watch Algorithm Tests/DIRModesAndStartupFlowTests' \
  -only-testing:'DIRDiving Watch Algorithm Tests/FullComputerImportedPlanStoreTests' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test >/dev/null

echo "PASS: consolidated software readiness gates"
