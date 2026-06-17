#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
echo "[apnea-readiness] start Apnea release-hard validation on branch: ${BRANCH}"

if [[ "${BRANCH}" != "integration/full-computer" ]]; then
  echo "[apnea-readiness] warning: expected branch integration/full-computer (continuing)"
fi

./Scripts/check_secrets.sh
./Scripts/audit_localization.sh

echo "[apnea-readiness] running xcodegen"
xcodegen generate

echo "[apnea-readiness] checking xcodegen drift"
git diff --exit-code -- DIRDiving.xcodeproj

required_docs=(
  "Docs/APNEA_ARCHITECTURE.md"
  "Docs/APNEA_RELEASE_HARD_TEST_MATRIX.md"
  "Docs/APNEA_RELEASE_CHECKLIST.md"
  "Docs/DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md"
  "Docs/SAFETY_DISCLAIMER.md"
  "Docs/BUILD_AND_XCODEGEN_WORKFLOW.md"
)

echo "[apnea-readiness] checking required docs"
for doc in "${required_docs[@]}"; do
  [[ -f "$doc" ]] || { echo "[apnea-readiness] missing doc: $doc"; exit 1; }
done

echo "[apnea-readiness] checking mockup matrix count"
python3 - <<'PY'
from pathlib import Path
import re
text = Path("Utils/ApneaMockupReferenceMatrix.swift").read_text(encoding="utf-8")
ids = re.findall(r'id: "(APNEA_[^"]+)"', text)
assert len(ids) == 23, f"expected 23 mockup ids, got {len(ids)}"
assert len(set(ids)) == 23, "duplicate mockup ids"
print("[apnea-readiness] mockup matrix ok (23 entries)")
PY

echo "[apnea-readiness] build Watch"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination "generic/platform=watchOS" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO >/tmp/dirdiving_apnea_watch_build.log

echo "[apnea-readiness] build iOS"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination "platform=iOS Simulator,name=iPhone 17" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO >/tmp/dirdiving_apnea_ios_build.log

echo "[apnea-readiness] test Watch algorithms (Apnea release-hard suite)"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination "platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaReleaseHardValidationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaMockupReferenceMatrixTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaLifecycleEngineTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaOperationalEventEngineTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaTimeRecoveryCheckpointEngineTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaWatchPresentationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaWatchUIViewContractTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaLogbookStoreTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaSyncWatchReceiverTests" >/tmp/dirdiving_apnea_watch_tests.log

echo "[apnea-readiness] test iOS algorithms (Apnea companion + sync)"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination "platform=iOS Simulator,name=iPhone 17" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  -only-testing:"DIRDiving iOS Algorithm Tests/ApneaReleaseHardValidationTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSApneaCompanionTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSApneaLogbookAnalyticsTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSApneaMapEquipmentExportTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/ApneaSyncCodecTests" >/tmp/dirdiving_apnea_ios_tests.log

echo "[apnea-readiness] PASS"
