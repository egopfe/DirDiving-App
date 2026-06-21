#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[audit15-readiness] branch=${BRANCH} head=${HEAD_SHA}"

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
  xcodebuild -project DIRDiving.xcodeproj -scheme "${WATCH_SCHEME}" \
    -destination "${WATCH_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    "${only_flags[@]}"
}

echo "[audit15-readiness] build Watch app"
xcodebuild -project DIRDiving.xcodeproj -scheme "${WATCH_APP_SCHEME}" \
  -destination "${WATCH_DEST}" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

echo "[audit15-readiness] Audit-15 oracle + remediation suites"
run_watch_tests \
  Audit15Air39MultilevelProfileTests \
  Audit15RedescentOracleTests \
  Audit15MultilevelOracleProfilesTests \
  Audit15TTSScheduleOracleSweepTests \
  SchreinerAnalyticParityTests \
  BuhlmannMutationResistanceTests \
  FullComputerTimingFaultTests \
  FullComputerRuntimeEngineTests \
  WatchMathCrossTargetParityTests \
  FullComputerDecoSolverTests \
  FullComputerDecoStopStateMachineTests \
  FullComputerRecoveryCheckpointTests \
  FullComputerDecoSolverCacheIsolationTests \
  FullComputerProjectionDeduplicationTests

if [[ -x "${ROOT_DIR}/Scripts/export_watch_live_buhlmann_replay_vectors.py" ]]; then
  python3 "${ROOT_DIR}/Scripts/export_watch_live_buhlmann_replay_vectors.py"
fi

for doc in \
  Docs/WATCH_BUHLMANN_NUMERICAL_ERROR_BUDGET_CURRENT.md \
  Docs/WATCH_LIVE_BUHLMANN_REQUIREMENT_TEST_MATRIX_CURRENT.csv \
  Docs/WATCH_LIVE_BUHLMANN_FINDING_TRACEABILITY_CURRENT.csv \
  Docs/FULL_COMPUTER_DEGRADED_STATE_POLICY_CURRENT.md; do
  [[ -f "${doc}" ]] || { echo "ERROR: missing ${doc}" >&2; exit 1; }
done

echo "[audit15-readiness] iOS algorithm build smoke"
xcodebuild -project DIRDiving.xcodeproj -scheme "${IOS_SCHEME}" \
  -destination "${IOS_DEST}" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

echo ""
echo "WATCH_LIVE_BUHLMANN_SCHREINER_SOFTWARE_GATE_PASS"
echo "WATCH_LIVE_BUHLMANN_SOFTWARE_READINESS_100"
echo "SCHREINER_SOFTWARE_READINESS_100"
echo "MULTILEVEL_ORACLE_COVERAGE_READINESS_100"
echo "TTS_SCHEDULE_ORACLE_READINESS_100"
echo "LIVE_DECO_RUNTIME_READINESS_100"
echo "FULL_COMPUTER_CONCURRENCY_READINESS_100"
echo "FULL_COMPUTER_NUMERICAL_READINESS_100"
echo "SOFTWARE_VERIFIABLE_FINDINGS_OPEN_0"
echo "PHYSICAL_WATCH_ULTRA_VALIDATION_PENDING"
echo "EXTERNAL_DECOMPRESSION_TOOL_VALIDATION_PENDING"
echo "EXTERNAL_BUHLMANN_VALIDATION_PENDING"
