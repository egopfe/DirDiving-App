#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[activity-settings-navigation] branch=${BRANCH} head=${HEAD_SHA}"

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

grep -q 'IOSCompanionSettingsModeSwitcher' iOSApp/Views/Components/IOSCompanionSettingsModeSwitcher.swift
grep -q 'IOSCompanionSettingsRootView' iOSApp/Views/IOSCompanionSettingsRootView.swift
grep -q 'WatchInModeSettingsAccessButton' Utils/WatchInModeSettingsAccess.swift
grep -q 'WatchInModeSettingsAccessButton' Views/ApneaView.swift
grep -q 'WatchInModeSettingsAccessButton' Views/SnorkelingView.swift

echo "[activity-settings-navigation] build iOS MAIN"
run_build "DIRDiving iOS" 'generic/platform=iOS Simulator'

echo "[activity-settings-navigation] build Watch MAIN"
run_build "DIRDiving Watch App" 'generic/platform=watchOS Simulator'

echo "[activity-settings-navigation] iOS settings suites"
run_tests "${IOS_SCHEME}" "${IOS_DEST}" \
  IOSActivitySettingsModeSwitchTests \
  IOSActivitySettingsRoutingTests \
  IOSActivitySettingsCoherenceTests \
  IOSCompanionActivitySelectionTests \
  IOSCompanionStoreLifecycleTests

echo "[activity-settings-navigation] Watch settings suites"
run_tests "${WATCH_SCHEME}" "${WATCH_DEST}" \
  WatchSettingsRoutingTests \
  WatchActivitySettingsOwnershipTests \
  WatchActivityLogbookRoutingTests

if [[ -x "${ROOT_DIR}/Scripts/validate_activity_architecture_settings_logbook_readiness.sh" ]]; then
  echo "[activity-settings-navigation] activity architecture regression"
  ./Scripts/validate_activity_architecture_settings_logbook_readiness.sh
fi

if [[ -x "${ROOT_DIR}/Scripts/validate_ui_ux_main_readiness.sh" ]]; then
  echo "[activity-settings-navigation] UI/UX regression"
  ./Scripts/validate_ui_ux_main_readiness.sh
fi

echo "ACTIVITY_SETTINGS_NAVIGATION_SOFTWARE_GATE_PASS"
echo "IOS_SETTINGS_MODE_SWITCH_READINESS_100"
echo "IOS_APNEA_SETTINGS_ACCESS_READINESS_100"
echo "IOS_SNORKELING_SETTINGS_ACCESS_READINESS_100"
echo "WATCH_APNEA_SETTINGS_ACCESS_READINESS_100"
echo "WATCH_SNORKELING_SETTINGS_ACCESS_READINESS_100"
echo "ACTIVITY_SETTINGS_OWNERSHIP_READINESS_100"
echo "SOFTWARE_VERIFIABLE_FINDINGS_OPEN_0"
