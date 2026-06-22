#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[ios-performance-audit] branch=${BRANCH} head=${HEAD_SHA}"

if [[ "${BRANCH}" != "main" ]]; then
  echo "ERROR: validation requires main branch" >&2
  exit 1
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

AUDIT_DOCS=(
  Docs/IOS_PERFORMANCE_OPTIMIZATION_AUDIT_CURRENT.md
  Docs/IOS_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv
  Docs/IOS_PERFORMANCE_FINDING_TRACEABILITY_CURRENT.csv
  Docs/IOS_PERFORMANCE_REQUIREMENT_TEST_MATRIX_CURRENT.csv
  Docs/IOS_PERFORMANCE_PROFILING_PLAN_CURRENT.md
  Docs/IOS_PERFORMANCE_SCALABILITY_MATRIX_CURRENT.csv
  Docs/IOS_PERFORMANCE_EXTERNAL_QA_PENDING_CURRENT.md
  Docs/IOS_PERFORMANCE_SIGNPOST_CATALOG_CURRENT.md
)

for doc in "${AUDIT_DOCS[@]}"; do
  if [[ ! -f "${doc}" ]]; then
    echo "ERROR: missing audit artifact ${doc}" >&2
    exit 1
  fi
done

test -f Shared/Performance/DIRPerformanceSignpost.swift
test -f Shared/Performance/DIRPerformanceBudgets.swift
test -f Shared/Performance/PresentationSeriesDownsampler.swift

IOS_DEST='platform=iOS Simulator,name=iPhone 17 Pro'
IOS_SCHEME='DIRDiving iOS Algorithm Tests'

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

echo "[ios-performance-audit] build DIRDiving iOS"
run_build "DIRDiving iOS" 'generic/platform=iOS Simulator'

echo "[ios-performance-audit] iOS performance / scalability suites"
run_tests "${IOS_SCHEME}" "${IOS_DEST}" \
  PerformanceConcurrencyBatteryRemediationTests \
  MainDeepCodeReadinessCurrentTests \
  IOSActivitySettingsRoutingTests \
  IOSActivitySettingsContentVisibilityTests \
  IOSActivitySettingsModeSwitchTests \
  LogbookScalabilitySupportTests \
  ActivitySyncLargePayloadTransferTests

cat <<EOF
IOS_PERFORMANCE_OPTIMIZATION_AUDIT_GATE_PASS
IOS_PERFORMANCE_AUDIT_DOCUMENTATION_COMPLETE
IOS_PERFORMANCE_BUDGET_MATRIX_COMPLETE
IOS_PERFORMANCE_FINDING_TRACEABILITY_COMPLETE
IOS_PERFORMANCE_PROFILING_PLAN_COMPLETE
PHYSICAL_INSTRUMENTS_PROFILING_PENDING
EOF
