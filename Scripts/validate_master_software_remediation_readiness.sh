#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== Master software remediation readiness validation =="

fail() { echo "FAIL: $1" >&2; exit 1; }

[[ -f Docs/MASTER_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md ]] || fail "missing remediation report"
[[ -f Docs/MASTER_SOFTWARE_REMEDIATION_FINDING_STATUS_CURRENT.csv ]] || fail "missing finding status CSV"
[[ -f iOSApp/Services/IOSCompanionNavigationPersistence.swift ]] || fail "missing navigation persistence"

if rg -n 'BuhlmannEngine\.runtimeProjection' Tests/WatchAlgorithmTests/Support/Audit15OracleTestSupport.swift >/dev/null 2>&1; then
  fail "Audit15OracleTestSupport still references production runtimeProjection"
fi

if rg -q 'BuhlmannEngine\.runtimeProjection' Tests/WatchAlgorithmTests/Support/IndependentBuhlmannOracle.swift 2>/dev/null; then
  fail "IndependentBuhlmannOracle still calls BuhlmannEngine.runtimeProjection"
fi

xcodegen generate >/dev/null

IOS_DEST='platform=iOS Simulator,name=iPhone 17'
WATCH_DEST='platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)'

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination "$IOS_DEST" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build >/dev/null
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination "$WATCH_DEST" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build >/dev/null

export XCTestDisableAutomaticTestTimeouts=1
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination "$IOS_DEST" \
  -only-testing:'DIRDiving iOS Algorithm Tests/IOSCompanionNavigationRestorationTests' \
  -only-testing:'DIRDiving iOS Algorithm Tests/PerformanceConcurrencyBatteryRemediationTests/testTissueAnalyticsCacheBounded' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test >/dev/null

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination "$WATCH_DEST" \
  -only-testing:'DIRDiving Watch Algorithm Tests/IntegratedModesSequentialFlowTests' \
  -only-testing:'DIRDiving Watch Algorithm Tests/Audit15TTSScheduleOracleSweepTests' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test >/dev/null

echo "PASS: master software remediation readiness gates"
