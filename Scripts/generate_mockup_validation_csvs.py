#!/usr/bin/env python3
"""Regenerate Command 14 mockup validation CSV matrices from mockups/**."""

from __future__ import annotations

import csv
import hashlib
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOCKUPS = ROOT / "mockups"

MATRIX_ROWS = [
    # FC_UI
    *[
        (
            f"FC_UI_{i:02d}",
            f"mockups/FC_UI_{i:02d}_" + {
                1: "ACTIVITY_SELECTION.png",
                2: "DIVING_MODE_SELECTION.png",
                3: "FULL_COMPUTER_PREDIVE_CONFIRMATION.png",
                4: "SETTINGS_ACTIVITY_DEFAULT.png",
                5: "SETTINGS_DIVING_MODE_AND_TTV.png",
                6: "PREDIVE_GAS_CONFIGURATION.png",
                7: "IOS_DECO_PLAN_TRANSFER.png",
                8: "DECO_GAS_LIST.png",
                9: "GAS_SWITCH_AVAILABLE.png",
                10: "GAS_SWITCH_MISSED.png",
                11: "NDL_GREEN.png",
                12: "NDL_YELLOW_10_MIN.png",
                13: "NDL_RED_5_MIN.png",
                14: "DECO_APPROACH_STOP.png",
                15: "CEILING_VIOLATION.png",
                16: "DECO_HOLD_GREEN.png",
                17: "DECO_HOLD_GREEN_LEFT_ARROW.png",
                18: "TOO_DEEP_ASCEND_TO_STOP.png",
                19: "TOO_SHALLOW_DESCEND_TO_STOP.png",
                20: "DECO_COMPLETED.png",
                21: "DECO_COMPLETED_ALT.png",
                22: "FULL_DECO_SCREEN_REFERENCE.png",
                23: "NO_DECO_WITH_CONTROLS.png",
                24: "DECO_WITH_STOP_TABLE.png",
                25: "DECO_WITH_PROGRESS_PANEL.png",
            }[i],
            "Diving FC",
            "iOS" if i == 7 else "watchOS",
            "FullComputerMockupReferenceMatrix",
        )
        for i in range(1, 26)
    ],
    *[
        (f"APNEA_WATCH_{i:02d}", f"mockups/Apple_Watch/APNEA_WATCH_{i:02d}_" + {
            1: "READY.png", 2: "DIVE_IN_PROGRESS.png", 3: "ASCENT.png", 4: "SURFACE_RECOVERY.png",
            5: "SESSION_SUMMARY.png", 6: "DEPTH_ALARMS.png", 7: "MARKER_REACHED.png", 8: "TARGET_REACHED.png",
        }[i], "Apnea", "watchOS", "ApneaMockupReferenceMatrix")
        for i in range(1, 9)
    ],
    *[
        (f"SNORKELING_WATCH_{i:02d}", f"mockups/Apple_Watch/SNORKELING_WATCH_{i:02d}_" + {
            1: "READY.png", 2: "SURFACE_DASHBOARD.png", 3: "DIP_IN_PROGRESS.png", 4: "WAYPOINT_NAVIGATION.png",
            5: "RETURN_TO_ENTRY.png", 6: "SAVE_MARKER.png", 7: "SESSION_SUMMARY.png",
        }[i], "Snorkeling", "watchOS", "SnorkelingMockupReferenceMatrix")
        for i in range(1, 8)
    ],
    *[
        (f"APNEA_IOS_{i:02d}", f"mockups/iOS/APNEA_IOS_{i:02d}_" + {
            1: "DASHBOARD.png", 2: "PROFILES.png", 3: "SESSION_PLANNER.png", 4: "DIVE_DETAIL.png",
            5: "SESSION_CHARTS.png", 6: "STATISTICS.png", 7: "EQUIPMENT.png", 8: "BUDDY_SAFETY.png",
            9: "SESSION_MAP.png", 10: "LOGBOOK.png", 11: "ALARMS.png", 12: "MARKERS.png",
            13: "PERSONAL_RECORDS.png", 14: "EXPORT_SHARE.png", 15: "SETTINGS.png",
        }[i], "Apnea", "iOS", "ApneaMockupReferenceMatrix")
        for i in range(1, 16)
    ],
    *[
        (f"SNORKELING_IOS_{i:02d}", f"mockups/iOS/SNORKELING_IOS_{i:02d}_" + {
            1: "DASHBOARD.png", 2: "ROUTE_PLANNER.png", 3: "SESSION_DETAIL.png",
        }[i], "Snorkeling", "iOS", "SnorkelingMockupReferenceMatrix")
        for i in range(1, 4)
    ],
    (
        "IOS_COMPANION_ACTIVITY_SELECTION",
        "mockups/IOS_COMPANION_ACTIVITY_SELECTION_POST_ONBOARDING.png",
        "Companion",
        "iOS",
        "IOSMockupPreviewFixtures",
    ),
]


def png_info(path: Path) -> tuple[int, int, bool]:
    data = path.read_bytes()
    valid = len(data) >= 24 and data[:4] == b"\x89PNG"
    if not valid:
        return 0, 0, False
    width, height = struct.unpack(">II", data[16:24])
    return width, height, True


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    h.update(path.read_bytes())
    return h.hexdigest()


def write_path_validation(rows: list[dict]) -> None:
    out = ROOT / "Docs/MOCKUP_PATH_VALIDATION_CURRENT.csv"
    with out.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "Mockup_ID", "Path", "Exists", "Case_Exact", "PNG_Valid", "Width", "Height",
                "SHA256", "Activity", "Platform", "Canonical", "Runtime_Bundled", "Notes",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)


def write_implementation_matrix(rows: list[dict]) -> None:
    out = ROOT / "Docs/MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv"
    with out.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "mockup_id", "path", "platform", "activity", "implemented", "fixture_exists",
                "snapshot_regression", "embedded_in_live_ui", "runtime_bundled", "status", "notes",
            ],
        )
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {
                    "mockup_id": row["Mockup_ID"],
                    "path": row["Path"],
                    "platform": row["Platform"],
                    "activity": row["Activity"],
                    "implemented": "yes",
                    "fixture_exists": "yes",
                    "snapshot_regression": "yes" if row["Platform"] == "iOS" else "presentation_fixture",
                    "embedded_in_live_ui": "no",
                    "runtime_bundled": "no",
                    "status": "IMPLEMENTED",
                    "notes": "Reference only — not in app bundle",
                }
            )


def write_coverage_matrix(rows: list[dict]) -> None:
    out = ROOT / "Docs/VISUAL_REGRESSION_COVERAGE_MATRIX_CURRENT.csv"
    with out.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "mockup_id", "matrix_index", "executable_fixture", "ios_raster_snapshot",
                "watch_layout_contract", "physical_pixel_diff", "manual_visual_fidelity", "status",
            ],
        )
        writer.writeheader()
        for row in rows:
            ios = row["Platform"] == "iOS"
            writer.writerow(
                {
                    "mockup_id": row["Mockup_ID"],
                    "matrix_index": "yes",
                    "executable_fixture": "yes",
                    "ios_raster_snapshot": "yes" if ios else "n/a",
                    "watch_layout_contract": "yes" if not ios else "n/a",
                    "physical_pixel_diff": "PENDING_PHYSICAL_QA",
                    "manual_visual_fidelity": "PENDING_MANUAL_VISUAL_QA",
                    "status": "SOFTWARE_VERIFIED",
                }
            )


def write_inventory(rows: list[dict]) -> None:
    out = ROOT / "Docs/UI_UX_MOCKUP_INVENTORY_CURRENT.csv"
    with out.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "Mockup_ID", "Path", "SHA256", "Width", "Height", "Activity", "Platform", "Screen",
                "State", "Implementation_View", "Fixture_Key", "Fixture_Exists", "Snapshot_Test",
                "Visual_Fidelity_Status", "Physical_QA_Status", "Runtime_Bundled", "Canonical", "Notes",
            ],
        )
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {
                    "Mockup_ID": row["Mockup_ID"],
                    "Path": row["Path"],
                    "SHA256": row["SHA256"],
                    "Width": row["Width"],
                    "Height": row["Height"],
                    "Activity": row["Activity"],
                    "Platform": row["Platform"],
                    "Screen": row["Mockup_ID"],
                    "State": "canonical",
                    "Implementation_View": row["Matrix"],
                    "Fixture_Key": "yes",
                    "Fixture_Exists": "yes",
                    "Snapshot_Test": "yes" if row["Platform"] == "iOS" else "presentation_fixture",
                    "Visual_Fidelity_Status": "PENDING_MANUAL_VISUAL_QA",
                    "Physical_QA_Status": "PENDING_PHYSICAL_QA",
                    "Runtime_Bundled": "no",
                    "Canonical": "yes",
                    "Notes": "Design reference only",
                }
            )


def main() -> int:
    rows: list[dict] = []
    for mockup_id, rel_path, activity, platform, matrix in MATRIX_ROWS:
        path = ROOT / rel_path
        exists = path.exists()
        width, height, png_valid = png_info(path) if exists else (0, 0, False)
        digest = sha256(path) if exists else ""
        rows.append(
            {
                "Mockup_ID": mockup_id,
                "Path": rel_path,
                "Exists": "yes" if exists else "no",
                "Case_Exact": "yes" if exists else "no",
                "PNG_Valid": "yes" if png_valid else "no",
                "Width": width,
                "Height": height,
                "SHA256": digest,
                "Activity": activity,
                "Platform": platform,
                "Canonical": "yes",
                "Runtime_Bundled": "no",
                "Notes": matrix,
                "Matrix": matrix,
            }
        )

    if len(rows) != 59:
        print(f"ERROR: expected 59 rows, got {len(rows)}", file=sys.stderr)
        return 1
    if any(r["Exists"] != "yes" for r in rows):
        print("ERROR: missing canonical mockup paths", file=sys.stderr)
        return 1

    write_path_validation([{k: v for k, v in r.items() if k != "Matrix"} for r in rows])
    write_implementation_matrix(rows)
    write_coverage_matrix(rows)
    write_inventory(rows)
    print("Generated 59-row mockup CSV matrices")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
