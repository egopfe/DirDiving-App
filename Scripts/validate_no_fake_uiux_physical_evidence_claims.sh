#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "[no-fake-uiux-claims] scanning remediation docs for forbidden physical claims"

FORBIDDEN=(
  "Water Lock physical QA passed"
  "Action Button underwater physically validated"
  "physical QA complete"
  "App Store ready"
  "automatically launches whenever Apple Watch enters water"
  "guaranteed automatic system launch"
  "59/59 pixel pass"
)

docs=(
  Docs/MASTER_UI_UX_REMEDIATION_TO_100_REPORT_CURRENT.md
  Docs/MASTER_UI_UX_SOFTWARE_READINESS_TO_100_CURRENT.md
)

for doc in "${docs[@]}"; do
  [[ -f "$doc" ]] || continue
  for phrase in "${FORBIDDEN[@]}"; do
    if grep -qi "$phrase" "$doc"; then
      echo "FAIL forbidden claim in $doc: $phrase" >&2
      exit 1
    fi
  done
done

echo "[no-fake-uiux-claims] PASS"
