#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[ios-main-algorithm-math] branch=${BRANCH} head=${HEAD_SHA}"

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

IOS_DEST='platform=iOS Simulator,name=iPhone 17'
WATCH_DEST='platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)'

run_scheme_tests() {
  local scheme="$1"
  local dest="$2"
  xcodebuild -project DIRDiving.xcodeproj -scheme "${scheme}" \
    -destination "${dest}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
}

if command -v xcbeautify >/dev/null 2>&1; then
  run_scheme_tests "DIRDiving iOS Algorithm Tests" "${IOS_DEST}" | xcbeautify --quieter
  run_scheme_tests "DIRDiving Watch Algorithm Tests" "${WATCH_DEST}" | xcbeautify --quieter
else
  run_scheme_tests "DIRDiving iOS Algorithm Tests" "${IOS_DEST}"
  run_scheme_tests "DIRDiving Watch Algorithm Tests" "${WATCH_DEST}"
fi

echo "IOS_MAIN_ALGORITHM_MATH_SOFTWARE_GATE_PASS"
echo "INTERNAL_MATHEMATICAL_READINESS_100"
echo "EXTERNAL_BUHLMANN_VALIDATION_PENDING"
echo "EXTERNAL_CCR_VALIDATION_PENDING"
echo "PHYSICAL_PDF_RENDER_QA_PENDING"
echo "PHYSICAL_DEVICE_QA_PENDING"
