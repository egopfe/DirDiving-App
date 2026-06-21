#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
echo "[release-legal-claims] branch=${BRANCH} head=${HEAD_SHA}"

if [[ "${BRANCH}" != "main" ]]; then
  echo "ERROR: validation requires main branch" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "[release-legal-claims] working tree dirty (continuing)"
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
./Scripts/validate_release_legal_claims.sh

test -f Shared/Utils/ReleaseLegalClaimsPolicy.swift
test -f Docs/CLAIMS_POLICY_REGISTRY_CURRENT.md
test -f Docs/CLAIMS_POLICY_REGISTRY_CURRENT.csv
test -f Docs/PROHIBITED_CLAIMS_ALLOWLIST_CURRENT.csv
test -f Docs/LEGAL_VERSIONING_AND_RECONSENT_POLICY_CURRENT.md
test -f Docs/RELEASE_CLAIMS_GATE_POLICY_CURRENT.md
test -f Docs/INCIDENT_RESPONSE_RUNBOOK_CURRENT.md
test -f Docs/RELEASE_ROLLBACK_PROCEDURE_CURRENT.md
test -f Docs/SUPPORT_ESCALATION_AND_SLA_CURRENT.md
test -f Docs/EXPORT_DISCLAIMER_POLICY_CURRENT.md
test -f Docs/WATCH_ULTRA_ENTITLEMENT_RELEASE_GATE_CURRENT.md
test -f Docs/RELEASE_LEGAL_CLAIMS_COMPLIANCE_REMEDIATION_REPORT_CURRENT.md
test -f Docs/RELEASE_LEGAL_FINDING_TRACEABILITY_CURRENT.csv
test -f Docs/RELEASE_LEGAL_EXTERNAL_QA_PENDING_CURRENT.md
test -f Docs/LEGAL_COPY_OWNERSHIP_CURRENT.md
test -f Docs/RELEASE_LEGAL_REQUIREMENT_TEST_MATRIX_CURRENT.csv
test -f Config/PrivacyInfo-Watch.xcprivacy
test -f iOSApp/Config/PrivacyInfo-iOS.xcprivacy

for package in \
  "Docs/QA_EVIDENCE/LEGAL_REVIEW" \
  "Docs/QA_EVIDENCE/APP_STORE_MARKETING" \
  "Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL" \
  "Docs/QA_EVIDENCE/CCR_EXTERNAL" \
  "Docs/QA_EVIDENCE/HARDWARE_ENTITLEMENT" \
  "Docs/QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER" \
  "Docs/QA_EVIDENCE/WATCH_IOS_SYNC" \
  "Docs/QA_EVIDENCE/ICLOUD_TWO_DEVICE"; do
  test -f "${package}/README.md"
  test -f "${package}/STATUS.md"
  test -f "${package}/EVIDENCE_TEMPLATE.md"
done

test -f Docs/QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/LEGAL_JOURNEY_TEMPLATE.md
test -f Docs/QA_EVIDENCE/APP_STORE_MARKETING/MARKETING_ASSET_CHECKLIST_CURRENT.md

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

echo "[release-legal-claims] build iOS MAIN"
run_build "DIRDiving iOS" 'generic/platform=iOS Simulator'

echo "[release-legal-claims] build Watch MAIN"
run_build "DIRDiving Watch App" 'generic/platform=watchOS Simulator'

echo "[release-legal-claims] iOS remediation suites"
run_tests "${IOS_SCHEME}" "${IOS_DEST}" \
  ReleaseLegalClaimsRemediationTests \
  IOSLegalSettingsLocalizationTests \
  SecurityPrivacyTrustRemediationTests \
  CSVMetadataRoundTripTests \
  SnorkelingAccessibilityContractTests \
  PlannerVisualContractTests

echo "[release-legal-claims] watch remediation suites"
run_tests "${WATCH_SCHEME}" "${WATCH_DEST}" \
  ReleaseLegalClaimsRemediationWatchTests \
  LegalAcceptanceGateTests \
  ActionButtonIntentsSafetyTests

echo "[release-legal-claims] Command 12 regression"
./Scripts/validate_test_qa_evidence_readiness.sh

cat <<EOF
RELEASE_LEGAL_CLAIMS_SOFTWARE_GATE_PASS
RELEASE_CLAIMS_SOFTWARE_READINESS_100
LEGAL_POSITIONING_DOCUMENTATION_READINESS_100
CLAIMS_TRACEABILITY_READINESS_100
RELEASE_GOVERNANCE_READINESS_100
SUPPORT_ESCALATION_DOCUMENTATION_READINESS_100
SOFTWARE_VERIFIABLE_FINDINGS_OPEN_0
EXTERNAL_LEGAL_COUNSEL_REVIEW_PENDING
APP_STORE_MARKETING_SIGN_OFF_PENDING
EXTERNAL_BUHLMANN_VALIDATION_PENDING
EXTERNAL_CCR_VALIDATION_PENDING
WATCH_ULTRA_ENTITLEMENT_FIELD_QA_PENDING
PHYSICAL_VOICEOVER_LEGAL_JOURNEY_QA_PENDING
PAIRED_DEVICE_FIELD_QA_PENDING
ICLOUD_TWO_DEVICE_QA_PENDING
APP_STORE_REVIEW_PENDING
EOF
