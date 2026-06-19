#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

MODE="internal"
for arg in "$@"; do
  case "$arg" in
    --internal) MODE="internal" ;;
    --release) MODE="release" ;;
    -h|--help)
      cat <<'EOF'
Usage: ./Scripts/validate_integrated_modes.sh [--internal|--release]

Chains per-activity release validators and cross-cutting integrated gates.
Does not replace physical-device or underwater QA evidence.
EOF
      exit 0
      ;;
    *)
      echo "[integrated-modes] unknown argument: $arg"
      exit 2
      ;;
  esac
done

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
DIRTY="$(git status --porcelain)"

echo "[integrated-modes] mode: ${MODE}"
echo "[integrated-modes] branch: ${BRANCH} @ ${HEAD_SHA}"

if [[ "${MODE}" == "release" && -n "${DIRTY}" ]]; then
  echo "[integrated-modes] release mode requires a clean working tree"
  exit 1
fi

if [[ -n "${DIRTY}" && "${MODE}" == "internal" ]]; then
  echo "[integrated-modes] internal mode: dirty tree allowed — clean-commit validation still pending"
fi

# shellcheck source=Scripts/lib/xcodegen_once.sh
source "${ROOT_DIR}/Scripts/lib/xcodegen_once.sh"
xcodegen_once
export DIR_DIVING_SKIP_XCODEGEN=1

echo "[integrated-modes] cross-cutting: MAIN target isolation"
./Scripts/check_main_target_isolation.sh

echo "[integrated-modes] cross-cutting: secrets"
./Scripts/check_secrets.sh

echo "[integrated-modes] cross-cutting: localization parity"
./Scripts/audit_localization.sh

echo "[integrated-modes] per-activity: Full Computer release-hard"
./Scripts/validate_full_computer_release_readiness.sh

echo "[integrated-modes] per-activity: Apnea release-hard"
./Scripts/validate_apnea_release_readiness.sh --internal

echo "[integrated-modes] per-activity: Snorkeling release-hard"
./Scripts/validate_snorkeling_release_readiness.sh --internal

WATCH_DEST="${INTEGRATED_WATCH_SIM_DEST:-platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)}"
IOS_DEST="${INTEGRATED_IOS_SIM_DEST:-platform=iOS Simulator,name=iPhone 17}"

echo "[integrated-modes] integrated automated: sequential mode flow + activity lock"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination "${WATCH_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  -only-testing:"DIRDiving Watch Algorithm Tests/IntegratedModesSequentialFlowTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/DIRModesAndStartupFlowTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaArchitectureIsolationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingCrossDomainIsolationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/FullComputerNamespaceIsolationTests" \
  >/tmp/dirdiving_integrated_watch_tests.log

echo "[integrated-modes] integrated automated: iOS companion activity availability"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination "${IOS_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSApneaCompanionTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSCompanionActivitySelectionTests" \
  >/tmp/dirdiving_integrated_ios_tests.log

echo "[integrated-modes] physical QA status: PENDING (automated gate only)"
echo "[integrated-modes] external release: NO-GO until signed physical QA evidence exists"
echo "INTEGRATED_MODES_INTERNAL_RELEASE_GATE_PASS"
echo "INTEGRATED_MODES_EXTERNAL_RELEASE_PENDING_PHYSICAL_QA"
