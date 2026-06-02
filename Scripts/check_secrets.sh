#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[secrets] scanning repository for obvious secrets"
python3 - <<'PY'
import re
from pathlib import Path

root = Path(".")
skip_dirs = {".git", ".worktrees", "DIRDiving.xcodeproj", ".cursor"}
skip_suffixes = {".png", ".jpg", ".jpeg", ".pdf", ".zip", ".pptx"}
pattern = re.compile(
    r"(AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,}|-----BEGIN (RSA|EC|OPENSSH|PRIVATE) KEY-----|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z\-_]{35}|sk_(live|test)_[0-9A-Za-z]{16,}|(api[_-]?key|secret|token|password)\s*[:=]\s*[\"'][^\"']{12,}[\"'])",
    re.IGNORECASE,
)

hits = []
for path in root.rglob("*"):
    if not path.is_file():
        continue
    if any(part in skip_dirs for part in path.parts):
        continue
    if path.suffix.lower() in skip_suffixes:
        continue
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        continue
    match = pattern.search(text)
    if match:
        line = text.count("\n", 0, match.start()) + 1
        hits.append(f"{path}:{line}: {match.group(0)[:120]}")

if hits:
    print("[secrets] potential secret(s) detected:")
    for hit in hits[:50]:
        print(hit)
    raise SystemExit(1)

print("[secrets] no obvious secrets detected")
PY
