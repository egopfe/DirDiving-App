#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_YML="$ROOT_DIR/project.yml"

if [[ ! -f "$PROJECT_YML" ]]; then
  echo "[isolation] project.yml not found"
  exit 1
fi

required_exclusions=(
  "ApneaView.swift"
  "SnorkelingView.swift"
  "BuddyAssistView.swift"
  "ExperimentalConceptsView.swift"
  "ExperimentalFeatures.swift"
  "ExplorationModels.swift"
  "BuddyExperimentalModels.swift"
  "ExplorationPlanningStore.swift"
  "BuddyExperimentalStore.swift"
  "ExplorationCenterView.swift"
  "ExperimentalFutureConceptsView.swift"
  "BuddyExperimentalView.swift"
)

echo "[isolation] checking experimental exclusions in project.yml"
python3 - "$PROJECT_YML" "${required_exclusions[@]}" <<'PY'
import sys
from pathlib import Path

project = Path(sys.argv[1]).read_text(encoding="utf-8")
missing = [item for item in sys.argv[2:] if item not in project]
if missing:
    for item in missing:
        print(f"[isolation] missing exclusion: {item}")
    raise SystemExit(1)
PY

echo "[isolation] exclusions are present"
