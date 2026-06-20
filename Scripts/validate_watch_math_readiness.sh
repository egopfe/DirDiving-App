#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[watch-math-readiness] branch=${BRANCH} head=${HEAD_SHA}"

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

echo "[watch-math-readiness] build Watch MAIN"
if command -v xcbeautify >/dev/null 2>&1; then
  xcodebuild -project DIRDiving.xcodeproj -scheme "${WATCH_APP_SCHEME}" \
    -destination "${WATCH_DEST}" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    | xcbeautify --quieter
else
  xcodebuild -project DIRDiving.xcodeproj -scheme "${WATCH_APP_SCHEME}" \
    -destination "${WATCH_DEST}" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
fi

echo "[watch-math-readiness] Audit-15 and oracle suites"
run_watch_tests \
  Audit15Air39MultilevelProfileTests \
  Audit15RedescentOracleTests \
  SchreinerAnalyticParityTests \
  BuhlmannMutationResistanceTests \
  FullComputerTimingFaultTests \
  WatchMathCrossTargetParityTests \
  WatchGaugeMathCompletionTests \
  WatchUnitConversionRoundTripTests

echo "[watch-math-readiness] Bühlmann / Full Computer / Gauge / sync / briefing focused suites"
run_watch_tests \
  FullComputerReleaseHardValidationTests \
  FullComputerRuntimeEngineTests \
  FullComputerDecoSolverTests \
  FullComputerRecoveryCheckpointTests \
  FullComputerDecoStopStateMachineTests \
  DiveAlgorithmTests \
  DiveManagerAlgorithmIntegrationTests \
  GaugeOptionalTTVTests \
  BuhlmannCoreCrossTargetEquivalenceTests \
  PlannerBriefingCardKindMatrixTests \
  PlannerBriefingLegacyKindDecodeTests \
  WatchBriefingCardRemediationTests \
  WatchSyncCryptographicLogicTests \
  WatchSyncServiceIntegrationTests \
  ApneaReleaseHardValidationTests \
  ApneaLifecycleEngineTests \
  SnorkelingReleaseHardValidationTests \
  SnorkelingNavigationReturnEngineTests

echo "[watch-math-readiness] complete Watch Algorithm Tests"
if command -v xcbeautify >/dev/null 2>&1; then
  xcodebuild -project DIRDiving.xcodeproj -scheme "${WATCH_SCHEME}" \
    -destination "${WATCH_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    | xcbeautify --quieter
else
  xcodebuild -project DIRDiving.xcodeproj -scheme "${WATCH_SCHEME}" \
    -destination "${WATCH_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
fi

if git diff --name-only -- Shared/BuhlmannCore Models/PlannerBriefingCard.swift Services/WatchSyncAuth.swift Services/FullComputerRuntimeEngine.swift | grep -q .; then
  echo "[watch-math-readiness] shared/core touched — running iOS parity suites"
  if command -v xcbeautify >/dev/null 2>&1; then
    xcodebuild -project DIRDiving.xcodeproj -scheme "${IOS_SCHEME}" \
      -destination "${IOS_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
      -only-testing:"${IOS_SCHEME}/BuhlmannCoreCrossTargetEquivalenceTests" \
      -only-testing:"${IOS_SCHEME}/PlannerBriefingImageExportServiceTests" \
      | xcbeautify --quieter
  else
    xcodebuild -project DIRDiving.xcodeproj -scheme "${IOS_SCHEME}" \
      -destination "${IOS_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
      -only-testing:"${IOS_SCHEME}/BuhlmannCoreCrossTargetEquivalenceTests" \
      -only-testing:"${IOS_SCHEME}/PlannerBriefingImageExportServiceTests"
  fi
fi

required_docs=(
  "Docs/WATCH_MAIN_COMPLETE_MATH_FUNCTIONS_REMEDIATION_REPORT_CURRENT.md"
  "Docs/WATCH_MAIN_COMPLETE_MATH_FUNCTIONS_AUDIT_CURRENT.md"
  "Docs/WATCH_MATH_FEATURE_INVENTORY_CURRENT.csv"
  "Docs/WATCH_MATH_EDGE_CASE_MATRIX_CURRENT.csv"
  "Docs/WATCH_MATH_REQUIREMENT_TEST_MATRIX_CURRENT.csv"
  "Docs/WATCH_MATH_FINDING_TRACEABILITY_CURRENT.csv"
  "Docs/WATCH_MATH_NUMERICAL_ERROR_BUDGET_CURRENT.md"
  "Docs/WATCH_MATH_EXTERNAL_QA_PENDING_CURRENT.md"
  "Docs/WATCH_AUDIT15_AIR39_PROFILE_CURRENT.csv"
  "Docs/WATCH_AUDIT15_REDESCENT_PROFILE_CURRENT.csv"
)

for doc in "${required_docs[@]}"; do
  [[ -f "$doc" ]] || { echo "ERROR: missing required doc ${doc}" >&2; exit 1; }
done

echo "WATCH_MATH_SOFTWARE_GATE_PASS"
echo "WATCH_MAIN_MATH_SOFTWARE_READINESS_100"
echo "WATCH_MATH_SOFTWARE_FINDINGS_OPEN_0"
echo "WATCH_EXTERNAL_BUHLMANN_VALIDATION_PENDING"
echo "WATCH_PHYSICAL_ULTRA_QA_PENDING"
echo "WATCH_PAIRED_SYNC_QA_PENDING"
echo "WATCH_LONG_DIVE_BATTERY_QA_PENDING"
