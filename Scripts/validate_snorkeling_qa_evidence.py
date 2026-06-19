#!/usr/bin/env python3
"""Validate Snorkeling physical QA evidence folders and README metadata."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE_ROOT = ROOT / "Docs" / "QA_EVIDENCE"

CATALOG_ENTRIES = [
    ("SNK-QA-001", "SNORKELING_IOS_WATCH_SYNC"),
    ("SNK-QA-002", "SNORKELING_ROUTE_PUSH"),
    ("SNK-QA-003", "SNORKELING_SESSION_PULL"),
    ("SNK-QA-004", "SNORKELING_WATER_LOCK"),
    ("SNK-QA-005", "SNORKELING_WATCH_UI"),
    ("SNK-QA-006", "SNORKELING_IOS_MAPS"),
    ("SNK-QA-007", "SNORKELING_SAFETY_REVIEW"),
    ("SNK-QA-008", "SNORKELING_VOICEOVER"),
    ("SNK-QA-009", "SNORKELING_BATTERY_THERMAL"),
    ("SNK-QA-010", "SNORKELING_GPS"),
    ("SNK-QA-011", "SNORKELING_RECOVERY"),
    ("SNK-QA-012", "SNORKELING_RELAUNCH"),
    ("SNK-QA-013", "SNORKELING_OFFLINE_ONLINE"),
    ("SNK-QA-014", "SNORKELING_AIRPLANE_MODE"),
    ("SNK-QA-015", "SNORKELING_PHOTO_PRIVACY"),
    ("SNK-QA-016", "SNORKELING_EXPORT"),
    ("SNK-QA-017", "SNORKELING_WATCH_LAYOUTS"),
    ("SNK-QA-018", "SNORKELING_PAIR_UNPAIR"),
    ("SNK-QA-019", "SNORKELING_HAPTICS"),
    ("SNK-QA-020", "SNORKELING_WET_GLOVE"),
    ("SNK-QA-021", "SNORKELING_KEYCHAIN"),
]

REQUIRED_FIELDS = [
    "QA ID",
    "Status",
    "Branch",
    "Commit",
    "Tester",
    "Reviewer",
    "Execution date",
    "iPhone model",
    "iOS version",
    "Watch model",
    "watchOS version",
    "App build",
    "Test environment",
    "Preconditions",
    "Test steps",
    "Expected results",
    "Observed results",
    "Evidence artifacts",
    "Tester signature",
    "Reviewer signature",
]

PASS_REQUIRED_VALUES = [
    "Tester",
    "Reviewer",
    "Execution date",
    "iPhone model",
    "iOS version",
    "Watch model",
    "watchOS version",
    "App build",
    "Evidence artifacts",
]


def parse_status(text: str) -> str | None:
    match = re.search(r"\|\s*\*\*Status\*\*\s*\|\s*\*\*(PENDING|PASS|FAIL)\*\*", text, re.I)
    if match:
        return match.group(1).upper()
    match = re.search(r"status:\s*(PENDING|PASS|FAIL)", text, re.I)
    if match:
        return match.group(1).upper()
    return None


def field_has_value(text: str, field: str) -> bool:
    pattern = rf"\|\s*\*\*{re.escape(field)}\*\*\s*\|\s*([^|\n]+)\|"
    match = re.search(pattern, text, re.I)
    if not match:
        return False
    value = match.group(1).strip()
    if not value:
        return False
    lowered = value.lower()
    if lowered in {"pending", "(record at execution)", "(none)", "(none — add", ""}:
        return False
    if value.startswith("(none"):
        return False
    return True


def validate_entry(qa_id: str, folder: str, mode: str) -> list[str]:
    issues: list[str] = []
    folder_path = EVIDENCE_ROOT / folder
    readme = folder_path / "README.md"

    if not folder_path.is_dir():
        issues.append(f"{qa_id}: missing folder {folder_path}")
        return issues
    if not readme.is_file():
        issues.append(f"{qa_id}: missing README.md")
        return issues

    text = readme.read_text(encoding="utf-8")
    if qa_id not in text:
        issues.append(f"{qa_id}: README missing immutable QA ID {qa_id}")

    for field in REQUIRED_FIELDS:
        if field.lower() not in text.lower():
            issues.append(f"{qa_id}: README missing field heading {field}")

    status = parse_status(text)
    if status is None:
        issues.append(f"{qa_id}: could not parse Status (expected PENDING, PASS, or FAIL)")
        return issues

    if mode == "internal":
        if status != "PENDING":
            issues.append(f"{qa_id}: internal mode expects PENDING, got {status}")
        return issues

    # release mode
    if status == "PENDING":
        issues.append(f"{qa_id}: release blocked — status PENDING")
        return issues

    if status == "FAIL":
        issues.append(f"{qa_id}: release blocked — status FAIL")
        return issues

    for field in PASS_REQUIRED_VALUES:
        if not field_has_value(text, field):
            issues.append(f"{qa_id}: PASS requires populated {field}")

    if "signature" in text.lower():
        if not re.search(r"\|\s*Tester\s*\|\s*[^|\s][^|]*\|", text):
            issues.append(f"{qa_id}: PASS requires tester signature row")
        if not re.search(r"\|\s*Reviewer\s*\|\s*[^|\s][^|]*\|", text, re.I):
            issues.append(f"{qa_id}: PASS requires reviewer signature row")

    artifact_section = re.search(r"## Evidence artifacts\s*(.*?)(?:\n## |\Z)", text, re.S | re.I)
    if artifact_section:
        body = artifact_section.group(1)
        if "(none)" in body.lower() and "evidence-" not in body.lower():
            issues.append(f"{qa_id}: PASS requires artifact path")

    return issues


def main() -> int:
    mode = "internal"
    for arg in sys.argv[1:]:
        if arg == "--internal":
            mode = "internal"
        elif arg == "--release":
            mode = "release"
        elif arg in {"-h", "--help"}:
            print("Usage: validate_snorkeling_qa_evidence.py [--internal|--release]")
            return 0
        else:
            print(f"unknown argument: {arg}", file=sys.stderr)
            return 2

    print(f"[snorkeling-qa-evidence] mode: {mode}")
    print(f"[snorkeling-qa-evidence] catalog entries: {len(CATALOG_ENTRIES)}")

    all_issues: list[str] = []
    seen_ids: set[str] = set()
    for qa_id, folder in CATALOG_ENTRIES:
        if qa_id in seen_ids:
            all_issues.append(f"duplicate QA ID in catalog: {qa_id}")
        seen_ids.add(qa_id)
        all_issues.extend(validate_entry(qa_id, folder, mode))

    extra = sorted(
        p.name
        for p in EVIDENCE_ROOT.glob("SNORKELING_*")
        if p.is_dir() and p.name not in {folder for _, folder in CATALOG_ENTRIES}
    )
    for name in extra:
        all_issues.append(f"unexpected evidence folder not in catalog: {name}")

    if all_issues:
        print("[snorkeling-qa-evidence] FAIL")
        for issue in all_issues:
            print(f"  - {issue}")
        return 1

    print("[snorkeling-qa-evidence] PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
