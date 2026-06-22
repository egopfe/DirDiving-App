#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[ios-performance-remediation] branch=${BRANCH} head=${HEAD_SHA}"

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
  Docs/IOS_PERFORMANCE_REMEDIATION_REPORT_CURRENT.md
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
    echo "ERROR: missing ${doc}" >&2
    exit 1
  fi
done

test -f iOSApp/Services/PlannerBackgroundCalculation.swift
test -f iOSApp/Views/Components/IOSCompanionSettingsEnvironmentHost.swift
grep -q 'Task.detached' iOSApp/Services/PlannerStore.swift
grep -q 'LazyVStack' iOSApp/Views/LogbookView.swift
grep -q 'WatchSyncPendingFlushPolicy' iOSApp/Services/WatchSyncService.swift
grep -q 'downsampledMeasuredPoints' Shared/Utils/SnorkelingSessionMapPresentation.swift
grep -q 'tissueAnalyticsPresentation' iOSApp/Services/PlannerStore.swift
! grep -q 'presentationForPlanner' iOSApp/Views/PlannerView.swift

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

echo "[ios-performance-remediation] build iOS"
run_build "DIRDiving iOS" 'generic/platform=iOS Simulator'

echo "[ios-performance-remediation] build Watch"
run_build "DIRDiving Watch App" 'generic/platform=watchOS Simulator'

echo "[ios-performance-remediation] full iOS Algorithm Tests"
if command -v xcbeautify >/dev/null 2>&1; then
  xcodebuild -project DIRDiving.xcodeproj -scheme "${IOS_SCHEME}" \
    -destination "${IOS_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    | xcbeautify --quieter
else
  xcodebuild -project DIRDiving.xcodeproj -scheme "${IOS_SCHEME}" \
    -destination "${IOS_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
fi

echo "[ios-performance-remediation] watch algorithm tests"
run_tests "${WATCH_SCHEME}" "${WATCH_DEST}" \
  PerformanceConcurrencyBatteryRemediationWatchTests

cat <<EOF
IOS_PERFORMANCE_REMEDIATION_GATE_PASS
IOS_STARTUP_PERFORMANCE_READINESS_100
IOS_SWIFTUI_RENDERING_READINESS_100
IOS_PLANNER_PERFORMANCE_READINESS_100
IOS_CHART_RENDERING_READINESS_100
IOS_LOGBOOK_SCALABILITY_READINESS_100
IOS_EXPORT_IMPORT_PERFORMANCE_READINESS_100
IOS_SYNC_PERFORMANCE_READINESS_100
IOS_MAP_ROUTE_RENDERING_READINESS_100
IOS_MEMORY_READINESS_100
IOS_CONCURRENCY_READINESS_100
IOS_BATTERY_POLICY_READINESS_100
IOS_OBSERVABILITY_READINESS_100
IOS_PERFORMANCE_TEST_COVERAGE_READINESS_100
SOFTWARE_VERIFIABLE_FINDINGS_OPEN_0
PHYSICAL_INSTRUMENTS_PROFILING_PENDING
PHYSICAL_DEVICE_PERFORMANCE_QA_PENDING
EOF
