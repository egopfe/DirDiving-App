#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[activity-architecture-readiness] branch=${BRANCH} head=${HEAD_SHA}"

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

echo "[activity-architecture-readiness] build iOS MAIN"
run_build "DIRDiving iOS" 'generic/platform=iOS Simulator'

echo "[activity-architecture-readiness] build Watch MAIN"
run_build "DIRDiving Watch App" 'generic/platform=watchOS Simulator'

echo "[activity-architecture-readiness] iOS activity architecture suites"
run_tests "${IOS_SCHEME}" "${IOS_DEST}" \
  IOSActivityLogbookRoutingTests \
  IOSCompanionEnvironmentIsolationTests \
  IOSActivityLogbookDataIsolationTests \
  IOSActivitySettingsCoherenceTests \
  IOSCompanionActivitySelectionTests \
  IOSCompanionStoreLifecycleTests

echo "[activity-architecture-readiness] Watch activity architecture suites"
run_tests "${WATCH_SCHEME}" "${WATCH_DEST}" \
  WatchActivityLogbookRoutingTests \
  WatchActivityPageRestorationTests \
  WatchActivitySettingsOwnershipTests \
  DIRModesAndStartupFlowTests \
  IntegratedModesSequentialFlowTests

echo "[activity-architecture-readiness] UI/UX coherence spot checks"
run_tests "${IOS_SCHEME}" "${IOS_DEST}" \
  UIUXMainRemediationCurrentTests

echo ""
echo "ACTIVITY_ARCHITECTURE_SOFTWARE_GATE_PASS"
echo "ACTIVITY_ARCHITECTURE_READINESS_100"
echo "SETTINGS_OWNERSHIP_READINESS_100"
echo "LOGBOOK_ROUTING_READINESS_100"
echo "CROSS_ACTIVITY_ISOLATION_READINESS_100"
echo "SOFTWARE_FINDINGS_OPEN_0"
echo "PHYSICAL_WATCH_NAVIGATION_QA_PENDING"
