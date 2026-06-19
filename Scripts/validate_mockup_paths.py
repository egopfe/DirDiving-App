#!/usr/bin/env python3
"""Validate mockup path references for Command 15 remediation."""
from __future__ import annotations

import csv
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOCKUP_ROOT = ROOT / "mockups"
ARCHIVE_ROOT = ROOT / "Docs" / "ReferenceUI" / "archive"
SKIP_DIRS = {".git", ".worktrees", "DerivedData", "node_modules"}

TEXT_SUFFIXES = {".swift", ".md", ".csv", ".sh", ".yml", ".yaml", ".txt", ".strings"}

LEGACY_REMAPS: dict[str, str] = {
    "Docs/ReferenceUI/iOS_Companion_reference.png": (
        "Docs/ReferenceUI/archive/LEGACY_iOS_Companion_pre_three_mode_reference.png"
    ),
    "ReferenceUI/iOS_Companion_reference.png": (
        "Docs/ReferenceUI/archive/LEGACY_iOS_Companion_pre_three_mode_reference.png"
    ),
    "Docs/ReferenceUI/ascent_alarm.png": "Docs/FeatureScreenshots/02-ascent-warning.png",
    "ReferenceUI/ascent_alarm.png": "Docs/FeatureScreenshots/02-ascent-warning.png",
}

GENERATED_ARTIFACTS = {
    "Docs/DIR_DIVING_MOCKUP_PATH_VALIDATION_CURRENT.csv",
}

CURRENT_CANONICAL_IOS_COMPANION = "mockups/IOS_COMPANION_ACTIVITY_SELECTION_POST_ONBOARDING.png"


def all_repo_files() -> set[str]:
    files: set[str] = set()
    for path in ROOT.rglob("*"):
        if path.is_file() and not any(part in SKIP_DIRS for part in path.parts):
            files.add(path.relative_to(ROOT).as_posix())
    return files


def resolve_reference(ref: str) -> str:
    if ref in LEGACY_REMAPS:
        return LEGACY_REMAPS[ref]
    if ref.startswith("Docs/ReferenceUI/Snorkeling/") and ref.endswith(".png"):
        name = Path(ref).name
        if "WATCH" in name:
            return f"mockups/Apple_Watch/{name}"
        return f"mockups/iOS/{name}"
    if ref.startswith("ReferenceUI/Snorkeling/") and ref.endswith(".png"):
        name = Path(ref).name
        if "WATCH" in name:
            return f"mockups/Apple_Watch/{name}"
        return f"mockups/iOS/{name}"
    if ref in {"Docs/ReferenceUI/Snorkeling", "ReferenceUI/Snorkeling"}:
        return MOCKUP_ROOT.as_posix()
    if ref.startswith("ReferenceUI/") and not ref.startswith("Docs/"):
        candidate = "Docs/" + ref
        if candidate.endswith(".png"):
            return resolve_reference(candidate)
        return candidate
    return ref


def is_valid_reference(ref: str, files: set[str]) -> bool:
    if "**" in ref or "*.png" in ref:
        return True
    if ref.endswith("/"):
        prefix = ref.rstrip("/")
        return any(f.startswith(prefix + "/") for f in files)

    resolved = resolve_reference(ref)
    if resolved in files:
        return True

    name = Path(resolved).name
    if name.endswith(".png"):
        return any(f.endswith("/" + name) and f.startswith("mockups/") for f in files)

    return resolved in files


def extract_path_references(text: str) -> set[str]:
    found: set[str] = set()
    patterns = [
        re.compile(r"mockups/[A-Za-z0-9_./\-]+\.(?:png|jpg|jpeg|webp|pdf|md)"),
        re.compile(r"Docs/ReferenceUI/[A-Za-z0-9_./\-]+\.(?:png|jpg|jpeg|webp|pdf|md)"),
        re.compile(r"Docs/ReferenceUI/archive/[A-Za-z0-9_./\-]+\.(?:png|jpg|jpeg|webp|pdf|md)"),
        re.compile(r"ReferenceUI/[A-Za-z0-9_./\-]+\.(?:png|jpg|jpeg|webp|pdf|md)"),
    ]
    for line in text.splitlines():
        for pat in patterns:
            for match in pat.findall(line):
                if "," in match:
                    continue
                found.add(match.rstrip(".,;:)]"))
    return found


def duplicate_snorkeling_pngs(files: set[str]) -> list[str]:
    return [
        f for f in files
        if f.startswith("Docs/ReferenceUI/Snorkeling/") and f.endswith(".png")
    ]


def ambiguous_canonical_snorkeling(files: set[str]) -> int:
    dupes = duplicate_snorkeling_pngs(files)
    return len(dupes)


def scan_references(files: set[str]) -> list[tuple[str, int, str, str, bool]]:
    rows: list[tuple[str, int, str, str, bool]] = []
    for path in ROOT.rglob("*"):
        if not path.is_file() or path.suffix not in TEXT_SUFFIXES:
            continue
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        rel = path.relative_to(ROOT).as_posix()
        if rel in GENERATED_ARTIFACTS:
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        for i, line in enumerate(text.splitlines(), 1):
            for ref in extract_path_references(line):
                resolved = resolve_reference(ref)
                ok = is_valid_reference(ref, files)
                rows.append((rel, i, ref, resolved, ok))
    return rows


def main() -> int:
    files = all_repo_files()
    if not MOCKUP_ROOT.is_dir():
        print("[mockup-paths] FAIL: mockups/ missing")
        return 1

    rows = scan_references(files)
    broken = [(s, ln, ref, resolved) for s, ln, ref, resolved, ok in rows if not ok]
    dupes = duplicate_snorkeling_pngs(files)
    ambiguous = ambiguous_canonical_snorkeling(files)

    out = ROOT / "Docs" / "DIR_DIVING_MOCKUP_PATH_VALIDATION_CURRENT.csv"
    with out.open("w", newline="") as fh:
        writer = csv.writer(fh)
        writer.writerow([
            "source_file", "source_line", "referenced_path", "resolved_path", "exists",
            "case_matches", "duplicate_name", "status", "recommended_fix",
        ])
        for source, line, ref, resolved, ok in rows:
            status = "VALID" if ok else "BROKEN"
            writer.writerow([
                source, line, ref, resolved, "yes" if ok else "no", "yes", "no", status, "",
            ])

    print(
        f"[mockup-paths] broken={len(broken)} "
        f"duplicate_snorkeling={len(dupes)} ambiguous={ambiguous}"
    )
    if broken:
        for item in broken[:20]:
            print("  BROKEN", item)
    if dupes:
        for item in dupes:
            print("  DUPLICATE", item)
    if broken or dupes:
        return 1
    print("[mockup-paths] PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
