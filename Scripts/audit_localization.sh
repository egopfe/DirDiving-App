#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUTPUT_JSON="${TMPDIR:-/tmp}/dirdiving_localization_audit.json"
REPORT_MD="Docs/DIR_DIVING_LOCALIZATION_AUDIT_CURRENT.md"
INVENTORY_CSV="Docs/DIR_DIVING_LOCALIZATION_KEY_INVENTORY_CURRENT.csv"

echo "[l10n-audit] start repository-wide localization audit"

python3 - "$OUTPUT_JSON" "$INVENTORY_CSV" <<'PY'
import csv
import json
import re
import sys
from pathlib import Path

ROOT = Path('.')
OUT_JSON = Path(sys.argv[1])
OUT_CSV = Path(sys.argv[2])

PLACEHOLDER_VALUES = {"TODO", "TBD", "Mock", "Lorem", "FIXME"}
SEMANTIC_PREFIXES = (
    "startup.", "settings.", "gauge.", "fc.", "live.", "fullComputer.", "deco.", "gas.",
    "sync.", "recovery.", "log.", "watch.", "alarms.", "compass.", "briefing.", "legal.",
    "planner.", "checklist.", "export.", "pdf.", "a11y.", "accessibility.", "error.",
    "info.", "image.", "dive.", "watchsync.", "user_images.", "mode.", "navigation.",
    "snorkeling.", "apnea.", "global.", "common.", "mission.", "ascent.", "depth.",
)

WATCH_EXCLUDED = {
    "Views/ApneaView.swift",
    "Views/SnorkelingView.swift",
    "Views/BuddyAssistView.swift",
    "Views/ExperimentalConceptsView.swift",
}
IOS_EXCLUDED = {
    "iOSApp/Views/BuddyExperimentalView.swift",
    "iOSApp/Views/ExperimentalFutureConceptsView.swift",
    "iOSApp/Views/ExplorationCenterView.swift",
}

HARDCODED_EXEMPT_SUBSTRINGS = {
    "DIR DIVING", "CROWN", "°", "BUSSOLA", "NE", "042°", "2:1", "WPT 02",
}

KEY_PATTERNS = [
    re.compile(r'String\(localized:\s*(?:String\.LocalizationValue\()?\"([^\"\\]+)\"'),
    re.compile(r'DIRIOSLocalizer\.string\(\"([^\"\\]+)\"\)'),
    re.compile(r'Text\(\"([^\"\\]+)\",\s*bundle:'),
]


def parse_strings(path: Path) -> dict[str, str]:
    raw = path.read_text(encoding='utf-8')
    result: dict[str, str] = {}
    for match in re.finditer(r'"((?:\\.|[^"\\])*)"\s*=\s*"((?:\\.|[^"\\])*)"\s*;', raw):
        key = bytes(match.group(1), 'utf-8').decode('unicode_escape')
        value = bytes(match.group(2), 'utf-8').decode('unicode_escape')
        result[key] = value
    return result


def is_semantic_key(key: str) -> bool:
    return '.' in key and key[0].islower() and any(key.startswith(p) for p in SEMANTIC_PREFIXES)


def scan_swift_keys(roots: list[str], excluded: set[str]) -> dict[str, set[str]]:
    used: dict[str, set[str]] = {}
    for root in roots:
        base = ROOT / root
        if not base.exists():
            continue
        for path in base.rglob('*.swift'):
            rel = str(path.relative_to(ROOT))
            if rel in excluded or any(rel.endswith(x) for x in excluded):
                continue
            src = path.read_text(encoding='utf-8', errors='replace')
            for pattern in KEY_PATTERNS:
                for match in pattern.finditer(src):
                    key = match.group(1)
                    if is_semantic_key(key):
                        used.setdefault(key, set()).add(rel)
            for match in re.finditer(r'"(live\.fc\.[^"]+)"', src):
                key = match.group(1)
                used.setdefault(key, set()).add(rel)
    return used


def scan_hardcoded(roots: list[str], excluded: set[str]) -> list[dict]:
    findings = []
    text_pattern = re.compile(r'Text\("([^"]{4,})"\)')
    for root in roots:
        base = ROOT / root
        if not base.exists():
            continue
        for path in base.rglob('*.swift'):
            rel = str(path.relative_to(ROOT))
            if rel in excluded:
                continue
            src = path.read_text(encoding='utf-8', errors='replace')
            for match in text_pattern.finditer(src):
                text = match.group(1)
                if '\\(' in text:
                    continue
                if is_semantic_key(text):
                    continue
                if any(ex in text for ex in HARDCODED_EXEMPT_SUBSTRINGS):
                    continue
                if re.fullmatch(r'[\d\s°./:-]+', text):
                    continue
                if text.isascii() and (text.isupper() or ' ' in text) and re.search(r'[A-Za-z]{4,}', text):
                    findings.append({"file": rel, "text": text})
    return findings


def audit_catalog(name: str, en_path: str, it_path: str, code_roots: list[str], excluded: set[str]):
    en = parse_strings(ROOT / en_path)
    it = parse_strings(ROOT / it_path)
    used = scan_swift_keys(code_roots, excluded)

    missing_it = sorted(set(en) - set(it))
    missing_en = sorted(set(it) - set(en))
    missing_translation_en = []
    missing_translation_it = []
    placeholders = []
    for key in sorted(set(en) & set(it)):
        for locale, catalog in (("en", en), ("it", it)):
            value = catalog[key].strip()
            if is_semantic_key(key):
                if not value:
                    (missing_translation_en if locale == "en" else missing_translation_it).append(key)
                elif value in PLACEHOLDER_VALUES or value == key:
                    placeholders.append({"key": key, "locale": locale, "value": value})
    code_missing_en = sorted(k for k in used if k not in en)
    code_missing_it = sorted(k for k in used if k not in it)

    return {
        "name": name,
        "en_count": len(en),
        "it_count": len(it),
        "missing_it": missing_it,
        "missing_en": missing_en,
        "code_missing_en": code_missing_en,
        "code_missing_it": code_missing_it,
        "placeholder_issues": placeholders,
        "used_semantic_keys": len(used),
        "en": en,
        "it": it,
        "used": used,
    }


watch = audit_catalog(
    "Watch",
    "Resources/en.lproj/Localizable.strings",
    "Resources/it.lproj/Localizable.strings",
    ["App", "Services", "Views", "Utils"],
    WATCH_EXCLUDED,
)
ios = audit_catalog(
    "iOS",
    "iOSApp/Resources/en.lproj/Localizable.strings",
    "iOSApp/Resources/it.lproj/Localizable.strings",
    ["iOSApp"],
    IOS_EXCLUDED,
)
hardcoded = scan_hardcoded(["App", "Services", "Views", "Utils"], WATCH_EXCLUDED)

blocking = []
for catalog in (watch, ios):
    if catalog["missing_it"]:
        blocking.append(f"{catalog['name']}: {len(catalog['missing_it'])} keys missing in IT")
    if catalog["missing_en"]:
        blocking.append(f"{catalog['name']}: {len(catalog['missing_en'])} keys missing in EN")
    if catalog["code_missing_en"]:
        blocking.append(f"{catalog['name']}: {len(catalog['code_missing_en'])} code keys missing in EN")
    if catalog["code_missing_it"]:
        blocking.append(f"{catalog['name']}: {len(catalog['code_missing_it'])} code keys missing in IT")
    bad_placeholders = [p for p in catalog["placeholder_issues"] if is_semantic_key(p["key"])]
    if bad_placeholders:
        blocking.append(f"{catalog['name']}: {len(bad_placeholders)} semantic placeholder translations")

result = {
    "watch": {k: v for k, v in watch.items() if k not in {"en", "it", "used"}},
    "ios": {k: v for k, v in ios.items() if k not in {"en", "it", "used"}},
    "hardcoded_watch_main": hardcoded,
    "blocking_failures": blocking,
    "pass": len(blocking) == 0 and len(hardcoded) == 0,
}
OUT_JSON.write_text(json.dumps(result, indent=2), encoding='utf-8')

# CSV inventory (semantic keys + fc/live/startup used keys)
rows = []
seen = set()
for catalog_name, catalog in ("watch", watch), ("ios", ios):
    for key in sorted(set(catalog["en"]) | set(catalog["it"])):
        if not (is_semantic_key(key) or key in catalog["used"]):
            continue
        if (catalog_name, key) in seen:
            continue
        seen.add((catalog_name, key))
        en_val = catalog["en"].get(key, "")
        it_val = catalog["it"].get(key, "")
        feature = key.split('.')[0]
        sources = ";".join(sorted(catalog["used"].get(key, [])))
        pluralized = "%" in en_val or "%" in it_val
        accessibility = key.startswith("a11y.") or ".a11y" in key
        status = "PASS"
        if key not in catalog["en"] or key not in catalog["it"]:
            status = "MISSING_LOCALE"
        elif not en_val or not it_val:
            status = "EMPTY"
        elif en_val in PLACEHOLDER_VALUES or it_val in PLACEHOLDER_VALUES:
            status = "PLACEHOLDER"
        rows.append({
            "key": key,
            "feature": feature,
            "target": catalog_name,
            "source_file": sources,
            "italian_value": it_val,
            "english_value": en_val,
            "placeholders": "yes" if pluralized else "no",
            "pluralized": "yes" if pluralized else "no",
            "accessibility": "yes" if accessibility else "no",
            "status": status,
            "notes": "",
        })

OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
with OUT_CSV.open('w', newline='', encoding='utf-8') as handle:
    writer = csv.DictWriter(
        handle,
        fieldnames=[
            "key", "feature", "target", "source_file", "italian_value", "english_value",
            "placeholders", "pluralized", "accessibility", "status", "notes",
        ],
    )
    writer.writeheader()
    writer.writerows(rows)

print(f"[l10n-audit] Watch EN={watch['en_count']} IT={watch['it_count']} semantic_used={watch['used_semantic_keys']}")
print(f"[l10n-audit] iOS EN={ios['en_count']} IT={ios['it_count']} semantic_used={ios['used_semantic_keys']}")
print(f"[l10n-audit] inventory rows={len(rows)} -> {OUT_CSV}")
print(f"[l10n-audit] hardcoded watch main findings={len(hardcoded)}")
if blocking:
    for item in blocking:
        print(f"[l10n-audit] BLOCK {item}")
if hardcoded:
    for item in hardcoded[:10]:
        print(f"[l10n-audit] BLOCK hardcoded: {item['file']} -> {item['text'][:60]}")
if not result["pass"]:
    sys.exit(1)
print("[l10n-audit] PASS")
PY

echo "[l10n-audit] report: $REPORT_MD"
echo "[l10n-audit] inventory: $INVENTORY_CSV"
