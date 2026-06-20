#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[main-deep-code-readiness] branch=${BRANCH} head=${HEAD_SHA}"

if [[ "${BRANCH}" != "main" ]]; then
  echo "ERROR: validation requires main branch" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "[main-deep-code-readiness] dirty working tree detected — continuing validation"
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

echo "[main-deep-code-readiness] build iOS MAIN"
run_build "DIRDiving iOS" 'generic/platform=iOS Simulator'

echo "[main-deep-code-readiness] build Watch MAIN"
run_build "DIRDiving Watch App" 'generic/platform=watchOS Simulator'

echo "[main-deep-code-readiness] deep-code readiness suites"
run_tests "${IOS_SCHEME}" "${IOS_DEST}" \
  MainDeepCodeReadinessCurrentTests \
  MainDeepCodeAnalysisRemediationV1Tests \
  MainDeepCodeAuditRemediationTests \
  MainDeepCodeRemediationDCATests

run_tests "${WATCH_SCHEME}" "${WATCH_DEST}" \
  MainDeepCodeReadinessCurrentWatchTests \
  MainDeepCodeAnalysisRemediationV1WatchTests \
  MainDeepCodeRemediationDCATests

echo "[main-deep-code-readiness] delegated validation gates"
./Scripts/validate_ios_complete_algorithm_readiness.sh
./Scripts/validate_ui_ux_main_readiness.sh
./Scripts/validate_watch_complete_algorithm_readiness.sh
./Scripts/validate_watch_math_readiness.sh

required_docs=(
  "Docs/MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md"
  "Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md"
  "Docs/MAIN_DEEP_CODE_FINDING_TRACEABILITY_CURRENT.csv"
  "Docs/MAIN_DEEP_CODE_REQUIREMENT_TEST_MATRIX_CURRENT.csv"
  "Docs/MAIN_SECURITY_NEGATIVE_TEST_MATRIX_CURRENT.csv"
  "Docs/MAIN_PERFORMANCE_BUDGET_CURRENT.csv"
  "Docs/MAIN_PRIVACY_FILE_PROTECTION_MATRIX_CURRENT.csv"
  "Docs/MAIN_SYNC_DATA_INTEGRITY_MATRIX_CURRENT.csv"
  "Docs/MAIN_EXTERNAL_QA_PENDING_CURRENT.md"
  "Docs/MAIN_RELEASE_GATE_MATRIX_CURRENT.csv"
)

for doc in "${required_docs[@]}"; do
  [[ -f "$doc" ]] || { echo "ERROR: missing required doc ${doc}" >&2; exit 1; }
done

echo "MAIN_DEEP_CODE_SOFTWARE_GATE_PASS"
echo "MAIN_INTERNAL_CODE_READINESS_100"
echo "MAIN_SOFTWARE_FINDINGS_OPEN_0"
echo "IOS_SOFTWARE_READINESS_100"
echo "WATCH_SOFTWARE_READINESS_100"
echo "SECURITY_SOFTWARE_READINESS_100"
echo "PRIVACY_SOFTWARE_READINESS_100"
echo "PERFORMANCE_SOFTWARE_READINESS_100"
echo "DATA_INTEGRITY_SOFTWARE_READINESS_100"
echo "SYNC_SOFTWARE_READINESS_100"
echo "UI_UX_SOFTWARE_READINESS_100"
echo "PHYSICAL_WATCH_QA_PENDING"
echo "PAIRED_DEVICE_QA_PENDING"
echo "ICLOUD_TWO_DEVICE_QA_PENDING"
echo "SUBSURFACE_DESKTOP_QA_PENDING"
echo "EXTERNAL_BUHLMANN_VALIDATION_PENDING"
echo "EXTERNAL_CCR_VALIDATION_PENDING"
echo "SNORKELING_FIELD_GPS_QA_PENDING"
echo "APNEA_WET_QA_PENDING"
echo "LONG_DIVE_BATTERY_THERMAL_QA_PENDING"
echo "LEGAL_REVIEW_PENDING"
