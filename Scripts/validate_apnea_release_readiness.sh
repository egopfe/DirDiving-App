#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse --short HEAD)"
ALLOWED_BRANCH="${APNEA_RELEASE_ALLOWED_BRANCH:-main}"

echo "[apnea-readiness] start Apnea release-hard validation on branch: ${BRANCH} @ ${HEAD_SHA}"

case "${BRANCH}" in
  "${ALLOWED_BRANCH}"|integration/full-computer)
    echo "[apnea-readiness] canonical branch: ${BRANCH}"
    ;;
  *)
    echo "[apnea-readiness] note: Apnea release-hard is validated on ${ALLOWED_BRANCH}; continuing on ${BRANCH}"
    ;;
esac

if [[ -n "$(git status --porcelain)" ]]; then
  echo "[apnea-readiness] warning: working tree is not clean"
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

required_sources=(
  "Shared/Utils/ApneaSessionEngine.swift"
  "Shared/Utils/ApneaLifecycleStateMachine.swift"
  "Shared/Utils/ApneaSessionCheckpoint.swift"
  "Shared/Utils/DepthMeasurementFeed.swift"
  "Utils/ApneaReleaseSelfCheck.swift"
  "Services/ApneaWatchRuntimeStore.swift"
  "Views/ApneaView.swift"
)

echo "[apnea-readiness] checking required Apnea sources"
for src in "${required_sources[@]}"; do
  [[ -f "$src" ]] || { echo "[apnea-readiness] missing source: $src"; exit 1; }
done

echo "[apnea-readiness] checking ApneaView MAIN promotion in project.yml"
grep -q -- "- ApneaView.swift" project.yml && {
  echo "[apnea-readiness] ApneaView must not remain excluded from MAIN Watch target"
  exit 1
}
grep -q -- "Services/ApneaWatchRuntimeStore.swift" project.yml || {
  echo "[apnea-readiness] ApneaWatchRuntimeStore must be in MAIN Watch target"
  exit 1
}

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

WATCH_DEST="${APNEA_WATCH_SIM_DEST:-platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)}"
IOS_DEST="${APNEA_IOS_SIM_DEST:-platform=iOS Simulator,name=iPhone 17}"

echo "[apnea-readiness] build Watch"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination "generic/platform=watchOS" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO >/tmp/dirdiving_apnea_watch_build.log

echo "[apnea-readiness] build iOS"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination "${IOS_DEST}" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO >/tmp/dirdiving_apnea_ios_build.log

echo "[apnea-readiness] test Watch algorithms (Apnea release-hard suite)"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination "${WATCH_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaReleaseHardValidationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaMockupReferenceMatrixTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaLifecycleEngineTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaOperationalEventEngineTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaTimeRecoveryCheckpointEngineTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaWatchPresentationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaWatchUIViewContractTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaLogbookStoreTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaSyncWatchReceiverTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaSuspendResumeLifecycleIntegrationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaCheckpointFailureInjectionTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaArchitectureIsolationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaCommand04PromotionGateTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaWatchRuntimeStoreTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaWatchMainPromotionTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaWatchLayoutContractTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaPlanPackageWatchNegativeTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaPlanRevisionIdempotencyTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaSessionSyncTransportNegativeWatchTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaOfflineOnlineEndToEndIntegrationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/ApneaDomainModelTests" >/tmp/dirdiving_apnea_watch_tests.log

echo "[apnea-readiness] test iOS algorithms (Apnea companion + sync)"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination "${IOS_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  -only-testing:"DIRDiving iOS Algorithm Tests/ApneaReleaseHardValidationTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSApneaCompanionTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSApneaLogbookAnalyticsTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSApneaMapEquipmentExportTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/ApneaSyncCodecTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/ApneaSyncCodecNegativePathTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/ApneaSessionSyncTransportNegativeTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/ApneaSyncAckNegativeTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/ApneaOfflineOnlineEndToEndIntegrationTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/ApneaSessionMergeIntegrityTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/ApneaCloudBackupStubTruthfulnessTests" >/tmp/dirdiving_apnea_ios_tests.log

echo "[apnea-readiness] physical QA status: PENDING (no automated PASS for device evidence)"
echo "[apnea-readiness] PASS"
