#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[readiness] start MAIN release-readiness validation"

if [[ "$(git branch --show-current)" != "main" ]]; then
  echo "[readiness] must run on branch main"
  exit 1
fi

./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh

echo "[readiness] running xcodegen"
# shellcheck source=Scripts/lib/xcodegen_once.sh
source "${ROOT_DIR}/Scripts/lib/xcodegen_once.sh"
xcodegen_once

echo "[readiness] checking xcodegen drift"
git diff --exit-code -- DIRDiving.xcodeproj

echo "[readiness] checking localization parity (Watch)"
python3 - <<'PY'
from pathlib import Path
import re
def keys(path):
    txt = Path(path).read_text(encoding="utf-8")
    return set(re.findall(r'"([^"]+)"\s*=', txt))
en = keys("Resources/en.lproj/Localizable.strings")
it = keys("Resources/it.lproj/Localizable.strings")
if en != it:
    print("[l10n] mismatch Watch keys")
    print("missing in it:", sorted(en-it)[:20])
    print("missing in en:", sorted(it-en)[:20])
    raise SystemExit(1)
print("[l10n] Watch EN/IT parity ok")
PY

echo "[readiness] checking localization parity (iOS)"
python3 - <<'PY'
from pathlib import Path
import re
def keys(path):
    txt = Path(path).read_text(encoding="utf-8")
    return set(re.findall(r'"([^"]+)"\s*=', txt))
en = keys("iOSApp/Resources/en.lproj/Localizable.strings")
it = keys("iOSApp/Resources/it.lproj/Localizable.strings")
if en != it:
    print("[l10n] mismatch iOS keys")
    print("missing in it:", sorted(en-it)[:20])
    print("missing in en:", sorted(it-en)[:20])
    raise SystemExit(1)
print("[l10n] iOS EN/IT parity ok")
PY

required_docs=(
  "Docs/BUILD_AND_XCODEGEN_WORKFLOW.md"
  "Docs/RELEASE_CHECKLIST.md"
  "Docs/SAFETY_DISCLAIMER.md"
  "Docs/TESTFLIGHT_REVIEW_NOTES.md"
  "Docs/APP_STORE_REVIEW_NOTES.md"
  "Docs/SECURITY_STATIC_CHECKLIST.md"
  "Docs/SECURITY_PRIVACY_RELEASE_EVIDENCE.md"
  "Docs/QA_EVIDENCE_PACK_TEMPLATE.md"
  "Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md"
  "Docs/IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md"
  "Docs/WATCH_IOS_SYNC_QA_MATRIX.md"
  "Docs/ICLOUD_TWO_DEVICE_QA_MATRIX.md"
  "Docs/CSV_SUBSURFACE_QA_MATRIX.md"
  "Docs/PLANNER_GOLDEN_VALIDATION_QA_MATRIX.md"
  "Docs/TESTFLIGHT_RELEASE_GATE_CHECKLIST.md"
  "Docs/APP_STORE_RELEASE_GATE_CHECKLIST.md"
)

echo "[readiness] checking required docs"
for doc in "${required_docs[@]}"; do
  [[ -f "$doc" ]] || { echo "[readiness] missing doc: $doc"; exit 1; }
done

echo "[readiness] build Watch"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination "generic/platform=watchOS" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO >/tmp/dirdiving_watch_build.log

echo "[readiness] build iOS"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination "platform=iOS Simulator,name=iPhone 17" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO >/tmp/dirdiving_ios_build.log

echo "[readiness] test Watch algorithms"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination "platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO >/tmp/dirdiving_watch_tests.log

echo "[readiness] test iOS algorithms"
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination "platform=iOS Simulator,name=iPhone 17" test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO >/tmp/dirdiving_ios_tests.log

echo "[readiness] PASS"
