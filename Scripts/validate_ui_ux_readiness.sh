#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[ui-ux-readiness] branch: $(git branch --show-current) @ $(git rev-parse --short HEAD)"

# shellcheck source=Scripts/lib/xcodegen_once.sh
source "${ROOT_DIR}/Scripts/lib/xcodegen_once.sh"
xcodegen_once

./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh
python3 ./Scripts/validate_mockup_paths.py

IOS_DEST='platform=iOS Simulator,name=iPhone 17'
WATCH_DEST='platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)'

run_ios_tests() {
  xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" \
    -destination "$IOS_DEST" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    -only-testing:"DIRDiving iOS Algorithm Tests/IOSUIUXRemediationTests" \
    -only-testing:"DIRDiving iOS Algorithm Tests/IOSCompanionActivitySelectionTests" \
    -only-testing:"DIRDiving iOS Algorithm Tests/IOSActivitySettingsCoherenceTests" \
    -only-testing:"DIRDiving iOS Algorithm Tests/IOSSnorkelingUIViewContractTests"
}

run_watch_tests() {
  xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" \
    -destination "$WATCH_DEST" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    -only-testing:"DIRDiving Watch Algorithm Tests/WatchActivitySettingsOwnershipTests" \
    -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingMockupReferenceMatrixTests" \
    -only-testing:"DIRDiving Watch Algorithm Tests/ApneaMockupReferenceMatrixTests"
}

if command -v xcbeautify >/dev/null 2>&1; then
  run_ios_tests | xcbeautify --quieter
  run_watch_tests | xcbeautify --quieter
else
  run_ios_tests
  run_watch_tests
fi

echo "UI_UX_SOFTWARE_READINESS_GATE_PASS"
echo "UI_UX_PHYSICAL_QA_PENDING"
