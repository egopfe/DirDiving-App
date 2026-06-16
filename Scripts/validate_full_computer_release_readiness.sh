#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="$(git branch --show-current)"
echo "[fc-readiness] start Full Computer release-hard validation on branch: ${BRANCH}"

if [[ "${BRANCH}" != "integration/full-computer" ]]; then
  echo "[fc-readiness] warning: expected branch integration/full-computer (continuing)"
fi

./Scripts/check_secrets.sh

echo "[fc-readiness] running xcodegen"
xcodegen generate

echo "[fc-readiness] checking xcodegen drift"
git diff --exit-code -- DIRDiving.xcodeproj

required_docs=(
  "Docs/FULL_COMPUTER_ARCHITECTURE.md"
  "Docs/FULL_COMPUTER_RELEASE_HARD_TEST_MATRIX.md"
  "Docs/FULL_COMPUTER_RELEASE_CHECKLIST.md"
  "Docs/DIR_DIVING_FULL_COMPUTER_RELEASE_HARD_VALIDATION_REPORT.md"
  "Docs/SAFETY_DISCLAIMER.md"
  "Docs/BUILD_AND_XCODEGEN_WORKFLOW.md"
)

echo "[fc-readiness] checking required docs"
for doc in "${required_docs[@]}"; do
  [[ -f "$doc" ]] || { echo "[fc-readiness] missing doc: $doc"; exit 1; }
done

echo "[fc-readiness] checking mockup matrix count"
python3 - <<'PY'
from pathlib import Path
import re
text = Path("Utils/FullComputerMockupReferenceMatrix.swift").read_text(encoding="utf-8")
ids = re.findall(r'id: "FC_UI_(\d+)"', text)
assert len(ids) == 25, f"expected 25 mockup ids, got {len(ids)}"
assert len(set(ids)) == 25, "duplicate mockup ids"
print("[fc-readiness] mockup matrix ok (25 entries)")
PY

echo "[fc-readiness] build Watch"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination "generic/platform=watchOS" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO >/tmp/dirdiving_fc_watch_build.log

echo "[fc-readiness] build iOS"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination "platform=iOS Simulator,name=iPhone 17" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO >/tmp/dirdiving_fc_ios_build.log

echo "[fc-readiness] test Watch algorithms (Full Computer release-hard suite)"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination "platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -only-testing:"DIRDiving Watch Algorithm Tests/FullComputerReleaseHardValidationTests" -only-testing:"DIRDiving Watch Algorithm Tests/FullComputerMockupReferenceMatrixTests" -only-testing:"DIRDiving Watch Algorithm Tests/FullComputerRuntimeEngineTests" -only-testing:"DIRDiving Watch Algorithm Tests/FullComputerDecoSolverTests" -only-testing:"DIRDiving Watch Algorithm Tests/FullComputerRecoveryCheckpointTests" -only-testing:"DIRDiving Watch Algorithm Tests/FullComputerUIStateMatrixTests" >/tmp/dirdiving_fc_watch_tests.log

echo "[fc-readiness] test iOS algorithms (Bühlmann golden fixtures)"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination "platform=iOS Simulator,name=iPhone 17" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -only-testing:"DIRDiving iOS Algorithm Tests/BuhlmannGoldenFixtureTests" -only-testing:"DIRDiving iOS Algorithm Tests/PlannerRegressionFixtureTests" >/tmp/dirdiving_fc_ios_tests.log

echo "[fc-readiness] PASS"
