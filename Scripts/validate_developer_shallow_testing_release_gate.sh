#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() { echo "FAIL: $1" >&2; exit 1; }

grep -q 'allowsShallowDepthDivingTesting' Utils/DeveloperSettings.swift || fail "missing shallow FC testing gate"
grep -q 'allowsShallowGaugeTesting' Utils/DeveloperSettings.swift || fail "missing shallow gauge testing gate"
grep -q 'isDeveloperSectionVisible' Utils/DeveloperSettings.swift || fail "missing developer section gate"

echo "PASS: developer shallow testing release gate hooks present"
