#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[master-main-audit] branch=${BRANCH} head=${HEAD_SHA}"

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
  Docs/MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md
  Docs/MASTER_MAIN_CODE_FINDING_TRACEABILITY_CURRENT.csv
  Docs/MASTER_MAIN_ARCHITECTURE_RISK_MATRIX_CURRENT.csv
  Docs/MASTER_SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv
  Docs/MASTER_SCHEMA_MIGRATION_COMPATIBILITY_MATRIX_CURRENT.csv
  Docs/MASTER_BACKUP_RESTORE_ISOLATION_MATRIX_CURRENT.csv
  Docs/MASTER_SECURITY_THREAT_MODEL_CURRENT.md
  Docs/MASTER_PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv
  Docs/MASTER_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv
  Docs/MASTER_CONCURRENCY_RISK_MATRIX_CURRENT.csv
  Docs/MASTER_IOS_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv
  Docs/MASTER_IOS_PERFORMANCE_SCALABILITY_MATRIX_CURRENT.csv
  Docs/MASTER_PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md
  Docs/MASTER_SECURITY_REMEDIATION_PLAN_CURRENT.md
  Docs/MASTER_MAIN_CODE_REMEDIATION_PLAN_CURRENT.md
  Docs/MASTER_PERFORMANCE_SIGNPOST_CATALOG_CURRENT.md
  Docs/MASTER_MAIN_REQUIREMENT_TEST_TRACEABILITY_CURRENT.csv
  Docs/MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv
  Docs/MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv
  Docs/MASTER_MAIN_APNEA_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md
  Docs/MASTER_APNEA_SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv
  Docs/MASTER_APNEA_SCHEMA_MIGRATION_COMPATIBILITY_MATRIX_CURRENT.csv
  Docs/MASTER_APNEA_PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv
  Docs/MASTER_APNEA_PERFORMANCE_CONCURRENCY_MATRIX_CURRENT.csv
  Docs/MASTER_MAIN_ALGORITHMIC_SAFETY_PROTECTION_GATE_CURRENT.md
  Docs/MASTER_MAIN_CODE_POST_REMEDIATION_VERIFICATION_CURRENT.md
  Docs/MASTER_COMMAND_INTEGRITY_POST_REMEDIATION_MATRIX_CURRENT.csv
  Docs/MASTER_SYNC_SECURITY_POST_REMEDIATION_MATRIX_CURRENT.csv
  Docs/MASTER_DEPTH_CAPABILITY_POST_REMEDIATION_MATRIX_CURRENT.csv
  Docs/MASTER_PERFORMANCE_CONCURRENCY_POST_REMEDIATION_MATRIX_CURRENT.csv
)

for doc in "${AUDIT_DOCS[@]}"; do
  if [[ ! -f "${doc}" ]]; then
    echo "ERROR: missing ${doc}" >&2
    exit 1
  fi
done

# Structural checks for remediated iOS performance + sync paths
grep -q 'PlannerBackgroundCalculation' iOSApp/Services/PlannerStore.swift
grep -q 'Task.detached' iOSApp/Services/PlannerStore.swift
grep -q 'WatchSyncPendingFlushPolicy' iOSApp/Services/WatchSyncService.swift
grep -q 'ActivitySyncTombstoneBroadcast' Shared/Utils/ActivitySyncTombstoneBroadcast.swift
grep -q 'CloudBackupCapability' iOSApp/Utils/CloudBackupCapability.swift
grep -q 'downsampledMeasuredPoints' Shared/Utils/SnorkelingSessionMapPresentation.swift

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

echo "[master-main-audit] build iOS MAIN"
run_build "DIRDiving iOS" 'generic/platform=iOS Simulator'

echo "[master-main-audit] build Watch MAIN"
run_build "DIRDiving Watch App" 'generic/platform=watchOS Simulator'

echo "[master-main-audit] performance / sync / security readiness suites"
run_tests "${IOS_SCHEME}" "${IOS_DEST}" \
  PerformanceConcurrencyBatteryRemediationTests \
  ActivitySyncCrossDecodeRejectionTests \
  ActivitySyncTombstoneTests \
  ActivitySyncLargePayloadTransferTests \
  CloudBackupCapabilityTests \
  SecurityPrivacyTrustRemediationTests

run_tests "${WATCH_SCHEME}" "${WATCH_DEST}" \
  ActivitySyncTombstoneWatchTests \
  PerformanceConcurrencyBatteryRemediationWatchTests \
  FullComputerTimingFaultTests

echo "MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_GATE_PASS"
echo "MASTER_MAIN_CODE_AUDIT_DOCUMENTATION_COMPLETE"
echo "MASTER_SYNC_SCHEMA_MATRICES_COMPLETE"
echo "MASTER_SECURITY_PRIVACY_MATRICES_COMPLETE"
echo "MASTER_PERFORMANCE_BUDGETS_COMPLETE"
echo "MASTER_IOS_PERFORMANCE_MATRICES_COMPLETE"
echo "PHYSICAL_QA_PENDING_UNLESS_EVIDENCED"
