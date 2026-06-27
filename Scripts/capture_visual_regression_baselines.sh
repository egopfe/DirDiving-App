#!/usr/bin/env bash
set -euo pipefail
# Scaffold: capture simulator/device screenshots for mockup pixel-diff QA.
# Does NOT mark pixel diff as passed — outputs go to Docs/QA_EVIDENCE/PHYSICAL_PIXEL_DIFF/
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${ROOT}/Docs/QA_EVIDENCE/PHYSICAL_PIXEL_DIFF/captures"
mkdir -p "$OUT"
echo "[capture-vr] scaffold ready — output dir: $OUT"
echo "[capture-vr] manual step: run UI tests or take device screenshots and store beside mockups/"
echo "[capture-vr] status: PENDING_MANUAL_EXECUTION"
exit 0
