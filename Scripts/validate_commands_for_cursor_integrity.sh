#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() { echo "FAIL: $1" >&2; exit 1; }

expect_launch_order() {
  local file="$1"
  local order="$2"
  grep -q "LAUNCH ORDER ${order}" "$file" || fail "${file} missing LAUNCH ORDER ${order}"
}

expect_launch_order "commands_for_cursor/01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.1.md" "01"
expect_launch_order "commands_for_cursor/02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.1.md" "02"
expect_launch_order "commands_for_cursor/03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.2.md" "03"
expect_launch_order "commands_for_cursor/04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.1.md" "04"
expect_launch_order "commands_for_cursor/05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md" "05"
expect_launch_order "commands_for_cursor/06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.1.md" "06"

echo "PASS: commands_for_cursor integrity (01–06 launch order aligned)"
