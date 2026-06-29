#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() { echo "FAIL: $1" >&2; exit 1; }

[[ -f Docs/MASTER_CLAIMS_EVIDENCE_MATRIX_CURRENT.csv ]] || fail "missing claims matrix"
[[ -f Scripts/validate_release_legal_claims_readiness.sh ]] || fail "missing legal claims validator"

bash Scripts/validate_release_legal_claims_readiness.sh
echo "PASS: release claims evidence validators"
