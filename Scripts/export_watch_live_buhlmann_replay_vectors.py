#!/usr/bin/env python3
"""Export Audit-15 ML profile CSV scaffolding for external decompression comparison."""

from __future__ import annotations

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "Docs"

PROFILES = [
    ("ML-01", "Air 39m to 10m multilevel", "Docs/WATCH_AUDIT15_AIR39_PROFILE_CURRENT.csv"),
    ("ML-02", "Air bottom EAN50 @21m", "generated"),
    ("ML-03", "Trimix bottom + EAN50 deco", "generated"),
    ("ML-04", "Sawtooth multilevel", "generated"),
    ("ML-05", "Re-descent after shallow clear", "Docs/WATCH_AUDIT15_REDESCENT_PROFILE_CURRENT.csv"),
    ("ML-06", "Stop boundary hover", "generated"),
    ("ML-07", "Very slow ascent", "generated"),
    ("ML-08", "Rapid ascent", "generated"),
    ("ML-09", "Long 10m level", "generated"),
    ("ML-10", "Surface interval + second segment", "generated"),
]

HEADER = [
    "profile_id", "second", "depth_m", "gas_o2", "gas_he", "gas_n2", "gf_low", "gf_high",
    "ambient_pressure_bar", "inspired_n2_bar", "inspired_he_bar",
    *[f"tissue_n2_{i:02d}" for i in range(1, 17)],
    *[f"tissue_he_{i:02d}" for i in range(1, 17)],
    "ceiling_m", "controlling_compartment", "ndl_s", "tts_s", "first_stop_m",
    "stop_schedule_json", "degraded_state", "event",
]


def write_scaffold(path: Path, profile_id: str, note: str) -> None:
    with path.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(HEADER)
        w.writerow([profile_id, 0, "0", "0.21", "0", "0.79", 30, 70,
                    "1.01325", "", "", *([""] * 32), "", "", "", "", "", "", note,
                    "PENDING_EXTERNAL_VALIDATION"])


def main() -> None:
    out_dir = DOCS / "WATCH_LIVE_BUHLMANN_REPLAY_EXPORTS"
    out_dir.mkdir(exist_ok=True)
    for profile_id, title, source in PROFILES:
        out = out_dir / f"{profile_id}_REPLAY_SCAFFOLD_CURRENT.csv"
        write_scaffold(out, profile_id, f"{title}; source={source}; fill via Watch oracle replay export")
    index = DOCS / "WATCH_LIVE_BUHLMANN_REPLAY_EXPORT_INDEX_CURRENT.csv"
    with index.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["Profile_ID", "Title", "Export_Path", "Status"])
        for profile_id, title, _ in PROFILES:
            w.writerow([profile_id, title, f"Docs/WATCH_LIVE_BUHLMANN_REPLAY_EXPORTS/{profile_id}_REPLAY_SCAFFOLD_CURRENT.csv", "SCAFFOLD_PENDING_EXTERNAL"])
    print(f"Wrote {len(PROFILES)} replay scaffolds under {out_dir}")


if __name__ == "__main__":
    main()
