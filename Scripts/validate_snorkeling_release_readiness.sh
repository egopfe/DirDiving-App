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
  python3 ./Scripts/validate_snorkeling_qa_evidence.py --release || {
    echo "[snorkeling-readiness] release requires signed physical QA evidence"
    exit 1
  }
elif [[ -n "${DIRTY}" ]]; then
  echo "[snorkeling-readiness] internal mode: dirty tree allowed (clean commit validation pending)"
fi

python3 ./Scripts/validate_snorkeling_qa_evidence.py --internal

./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh

echo "[snorkeling-readiness] running xcodegen"
# shellcheck source=Scripts/lib/xcodegen_once.sh
source "${ROOT_DIR}/Scripts/lib/xcodegen_once.sh"
xcodegen_once

required_docs=(
  "Docs/SNORKELING_ARCHITECTURE.md"
  "Docs/SNORKELING_RELEASE_CHECKLIST.md"
  "Docs/SNORKELING_RELEASE_HARD_TEST_MATRIX.md"
  "Docs/DIR_DIVING_SNORKELING_RELEASE_HARD_VALIDATION_REPORT.md"
  "Docs/AUDIT_SNORKELING_RELEASE_GATE_CURRENT.md"
  "Docs/SNORKELING_RELEASE_GATE_REMEDIATION_REPORT_CURRENT.md"
  "Docs/SNORKELING_IOS_MAPS_SYNC_EXPORT_REMEDIATION_REPORT_V1.0.md"
)

echo "[snorkeling-readiness] checking required docs"
for doc in "${required_docs[@]}"; do
  [[ -f "$doc" ]] || { echo "[snorkeling-readiness] missing doc: $doc"; exit 1; }
done

echo "[snorkeling-readiness] checking mockup matrix count"
python3 - <<'PY'
from pathlib import Path
import re
text = Path("Utils/SnorkelingMockupReferenceMatrix.swift").read_text(encoding="utf-8")
ids = re.findall(r'id: "(SNORKELING_[^"]+)"', text)
assert len(ids) == 10, f"expected 10 mockup ids, got {len(ids)}"
assert len(set(ids)) == 10, "duplicate mockup ids"
print("[snorkeling-readiness] mockup matrix ok (10 entries)")
PY

ref_dir="Docs/ReferenceUI/Snorkeling"
for png in SNORKELING_WATCH_01_READY.png SNORKELING_WATCH_02_SURFACE_DASHBOARD.png SNORKELING_WATCH_03_DIP_IN_PROGRESS.png SNORKELING_WATCH_04_WAYPOINT_NAVIGATION.png SNORKELING_WATCH_05_RETURN_TO_ENTRY.png SNORKELING_WATCH_06_SAVE_MARKER.png SNORKELING_WATCH_07_SESSION_SUMMARY.png SNORKELING_IOS_01_DASHBOARD.png SNORKELING_IOS_02_ROUTE_PLANNER.png SNORKELING_IOS_03_SESSION_DETAIL.png; do
  [[ -f "${ref_dir}/${png}" ]] || { echo "[snorkeling-readiness] missing reference PNG: ${png}"; exit 1; }
done

WATCH_DEST="${SNORKELING_WATCH_SIM_DEST:-platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)}"
IOS_DEST="${SNORKELING_IOS_SIM_DEST:-platform=iOS Simulator,name=iPhone 17 Pro}"

echo "[snorkeling-readiness] build Watch"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination "generic/platform=watchOS" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

echo "[snorkeling-readiness] build iOS"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination "generic/platform=iOS Simulator" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

echo "[snorkeling-readiness] Watch foundation + release-hard suites"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination "${WATCH_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingDomainModelTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingSensorGPSIngestionTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingLifecycleEngineTests" \
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
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingMockupReferenceMatrixTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingWatchUIViewContractTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingArchitectureIsolationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingCrossDomainIsolationTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingSessionSyncTransportNegativeWatchTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingWatchPendingQueueTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/SnorkelingRouteAckWatchTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/FullComputerTargetMembershipTests" \
  -only-testing:"DIRDiving Watch Algorithm Tests/DIRModesAndStartupFlowTests"

echo "[snorkeling-readiness] iOS Commands 08–12 focused suites"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination "${IOS_DEST}" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSSnorkelingCompanionTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSSnorkelingRoutePlannerTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/SnorkelingRouteSyncCodecTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSSnorkelingLogbookAnalyticsTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSSnorkelingMapEquipmentExportTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/SnorkelingSessionSyncCodecTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/SnorkelingSessionSyncTransportNegativeTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/SnorkelingSessionSyncInterruptedTransferTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/SnorkelingRouteAckRoundTripTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/SnorkelingLegacyV1TransportTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/SnorkelingDuplicateIgnoredImportTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSSnorkelingDashboardMapGapTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSSnorkelingNoGPSPresentationTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSSnorkelingExportServiceE2ETests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/SnorkelingPhotoMetadataSanitizationTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSSnorkelingReleaseHardValidationTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/IOSSnorkelingUIViewContractTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/SnorkelingQAEvidenceCatalogTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/SnorkelingAccessibilityContractTests"

echo "[snorkeling-readiness] physical QA status: PENDING (excluded from internal code readiness)"
if [[ "${MODE}" == "release" ]]; then
  echo "[snorkeling-readiness] release mode: TestFlight/App Store remain NO-GO until physical evidence PASS"
fi
echo "[snorkeling-readiness] PASS"
