#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[test-qa-evidence] branch=${BRANCH} head=${HEAD_SHA}"

if [[ "${BRANCH}" != "main" ]]; then
  echo "ERROR: validation requires main branch" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "[test-qa-evidence] working tree dirty (continuing)"
fi

if [[ -f "${ROOT_DIR}/Scripts/lib/xcodegen_once.sh" ]]; then
  # shellcheck source=Scripts/lib/xcodegen_once.sh
  source "${ROOT_DIR}/Scripts/lib/xcodegen_once.sh"
  xcodegen_once
else
  xcodegen generate
fi

./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh

test -f Shared/Utils/TestQaEvidenceSoftwareGatePolicy.swift
test -f Docs/TEST_QA_EVIDENCE_AUDIT_CURRENT.md
test -f Docs/REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv
test -f Docs/PHYSICAL_DEVICE_QA_MATRIX_CURRENT.csv
test -f Docs/EXTERNAL_VALIDATION_GAPS_CURRENT.md
test -f Docs/READINESS_TO_100_PLAN_CURRENT.md
test -f Docs/TEST_QA_EVIDENCE_REMEDIATION_REPORT_CURRENT.md
test -f Docs/TEST_QA_FINDING_TRACEABILITY_CURRENT.csv
test -f Docs/TEST_QA_EXTERNAL_QA_PENDING_CURRENT.md

IOS_DEST='platform=iOS Simulator,name=iPhone 17 Pro'
WATCH_DEST='platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)'
IOS_SCHEME='DIRDiving iOS Algorithm Tests'
WATCH_SCHEME='DIRDiving Watch Algorithm Tests'

run_build() {
  local scheme="$1"
  local dest="$2"
  if command -v xcbeautify >/dev/null 2>&1; then
    xcodebuild -project DIRDiving.xcodeproj -scheme "${scheme}" \
      -destination "${dest}" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
      | xcbeautify --quieter
  else
    xcodebuild -project DIRDiving.xcodeproj -scheme "${scheme}" \
      -destination "${dest}" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
  fi
}

run_tests() {
  local scheme="$1"
  local dest="$2"
  shift 2
  local -a only_flags=()
  for test_id in "$@"; do
    only_flags+=("-only-testing:${scheme}/${test_id}")
  done
  if command -v xcbeautify >/dev/null 2>&1; then
    xcodebuild -project DIRDiving.xcodeproj -scheme "${scheme}" \
      -destination "${dest}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
      "${only_flags[@]}" | xcbeautify --quieter
  else
    xcodebuild -project DIRDiving.xcodeproj -scheme "${scheme}" \
      -destination "${dest}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
      "${only_flags[@]}"
  fi
}

echo "[test-qa-evidence] build iOS MAIN"
run_build "DIRDiving iOS" 'generic/platform=iOS Simulator'

echo "[test-qa-evidence] build Watch MAIN"
run_build "DIRDiving Watch App" 'generic/platform=watchOS Simulator'

echo "[test-qa-evidence] iOS remediation suites"
run_tests "${IOS_SCHEME}" "${IOS_DEST}" \
  TestQaEvidenceRemediationTests \
  PlannerVisualContractTests \
  CSVMetadataRoundTripTests \
  BuhlmannReferenceFixtureTests \
  CCRMathRemediationTests \
  ActivitySyncSignedAckSymmetryTests \
  ActivitySyncTombstoneTests \
  MultiActivitySequentialSyncTests \
  SnorkelingAccessibilityContractTests \
  PerformanceConcurrencyBatteryRemediationTests

echo "[test-qa-evidence] watch remediation suites"
run_tests "${WATCH_SCHEME}" "${WATCH_DEST}" \
  TestQaEvidenceRemediationWatchTests \
  SnorkelingNavigationReturnEngineTests \
  SnorkelingReleaseHardValidationTests \
  ApneaReleaseHardValidationTests

echo "[test-qa-evidence] Command 7 regression"
./Scripts/validate_activity_architecture_settings_logbook_readiness.sh

echo "[test-qa-evidence] Command 8 regression"
./Scripts/validate_multi_activity_sync_persistence_schema_readiness.sh

echo "[test-qa-evidence] Command 9 regression"
./Scripts/validate_security_privacy_trust_readiness.sh

echo "[test-qa-evidence] Command 10 regression"
./Scripts/validate_performance_concurrency_battery_readiness.sh

cat <<EOF
TEST_QA_EVIDENCE_SOFTWARE_GATE_PASS
TEST_QA_SOFTWARE_READINESS_100
AUTOMATED_UNIT_INTEGRATION_SOFTWARE_READINESS_100
SIMULATOR_VALIDATION_SCRIPT_SOFTWARE_READINESS_100
UI_SNAPSHOT_CONTRACT_SOFTWARE_READINESS_100
TRACEABILITY_MATRIX_SOFTWARE_READINESS_100
SOFTWARE_VERIFIABLE_FINDINGS_OPEN_0
PHYSICAL_WATCH_QA_PENDING
PHYSICAL_IPHONE_QA_PENDING
PAIRED_DEVICE_QA_PENDING
UNDERWATER_ENTITLEMENT_QA_PENDING
EXTERNAL_BUHLMANN_VALIDATION_PENDING
EXTERNAL_CCR_VALIDATION_PENDING
EXTERNAL_SUBSURFACE_VALIDATION_PENDING
ICLOUD_TWO_DEVICE_QA_PENDING
APP_STORE_MARKETING_REVIEW_PENDING
VOICEOVER_DYNAMIC_TYPE_PHYSICAL_QA_PENDING
EOF
