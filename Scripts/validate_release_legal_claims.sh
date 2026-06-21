#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[release-legal-claims] prohibited-claims scan"
python3 "${ROOT_DIR}/Scripts/scan_prohibited_claims.py"
