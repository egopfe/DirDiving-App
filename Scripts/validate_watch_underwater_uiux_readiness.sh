#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "[watch-underwater-uiux] software readiness checks"

files=(
  Utils/WatchLaunchRoutingPolicy.swift
  Utils/WatchIntentSafetyPolicy.swift
  Utils/WatchUnderwaterNavigationClampPolicy.swift
  Utils/WatchAppShortcutErrors.swift
)

for f in "${files[@]}"; do
  [[ -f "$f" ]] || { echo "FAIL missing $f" >&2; exit 1; }
done

grep -q beginInitialLaunch Services/DIRActivitySelectionStore.swift
grep -q WatchUnderwaterNavigationClampPolicy Views/ContentView.swift
grep -q routePrimaryActionIfUnderwaterSession Services/ActionButtonIntents.swift
grep -q cold_launch_limitation Resources/en.lproj/Localizable.strings

echo "[watch-underwater-uiux] PASS"
