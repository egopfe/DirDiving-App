#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

MODE="${1:---internal}"
FAIL=0

require_file() {
  if [[ ! -f "$1" ]]; then
    echo "MISSING: $1"
    FAIL=1
  fi
}

for f in \
  Docs/APPLE_SHALLOW_DEPTH_ENTITLEMENT_SUPPORT.md \
  Docs/APPLE_SHALLOW_DEPTH_QA_PLAN.md \
  Docs/SENSOR_SOURCE_POLICY.md \
  Docs/DEPTH_CAPABILITY_MATRIX.md \
  Docs/APPLE_SHALLOW_DEPTH_ENTITLEMENT_IMPLEMENTATION_REPORT_CURRENT.md \
  Config/DIRDiving.WithShallowDepth.entitlements; do
  require_file "$f"
done

for d in Docs/QA_EVIDENCE/SHALLOW_*; do
  require_file "$d/README.md"
done

if [[ "$MODE" == "--release" ]]; then
  pending=$(grep -R "Status:\*\* PENDING" Docs/QA_EVIDENCE/SHALLOW_* 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$pending" -lt 1 ]]; then
    echo "Expected PENDING shallow QA templates"
    FAIL=1
  fi
  echo "RELEASE_GATE: shallow physical QA must be signed before release (--release fails by design until evidence PASS)."
  FAIL=1
else
  echo "INTERNAL_GATE: documentation + templates present; physical QA may remain PENDING."
fi

exit "$FAIL"
