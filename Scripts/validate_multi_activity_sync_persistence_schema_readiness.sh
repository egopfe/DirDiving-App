#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[multi-activity-sync-readiness] branch=${BRANCH} head=${HEAD_SHA}"

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

echo "[multi-activity-sync-readiness] build iOS MAIN"
run_build "DIRDiving iOS" 'generic/platform=iOS Simulator'

echo "[multi-activity-sync-readiness] build Watch MAIN"
run_build "DIRDiving Watch App" 'generic/platform=watchOS Simulator'

echo "[multi-activity-sync-readiness] iOS sync/persistence/schema suites"
run_tests "${IOS_SCHEME}" "${IOS_DEST}" \
  ActivitySyncEnvelopeTests \
  ActivitySyncCrossDecodeRejectionTests \
  ActivitySyncTombstoneTests \
  ActivitySyncLargePayloadTransferTests \
  ActivitySyncSignedAckSymmetryTests \
  ActivitySyncRevisionPolicyTests \
  DiveSessionSyncTransportNegativeTests \
  ApneaSessionSyncTransportNegativeTests \
  SnorkelingSessionSyncTransportNegativeTests \
  CloudBackupCapabilityTests \
  ActivitySyncSchemaRegistryTests \
  MultiActivitySequentialSyncTests \
  IOSActivityLogbookDataIsolationTests

echo "[multi-activity-sync-readiness] Watch sync/persistence/schema suites"
run_tests "${WATCH_SCHEME}" "${WATCH_DEST}" \
  ActivitySyncTombstoneWatchTests \
  ActivitySyncCrossDecodeRejectionWatchTests \
  ApneaSessionSyncTransportNegativeWatchTests \
  SnorkelingSessionSyncTransportNegativeWatchTests \
  WatchActivityLogbookRoutingTests

echo "[multi-activity-sync-readiness] Command 7 architecture regression"
./Scripts/validate_activity_architecture_settings_logbook_readiness.sh

echo "MULTI_ACTIVITY_SYNC_PERSISTENCE_SCHEMA_GATE_PASS"
echo "SYNC_SOFTWARE_READINESS_100"
echo "PERSISTENCE_SOFTWARE_READINESS_100"
echo "SCHEMA_SOFTWARE_READINESS_100"
echo "BACKUP_RESTORE_SOFTWARE_READINESS_100"
echo "CROSS_ACTIVITY_ISOLATION_READINESS_100"
echo "SOFTWARE_VERIFIABLE_FINDINGS_OPEN_0"
echo "PAIRED_DEVICE_QA_PENDING"
echo "ICLOUD_TWO_DEVICE_QA_PENDING"
echo "PHYSICAL_TOMBSTONE_PROPAGATION_QA_PENDING"
echo "PHYSICAL_LARGE_PAYLOAD_QA_PENDING"
