#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() { echo "FAIL: $1" >&2; exit 1; }

if rg -n 'EXTERNAL_VALIDATION: PASS|EXTERNAL_BUHLMANN.*PASS|PENDING_EXTERNAL_VALIDATION,PASS' Docs/MASTER_*CURRENT* 2>/dev/null | rg -v 'PENDING_EXTERNAL|NOT_EXECUTED|NOT READY|not claim|No claim|NOT certified|non-certified' >/dev/null; then
  fail "found possible fake external validation claim"
fi

echo "PASS: no fake external validation PASS claims detected in MASTER docs scan"
