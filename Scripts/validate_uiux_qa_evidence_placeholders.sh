#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "[uiux-qa-placeholders] validating QA evidence template folders"

required=(
  Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_WATER_LOCK/README.md
  Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_ACTION_BUTTON/README.md
  Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_PREFERRED/README.md
  Docs/QA_EVIDENCE/PAIRED_WATCH_IOS_UI_QA_TEMPLATE.md
  Docs/QA_EVIDENCE/PDF_PHYSICAL_RENDER_QA_TEMPLATE.md
  Docs/QA_EVIDENCE/VISUAL_REGRESSION_BASELINE_CAPTURE_TEMPLATE.md
  Docs/QA_EVIDENCE/PHYSICAL_41MM_WATCH_VISUAL_QA_TEMPLATE.md
  Docs/QA_EVIDENCE/ACCESSIBILITY_MANUAL_QA_TEMPLATE.md
)

missing=0
for path in "${required[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "MISSING template: $path" >&2
    missing=$((missing + 1))
  fi
done

if [[ "$missing" -gt 0 ]]; then
  echo "FAIL $missing missing QA templates" >&2
  exit 1
fi

echo "[uiux-qa-placeholders] PASS"
