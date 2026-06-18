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
      echo "Usage: $0 [--internal|--release]"
      exit 0
      ;;
    *)
      echo "[snorkeling-readiness] unknown argument: $arg"
      exit 2
      ;;
  esac
done

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
ALLOWED_BRANCH="${SNORKELING_RELEASE_ALLOWED_BRANCH:-main}"
DIRTY="$(git status --porcelain)"

echo "[snorkeling-readiness] mode: ${MODE}"
echo "[snorkeling-readiness] branch: ${BRANCH} @ ${HEAD_SHA}"

if [[ "${MODE}" == "release" ]]; then
  [[ "${BRANCH}" == "${ALLOWED_BRANCH}" ]] || { echo "[snorkeling-readiness] release requires ${ALLOWED_BRANCH}"; exit 1; }
  [[ -z "${DIRTY}" ]] || { echo "[snorkeling-readiness] release requires clean tree"; exit 1; }
elif [[ -n "${DIRTY}" ]]; then
  echo "[snorkeling-readiness] internal mode: dirty tree allowed"
fi

./Scripts/check_main_target_isolation.sh

echo "[snorkeling-readiness] running xcodegen"
xcodegen generate

WATCH_DEST="${SNORKELING_WATCH_SIM_DEST:-platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)}"
IOS_DEST="${SNORKELING_IOS_SIM_DEST:-platform=iOS Simulator,name=iPhone 17 Pro}"

echo "[snorkeling-readiness] build Watch"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination "generic/platform=watchOS" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

echo "[snorkeling-readiness] build iOS"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination "generic/platform=iOS Simulator" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

echo "[snorkeling-readiness] focused Snorkeling suites"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination "${WATCH_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingNavigationReturnEngineTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingCommand04FoundationGateTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingAlarmsMarkersHapticsMissionModeTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingWatchPresentationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingWatchLayoutContractTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingWatchMainPromotionTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingPersistenceRecoveryTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingWatchRuntimeStorePersistenceTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingLogbookStoreTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingLocalizationParityTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingReleaseHardValidationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingArchitectureIsolationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingCrossDomainIsolationTests"

echo "[snorkeling-readiness] physical QA status: PENDING"
if [[ "${MODE}" == "release" ]]; then
  echo "[snorkeling-readiness] release mode: TestFlight/App Store remain NO-GO until physical evidence"
fi
echo "[snorkeling-readiness] PASS"
