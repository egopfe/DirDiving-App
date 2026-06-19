#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[watch-complete-algorithm] branch=${BRANCH} head=${HEAD_SHA}"

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

WATCH_DEST='platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)'
IOS_DEST='platform=iOS Simulator,name=iPhone 17'
WATCH_SCHEME='DIRDiving Watch Algorithm Tests'
IOS_SCHEME='DIRDiving iOS Algorithm Tests'
WATCH_APP_SCHEME='DIRDiving Watch App'

run_watch_tests() {
  local -a only_flags=()
  for test_id in "$@"; do
    only_flags+=("-only-testing:${WATCH_SCHEME}/${test_id}")
  done
  if command -v xcbeautify >/dev/null 2>&1; then
    xcodebuild -project DIRDiving.xcodeproj -scheme "${WATCH_SCHEME}" \
      -destination "${WATCH_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
      "${only_flags[@]}" | xcbeautify --quieter
  else
    xcodebuild -project DIRDiving.xcodeproj -scheme "${WATCH_SCHEME}" \
      -destination "${WATCH_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
      "${only_flags[@]}"
  fi
}

run_full_watch_tests() {
  if command -v xcbeautify >/dev/null 2>&1; then
    xcodebuild -project DIRDiving.xcodeproj -scheme "${WATCH_SCHEME}" \
      -destination "${WATCH_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
      | xcbeautify --quieter
  else
    xcodebuild -project DIRDiving.xcodeproj -scheme "${WATCH_SCHEME}" \
      -destination "${WATCH_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
  fi
}

echo "[watch-complete-algorithm] build Watch MAIN"
if command -v xcbeautify >/dev/null 2>&1; then
  xcodebuild -project DIRDiving.xcodeproj -scheme "${WATCH_APP_SCHEME}" \
    -destination "${WATCH_DEST}" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    | xcbeautify --quieter
else
  xcodebuild -project DIRDiving.xcodeproj -scheme "${WATCH_APP_SCHEME}" \
    -destination "${WATCH_DEST}" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
fi

echo "[watch-complete-algorithm] focused suites"
run_watch_tests \
  FullComputerReleaseHardValidationTests \
  FullComputerRuntimeEngineTests \
  FullComputerDecoSolverTests \
  FullComputerRecoveryCheckpointTests \
  DiveManagerAlgorithmIntegrationTests \
  GaugeOptionalTTVTests \
  PlannerBriefingCardKindMatrixTests \
  PlannerBriefingLegacyKindDecodeTests \
  PlannerBriefingReceiverTests \
  PlannerBriefingCardStoreTests \
  WatchBriefingCardRemediationTests \
  WatchSyncCryptographicLogicTests \
  WatchSyncServiceIntegrationTests \
  WatchSyncPeerSecretPinningTests \
  WatchSyncPendingQueueTests \
  MainDeepCodeRemediationDCATests \
  CompanionPhotoManagementTests \
  MissionModeAlgorithmInvariantTests \
  DeveloperSensorSourceTests \
  ActionButtonIntentsSafetyTests \
  ApneaReleaseHardValidationTests \
  SnorkelingReleaseHardValidationTests \
  DIRDivingCompleteLocalizationAuditTests \
  FullComputerUIStateMatrixTests

echo "[watch-complete-algorithm] complete Watch Algorithm Tests"
run_full_watch_tests

if git diff --name-only -- Shared/BuhlmannCore Models/PlannerBriefingCard.swift Services/WatchSyncAuth.swift iOSApp/Services/WatchSyncAuth.swift | grep -q .; then
  echo "[watch-complete-algorithm] shared models touched — running iOS parity suites"
  if command -v xcbeautify >/dev/null 2>&1; then
    xcodebuild -project DIRDiving.xcodeproj -scheme "${IOS_SCHEME}" \
      -destination "${IOS_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
      -only-testing:"${IOS_SCHEME}/PlannerBriefingImageExportServiceTests" \
      -only-testing:"${IOS_SCHEME}/ApneaSyncCryptographicLogicTests" \
      | xcbeautify --quieter
  else
    xcodebuild -project DIRDiving.xcodeproj -scheme "${IOS_SCHEME}" \
      -destination "${IOS_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
      -only-testing:"${IOS_SCHEME}/PlannerBriefingImageExportServiceTests" \
      -only-testing:"${IOS_SCHEME}/ApneaSyncCryptographicLogicTests"
  fi
fi

required_docs=(
  "Docs/2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_REMEDIATION_REPORT_CURRENT.md"
  "Docs/2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_CURRENT.md"
  "Docs/WATCH_COMPLETE_ALGORITHM_REQUIREMENT_TEST_MATRIX_CURRENT.csv"
  "Docs/WATCH_COMPLETE_ALGORITHM_FINDING_TRACEABILITY_CURRENT.csv"
  "Docs/WATCH_SOFTWARE_PERFORMANCE_BUDGET_CURRENT.csv"
  "Docs/WATCH_EXTERNAL_QA_PENDING_CURRENT.md"
  "Docs/PLANNER_BRIEFING_CARD_KIND_MATRIX_CURRENT.csv"
)

for doc in "${required_docs[@]}"; do
  [[ -f "$doc" ]] || { echo "ERROR: missing required doc ${doc}" >&2; exit 1; }
done

echo "WATCH_COMPLETE_ALGORITHM_SOFTWARE_GATE_PASS"
echo "WATCH_MAIN_INTERNAL_READINESS_100"
echo "WATCH_FULL_COMPUTER_SOFTWARE_READINESS_100"
echo "WATCH_GAUGE_SOFTWARE_READINESS_100"
echo "WATCH_APNEA_SOFTWARE_READINESS_100"
echo "WATCH_SNORKELING_SOFTWARE_READINESS_100"
echo "WATCH_PHYSICAL_ULTRA_QA_PENDING"
echo "WATCH_PAIRED_DEVICE_QA_PENDING"
echo "WATCH_EXTERNAL_BUHLMANN_VALIDATION_PENDING"
echo "WATCH_LONG_DIVE_BATTERY_QA_PENDING"
