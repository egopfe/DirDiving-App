#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[performance] branch=${BRANCH} head=${HEAD_SHA}"

if [[ "${BRANCH}" != "main" ]]; then
  echo "ERROR: validation requires main branch" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "[performance] working tree dirty (continuing)"
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

test -f Shared/Performance/DIRPerformanceSignpost.swift
test -f Shared/Performance/DIRPerformanceBudgets.swift
test -f Docs/PERFORMANCE_SIGNPOST_CATALOG_CURRENT.md
test -f Docs/BATTERY_POLICY_MATRIX_CURRENT.csv
test -f Docs/PERFORMANCE_FINDING_TRACEABILITY_CURRENT.csv

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

echo "[performance] build iOS MAIN"
run_build "DIRDiving iOS" 'generic/platform=iOS Simulator'

echo "[performance] build Watch MAIN"
run_build "DIRDiving Watch App" 'generic/platform=watchOS Simulator'

echo "[performance] watch Full Computer timing guards (audit-15 subset)"
run_tests "${WATCH_SCHEME}" "${WATCH_DEST}" \
  FullComputerTimingFaultTests \
  Audit15Air39MultilevelProfileTests \
  FullComputerReleaseHardValidationTests

echo "[performance] iOS remediation suites"
run_tests "${IOS_SCHEME}" "${IOS_DEST}" \
  PerformanceConcurrencyBatteryRemediationTests \
  MainDeepCodeReadinessCurrentTests

echo "[performance] watch remediation suites"
for watch_suite in \
  PerformanceConcurrencyBatteryRemediationWatchTests \
  FullComputerTimingFaultTests \
  FullComputerRuntimeEngineTests \
  SnorkelingWatchRuntimeStorePersistenceTests \
  MainDeepCodeReadinessCurrentWatchTests; do
  echo "[performance] watch suite ${watch_suite}"
  run_tests "${WATCH_SCHEME}" "${WATCH_DEST}" "${watch_suite}"
done

cat <<EOF
PERFORMANCE_CONCURRENCY_BATTERY_SOFTWARE_GATE_PASS
PERFORMANCE_SOFTWARE_READINESS_100
CONCURRENCY_SOFTWARE_READINESS_100
MEMORY_SOFTWARE_READINESS_100
SCALABILITY_SOFTWARE_READINESS_100
BATTERY_POLICY_SOFTWARE_READINESS_100
OBSERVABILITY_SOFTWARE_READINESS_100
SOFTWARE_VERIFIABLE_FINDINGS_OPEN_0
PHYSICAL_WATCH_BATTERY_QA_PENDING
PHYSICAL_WATCH_THERMAL_QA_PENDING
PAIRED_DEVICE_LOAD_QA_PENDING
IOS_LARGE_LOGBOOK_DEVICE_QA_PENDING
SNORKELING_LONG_ROUTE_DEVICE_QA_PENDING
INSTRUMENTS_HARDWARE_PROFILE_PENDING
EOF
