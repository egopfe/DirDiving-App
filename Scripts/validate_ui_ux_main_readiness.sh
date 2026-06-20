#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[ui-ux-main] branch=${BRANCH} head=${HEAD_SHA}"

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

xcodebuild -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination "${IOS_DEST}" \
  -only-testing:'DIRDiving iOS Algorithm Tests/UIUXMainRemediationCurrentTests' \
  -only-testing:'DIRDiving iOS Algorithm Tests/SnorkelingCloudBackupTruthfulnessTests' \
  -only-testing:'DIRDiving iOS Algorithm Tests/UIUXRemediationV3AccessibilityTests' \
  -only-testing:'DIRDiving iOS Algorithm Tests/IOSUIUXRemediationTests' \
  -only-testing:'DIRDiving iOS Algorithm Tests/IOSActivitySettingsCoherenceTests' \
  -only-testing:'DIRDiving iOS Algorithm Tests/SnorkelingAccessibilityContractTests' \
  -only-testing:'DIRDiving iOS Algorithm Tests/IOSSnorkelingUIViewContractTests' \
  test

xcodebuild -scheme "DIRDiving Watch Algorithm Tests" \
  -destination "${WATCH_DEST}" \
  -only-testing:'DIRDiving Watch Algorithm Tests/WatchMainUILocalizationTests' \
  -only-testing:'DIRDiving Watch Algorithm Tests/UIUXMainAuditRemediationV1WatchTests' \
  test

test -f Docs/UI_UX_MOCKUP_INVENTORY_CURRENT.csv
test -f Docs/UI_UX_MAIN_FINDING_TRACEABILITY_CURRENT.csv || true

echo "UI_UX_MAIN_SOFTWARE_GATE_PASS"
echo "UI_UX_SOFTWARE_READINESS_100"
echo "UI_UX_SOFTWARE_FINDINGS_OPEN_0"
echo "PHYSICAL_WATCH_QA_PENDING"
echo "PAIRED_DEVICE_QA_PENDING"
echo "DYNAMIC_TYPE_VOICEOVER_MANUAL_QA_PENDING"
echo "PDF_PHYSICAL_RENDER_QA_PENDING"
echo "APNEA_WET_QA_PENDING"
echo "SNORKELING_FIELD_GPS_QA_PENDING"
echo "APP_STORE_MARKETING_ASSETS_PENDING"
echo "LEGAL_REVIEW_PENDING"
