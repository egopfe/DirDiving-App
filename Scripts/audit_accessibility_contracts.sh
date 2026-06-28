#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "[a11y-contracts] checking Watch underwater + water auto-open accessibility keys EN/IT"

keys=(
  watch.hardware.hint.a11y
  watch.hardware.crown.screen
  nav.underwater.blocked.diving.a11y
  nav.underwater.blocked.apnea.a11y
  nav.underwater.blocked.snorkeling.a11y
  settings.water_auto_open.apply_now.a11y.hint
  settings.water_auto_open.cold_launch_limitation.a11y
  settings.water_auto_open.system_setup.a11y
  settings.mode_switch.a11y.hint
)

for key in "${keys[@]}"; do
  grep -q "\"${key}\"" Resources/en.lproj/Localizable.strings || {
    grep -q "\"${key}\"" iOSApp/Resources/en.lproj/Localizable.strings || {
      echo "FAIL missing EN a11y key: ${key}" >&2
      exit 1
    }
  }
  grep -q "\"${key}\"" Resources/it.lproj/Localizable.strings || {
    grep -q "\"${key}\"" iOSApp/Resources/it.lproj/Localizable.strings || {
      echo "FAIL missing IT a11y key: ${key}" >&2
      exit 1
    }
  }
done

for file in Views/WatchUnderwaterPrimaryActionHintView.swift Views/WatchWaterAutoOpenSettingsView.swift iOSApp/Views/Components/IOSCompanionSettingsModeSwitcher.swift; do
  grep -q accessibilityLabel "$file" || { echo "FAIL missing accessibilityLabel in $file" >&2; exit 1; }
done

echo "[a11y-contracts] PASS"
