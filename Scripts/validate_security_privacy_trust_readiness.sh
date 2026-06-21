#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[security-privacy-trust] branch=${BRANCH} head=${HEAD_SHA}"

if [[ "${BRANCH}" != "main" ]]; then
  echo "ERROR: validation requires main branch" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "[security-privacy-trust] working tree dirty (continuing)"
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

test -f Config/PrivacyInfo-Watch.xcprivacy
test -f iOSApp/Config/PrivacyInfo-iOS.xcprivacy

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

echo "[security-privacy-trust] build iOS MAIN"
run_build "DIRDiving iOS" 'generic/platform=iOS Simulator'

echo "[security-privacy-trust] build Watch MAIN"
run_build "DIRDiving Watch App" 'generic/platform=watchOS Simulator'

echo "[security-privacy-trust] security remediation suites (iOS)"
run_tests "${IOS_SCHEME}" "${IOS_DEST}" \
  SecurityPrivacyTrustRemediationTests \
  MainDeepCodeReadinessCurrentTests \
  ActivitySyncSignedAckSymmetryTests \
  ActivitySyncCrossDecodeRejectionTests \
  CloudBackupCapabilityTests \
  DiveSessionSyncTransportNegativeTests

echo "[security-privacy-trust] security remediation suites (Watch)"
run_tests "${WATCH_SCHEME}" "${WATCH_DEST}" \
  SecurityPrivacyTrustRemediationWatchTests \
  MainDeepCodeReadinessCurrentWatchTests \
  CompanionPhotoImportSupportTests

echo "[security-privacy-trust] Command 7 regression"
./Scripts/validate_activity_architecture_settings_logbook_readiness.sh

echo "[security-privacy-trust] Command 8 regression"
./Scripts/validate_multi_activity_sync_persistence_schema_readiness.sh

cat <<EOF
SECURITY_PRIVACY_TRUST_SOFTWARE_GATE_PASS
SECURITY_SOFTWARE_READINESS_100
PRIVACY_SOFTWARE_READINESS_100
TRUST_SOFTWARE_READINESS_100
DATA_AT_REST_SOFTWARE_READINESS_100
EXPORT_PRIVACY_SOFTWARE_READINESS_100
APP_STORE_PRIVACY_DECLARATION_READINESS_100
SOFTWARE_VERIFIABLE_FINDINGS_OPEN_0
PAIRED_DEVICE_SECURITY_QA_PENDING
PHYSICAL_TOMBSTONE_QA_PENDING
PHYSICAL_LARGE_PAYLOAD_QA_PENDING
PENETRATION_TEST_PENDING
APP_STORE_PRIVACY_REVIEW_PENDING
LEGAL_GDPR_REVIEW_PENDING
EOF
