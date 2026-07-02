# Snorkeling Operational Settings Policy

- Operational thresholds are **Snorkeling-only** (`dirdiving.settings.snorkeling.v1`).
- Settings persist in `SnorkelingCompanionSettings` schema v2 with backward-compatible decode from v1.
- Thresholds sync to Watch through **route package metadata** (`SnorkelingRoutePlanningMetadata` optional fields).
- WatchConnectivity envelope is unchanged; only optional metadata fields are added.
- Engine alarms and return advisor consume thresholds via `SnorkelingOperationalThresholds` + `applyOperationalThresholds`.
