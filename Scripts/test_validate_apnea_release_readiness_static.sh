#!/usr/bin/env bash
# Static checks for validate_apnea_release_readiness.sh (no xcodebuild).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT_DIR}/Scripts/validate_apnea_release_readiness.sh"

fail() { echo "[apnea-script-test] FAIL: $1"; exit 1; }
pass() { echo "[apnea-script-test] PASS: $1"; }

[[ -f "$SCRIPT" ]] || fail "script missing"
[[ -x "$SCRIPT" ]] || fail "script not executable"

grep -q 'canonical branch' "$SCRIPT" || fail "missing canonical branch message"
grep -q 'APNEA_RELEASE_ALLOWED_BRANCH' "$SCRIPT" || fail "missing allowed branch override"
grep -q 'main' "$SCRIPT" || fail "main not referenced"
grep -q 'ApneaSuspendResumeLifecycleIntegrationTests' "$SCRIPT" || fail "suspend/resume suite not in script"
grep -q 'physical QA status: PENDING' "$SCRIPT" || fail "must not auto-mark physical QA PASS"

if grep -q 'expected branch integration/full-computer (continuing)' "$SCRIPT"; then
  fail "stale integration/full-computer warning still present"
fi

pass "validate_apnea_release_readiness.sh static policy"
