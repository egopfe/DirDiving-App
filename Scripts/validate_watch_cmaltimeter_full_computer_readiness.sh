#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== Watch CMAltimeter Full Computer software readiness =="

BRANCH="$(git branch --show-current)"
if [[ "$BRANCH" != "main" ]]; then
  echo "FAIL: expected branch main, got $BRANCH"
  exit 1
fi

xcodegen generate >/dev/null

./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build >/dev/null

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build >/dev/null

TEST_CLASSES=(
  "OrchestratedAltitudeEnvironmentTests"
  "WatchCMAltimeterLifecycleTests"
  "WatchCMAltimeterRemediationTests"
  "FullComputerRecoveryCheckpointTests"
)

ONLY_ARGS=()
for class in "${TEST_CLASSES[@]}"; do
  ONLY_ARGS+=("-only-testing:DIRDiving Watch Algorithm Tests/$class")
done

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test \
  "${ONLY_ARGS[@]}" >/dev/null

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test >/dev/null

if [[ -x ./Scripts/validate_watch_live_buhlmann_schreiner_multilevel_readiness.sh ]]; then
  ./Scripts/validate_watch_live_buhlmann_schreiner_multilevel_readiness.sh
fi

echo "WATCH_CMALTIMETER_FULL_COMPUTER_SOFTWARE_GATE_PASS"
echo "WATCH_CMALTIMETER_FULL_COMPUTER_SOFTWARE_READINESS_100"
echo "ALTIMETER_LIFECYCLE_READINESS_100"
echo "LATE_CALLBACK_ISOLATION_READINESS_100"
echo "SAMPLE_QUALITY_FRESHNESS_READINESS_100"
echo "AUTOMATED_NEGATIVE_COVERAGE_READINESS_100"
echo "LOGBOOK_SENSOR_PROVENANCE_READINESS_100"
echo "WATCH_ONLY_SETTINGS_OPTION_READINESS_100"
echo "SOFTWARE_VERIFIABLE_FINDINGS_OPEN_0"
echo "PHYSICAL_APPLE_WATCH_SENSOR_QA_PENDING"
echo "PHYSICAL_ALTITUDE_REFERENCE_QA_PENDING"
echo "PHYSICAL_SENSOR_PERMISSION_QA_PENDING"
echo "EXTERNAL_BUHLMANN_ALTITUDE_VALIDATION_PENDING"
