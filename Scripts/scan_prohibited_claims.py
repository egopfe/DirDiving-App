#!/usr/bin/env python3
"""Scan production and current-governance surfaces for unsupported product claims."""

from __future__ import annotations

import csv
import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

PRODUCTION_SUFFIXES = {".swift", ".strings", ".txt", ".xcprivacy", ".md"}
PRODUCTION_DIRS = [
    "App",
    "Views",
    "Models",
    "Services",
    "Utils",
    "Shared",
    "iOSApp",
    "Resources",
    "Config",
]

CURRENT_GOV_DOCS = [
    "Docs/SAFETY_DISCLAIMER.md",
    "Docs/TERMS_OF_USE.md",
    "Docs/iOS/SAFETY_DISCLAIMER.md",
    "Docs/TESTFLIGHT_REVIEW_NOTES.md",
    "Docs/CLAIMS_POLICY_REGISTRY_CURRENT.md",
    "Docs/EXPORT_DISCLAIMER_POLICY_CURRENT.md",
    "Docs/RELEASE_CLAIMS_GATE_POLICY_CURRENT.md",
    "Docs/IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md",
    "Docs/README.md",
    "README.md",
]

SKIP_DIR_PARTS = {
    "Tests",
    "node_modules",
    ".git",
    "agent-transcripts",
    "commands_for_cursor",
    "mockups",
    ".worktrees",
}

SKIP_FILE_PARTS = {
    "PROHIBITED_CLAIMS_ALLOWLIST_CURRENT.csv",
    "RELEASE_LEGAL_FINDING_TRACEABILITY_CURRENT.csv",
    "RELEASE_LEGAL_CLAIMS_COMPLIANCE_REMEDIATION_REPORT_CURRENT.md",
}

PROHIBITED_PATTERNS = [
    (re.compile(r"certified dive computer", re.I), "certified dive computer"),
    (re.compile(r"certified decompression", re.I), "certified decompression"),
    (re.compile(r"guaranteed safe", re.I), "guaranteed safe"),
    (re.compile(r"guarantees safety", re.I), "guarantees safety"),
    (re.compile(r"guarantee.{0,20}safety", re.I), "guarantee safety"),
    (re.compile(r"medical device", re.I), "medical device"),
    (re.compile(r"medical advice", re.I), "medical advice"),
    (re.compile(r"guaranteed recovery", re.I), "guaranteed recovery"),
    (re.compile(r"rescue navigation", re.I), "rescue navigation"),
    (re.compile(r"guaranteed return", re.I), "guaranteed return"),
    (re.compile(r"en\s*13319\s*compliant", re.I), "EN13319 compliant"),
    (re.compile(r"iso\s*6425\s*compliant", re.I), "ISO 6425 compliant"),
    (re.compile(r"approved decompression algorithm", re.I), "approved decompression algorithm"),
    (re.compile(r"clinically validated", re.I), "clinically validated"),
    (re.compile(r"official dive computer", re.I), "official dive computer"),
    (re.compile(r"life-support verification", re.I), "life-support verification"),
    (re.compile(r"computer subacqueo certificato", re.I), "computer subacqueo certificato (IT)"),
    (re.compile(r"planner decompressivo certificato", re.I), "planner decompressivo certificato (IT)"),
    (re.compile(r"navigazione di soccorso", re.I), "navigazione di soccorso (IT)"),
]

NEGATION_MARKERS = [
    "not a certified",
    "not certified",
    "non-certified",
    "non certified",
    "non certificato",
    "not a dive computer",
    "not a medical",
    "not medical",
    "does not guarantee",
    "do not guarantee",
    "not guarantee",
    "not guaranteed",
    "must not",
    "must not appear",
    "prohibited",
    "deny certification",
    "no certified",
    "without certification",
    "non è un computer",
    "non e un computer",
    "non sostituisce",
    "non garantisce",
    "reference-only",
    "reference only",
    "solo riferimento",
    "informativ",
    "heuristic",
    "pending",
    "out of scope",
    "out-of-scope",
    "not life-support",
    "not lifesupport",
]


def strip_markdown_for_negation(line: str) -> str:
    """Remove common markdown emphasis so negation markers match across bold/italic."""
    return re.sub(r"\*+([^*]+)\*+", r"\1", line)


@dataclass
class Violation:
    path: str
    line: int
    pattern: str
    excerpt: str


def load_allowlist() -> set[tuple[str, int, str]]:
    allow_path = ROOT / "Docs/PROHIBITED_CLAIMS_ALLOWLIST_CURRENT.csv"
    allowed: set[tuple[str, int, str]] = set()
    if not allow_path.exists():
        return allowed
    with allow_path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            rel = row.get("File", "").strip()
            line_s = row.get("Line", "").strip()
            pattern = row.get("Pattern", "").strip()
            if rel and line_s.isdigit() and pattern:
                allowed.add((rel, int(line_s), pattern.lower()))
    return allowed


def is_negated(line: str) -> bool:
    lower = strip_markdown_for_negation(line).lower()
    if any(marker in lower for marker in NEGATION_MARKERS):
        return True
    if re.search(r"\bnon\b.{0,80}certificat", lower):
        return True
    if re.search(r"\bnot\b.{0,80}certif", lower):
        return True
    if re.search(r"must not be used", lower):
        return True
    if re.search(r"use certified", lower):
        return True
    if re.search(r"follow certified", lower):
        return True
    if re.search(r"do not provide", lower):
        return True
    return False


def is_forbidden_term_definition(line: str) -> bool:
    stripped = line.strip()
    if re.match(r'^"[^"]+",?\s*$', stripped):
        return True
    if "forbidden =" in line or "forbiddenPhrases" in line or "verifyNoForbidden" in line:
        return True
    return False


def should_skip_path(path: Path) -> bool:
    rel = path.as_posix()
    parts = set(Path(rel).parts)
    if parts & SKIP_DIR_PARTS:
        return True
    if path.name in SKIP_FILE_PARTS:
        return True
    if "Tests" in path.parts:
        return True
    if path.suffix not in PRODUCTION_SUFFIXES and path.name not in {"README.md"}:
        return False
    return False


def iter_production_files() -> list[Path]:
    files: list[Path] = []
    for directory in PRODUCTION_DIRS:
        root = ROOT / directory
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if not path.is_file():
                continue
            if should_skip_path(path.relative_to(ROOT)):
                continue
            if path.suffix in PRODUCTION_SUFFIXES or path.name.endswith("LegalDisclaimer.txt"):
                files.append(path)
    for rel in CURRENT_GOV_DOCS:
        path = ROOT / rel
        if path.is_file():
            files.append(path)
    return sorted(set(files))


def scan_file(path: Path, allowlist: set[tuple[str, int, str]]) -> list[Violation]:
    rel = path.relative_to(ROOT).as_posix()
    violations: list[Violation] = []
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return violations
    in_must_not_section = False
    for index, line in enumerate(text.splitlines(), start=1):
        if line.startswith("#"):
            if re.search(r"non sostituisce|must not be used", line, re.I):
                in_must_not_section = True
            else:
                in_must_not_section = False
        if re.search(
            r"must not be used as|non deve essere usata come|non sostituisce",
            line,
            re.I,
        ):
            in_must_not_section = True
        if in_must_not_section and line.strip().startswith("-"):
            continue
        if is_negated(line) or is_forbidden_term_definition(line):
            continue
        for regex, label in PROHIBITED_PATTERNS:
            if not regex.search(line):
                continue
            if (rel, index, label.lower()) in allowlist:
                continue
            violations.append(
                Violation(
                    path=rel,
                    line=index,
                    pattern=label,
                    excerpt=line.strip()[:240],
                )
            )
    return violations


def main() -> int:
    allowlist = load_allowlist()
    all_violations: list[Violation] = []
    for path in iter_production_files():
        all_violations.extend(scan_file(path, allowlist))

    if all_violations:
        print("PROHIBITED_CLAIMS_SCAN_FAIL", file=sys.stderr)
        for item in all_violations:
            print(f"{item.path}:{item.line}: {item.pattern}: {item.excerpt}", file=sys.stderr)
        return 1

    print("PROHIBITED_CLAIMS_SCAN_PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
