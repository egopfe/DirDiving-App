#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() { echo "FAIL: $1" >&2; exit 1; }

if rg -n 'PHYSICAL_QA[^,]*PASS|PENDING_PHYSICAL[^,]*,PASS|physical Watch QA: PASS|Wet QA: PASS|PHYSICAL_WATCH_QA: PASS' Docs/MASTER_*CURRENT* 2>/dev/null | rg -v 'NOT_PASSED|NOT_EXECUTED|PENDING_PHYSICAL|0%|Software .* PASS' >/dev/null; then
  fail "found possible fake physical QA PASS claim in MASTER docs"
fi

echo "PASS: no fake physical evidence PASS claims detected in MASTER docs scan"
