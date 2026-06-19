#!/usr/bin/env python3
"""Scaffold Snorkeling QA evidence README templates from SnorkelingQAEvidenceCatalog."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

ENTRIES = [
    ("SNK-QA-001", "SNORKELING_IOS_WATCH_SYNC", "SNORKELING_IOS_WATCH_SYNC", "End-to-end iPhone ↔ Watch Snorkeling sync", "Paired iPhone + Apple Watch", "Snorkeling profile on both devices; signed dev or TestFlight build", True),
    ("SNK-QA-002", "SNORKELING_ROUTE_PUSH", "SNORKELING_ROUTE_PUSH", "Route plan push from iOS to Watch", "Paired iPhone + Apple Watch", "Route drafted on iOS; Watch reachable", True),
    ("SNK-QA-003", "SNORKELING_SESSION_PULL", "SNORKELING_SESSION_PULL", "Completed Watch session import to iOS Logbook", "Paired iPhone + Apple Watch", "Completed Snorkeling session on Watch", True),
    ("SNK-QA-004", "SNORKELING_WATER_LOCK", "SNORKELING_WATER_LOCK", "Water Lock during Snorkeling session", "Physical Apple Watch", "Active or pre-session Snorkeling UI", True),
    ("SNK-QA-005", "SNORKELING_WATCH_UI", "SNORKELING_WATCH_UI", "Watch UI stages: ready, surface, dip, nav, return, marker, summary", "Physical Apple Watch", "Snorkeling session plan or manual session", False),
    ("SNK-QA-006", "SNORKELING_IOS_MAPS", "SNORKELING_IOS_MAPS", "iOS map preview, route overlay, gap handling", "Physical iPhone", "Imported session with GPS track or route plan", False),
    ("SNK-QA-007", "SNORKELING_SAFETY_REVIEW", "SNORKELING_SAFETY_REVIEW", "Safety copy, disclaimers, non-certified navigation truthfulness", "iPhone + Watch", "Release candidate build", True),
    ("SNK-QA-008", "SNORKELING_VOICEOVER", "SNORKELING_VOICEOVER", "VoiceOver on Watch and iOS Snorkeling surfaces", "Physical iPhone + Watch", "VoiceOver enabled; EN and IT spot checks", False),
    ("SNK-QA-009", "SNORKELING_BATTERY_THERMAL", "SNORKELING_BATTERY,SNORKELING_THERMAL", "Battery drain and thermal behavior during surface sessions", "Physical Apple Watch (Ultra + smallest supported)", "30–60 min surface session script", False),
    ("SNK-QA-010", "SNORKELING_GPS", "SNORKELING_GPS_ACCURACY", "GPS accuracy, degraded/unavailable presentation", "Physical iPhone + Watch", "Outdoor or recorded GPS fixture", False),
    ("SNK-QA-011", "SNORKELING_RECOVERY", "SNORKELING_RECOVERY_RELAUNCH", "Session recovery after crash or force-quit", "Physical Apple Watch", "Active Snorkeling checkpoint on disk", True),
    ("SNK-QA-012", "SNORKELING_RELAUNCH", "SNORKELING_RECOVERY_RELAUNCH", "App relaunch during/after Snorkeling session", "Physical Apple Watch", "Session in progress or recently ended", True),
    ("SNK-QA-013", "SNORKELING_OFFLINE_ONLINE", "SNORKELING_OFFLINE", "Offline route/session behavior and reconnect sync", "Paired iPhone + Watch", "Airplane mode or unreachable peer", True),
    ("SNK-QA-014", "SNORKELING_AIRPLANE_MODE", "SNORKELING_OFFLINE", "Airplane mode sync deferral and recovery", "Paired iPhone + Watch", "Pending transfer queue", True),
    ("SNK-QA-015", "SNORKELING_PHOTO_PRIVACY", "SNORKELING_PRIVACY_REDACTION", "Photo EXIF redaction and export privacy", "Physical iPhone", "Session photos with location metadata", True),
    ("SNK-QA-016", "SNORKELING_EXPORT", "SNORKELING_EXPORT", "Session export formats and share sheet", "Physical iPhone", "Completed Snorkeling session in Logbook", False),
    ("SNK-QA-017", "SNORKELING_WATCH_LAYOUTS", "SNORKELING_SMALL_WATCH_LAYOUT,SNORKELING_WATCH_ULTRA", "Layout on smallest Watch and Watch Ultra", "41 mm and 49 mm Apple Watch", "Same session script on both sizes", False),
    ("SNK-QA-018", "SNORKELING_PAIR_UNPAIR", "SNORKELING_PAIRED_DEVICE_MATRIX", "Pair/unpair and multi-device matrix", "Multiple paired iPhone/Watch combinations", "Test matrix documented before execution", True),
    ("SNK-QA-019", "SNORKELING_HAPTICS", "SNORKELING_WATCH_UI", "Haptic alarms and marker confirmation on Watch", "Physical Apple Watch", "Haptics enabled in settings", False),
    ("SNK-QA-020", "SNORKELING_WET_GLOVE", "SNORKELING_WATER_LOCK", "Wet glove / crown interaction limits", "Physical Apple Watch", "Water Lock optional per scenario", False),
    ("SNK-QA-021", "SNORKELING_KEYCHAIN", "SNORKELING_IOS_WATCH_SYNC", "Sync crypto keychain trust and rotation", "Paired iPhone + Watch", "Fresh install or key rotation scenario", True),
]


def render(qa_id, folder, category, purpose, device, prereq, rollback):
    return f"""# Physical QA — {folder}

| Field | Value |
|-------|-------|
| **QA ID** | {qa_id} |
| **Command category** | {category} |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | {purpose} |
| **Required device** | {device} |
| **Tester** | |
| **Reviewer** | |
| **Execution date** | |
| **iPhone model** | |
| **iOS version** | |
| **Watch model** | |
| **watchOS version** | |
| **App build** | |
| **Test environment** | |
| **Rollback required** | {"YES" if rollback else "NO"} |

## Preconditions

{prereq}

## Test steps

1. Install the build at the recorded commit SHA.
2. Execute the scenario for **{folder}** per `PROCEDURE.md` when present.
3. Capture screenshot, video, or log artifacts under this folder (do not commit until reviewed).
4. Record observed results and compare to expected results.
5. Obtain tester and reviewer signatures before marking PASS.

## Expected results

(Document per scenario before execution. Do not mark PASS without matching observed behavior.)

## Observed results

**PENDING** — no physical evidence recorded yet.

## Evidence artifacts

- (none — add `evidence-YYYYMMDD.ext` paths after capture)

## Battery / thermal notes

(Required for battery/thermal scenarios; optional otherwise.)

## Linked issues

- (none)

## Signatures

| Role | Name | Date |
|------|------|------|
| Tester | | |
| Reviewer | | |

## Tester signature

(pending)

## Reviewer signature

(pending)

## Verdict

**PENDING** — PASS requires completed steps, attached artifacts, tester signature, and reviewer signature.
Do not mark PASS without real device execution.
"""


def main() -> None:
    for qa_id, folder, category, purpose, device, prereq, rollback in ENTRIES:
        target = ROOT / "Docs" / "QA_EVIDENCE" / folder
        target.mkdir(parents=True, exist_ok=True)
        readme = target / "README.md"
        readme.write_text(render(qa_id, folder, category, purpose, device, prereq, rollback), encoding="utf-8")
        print(f"scaffolded {readme}")


if __name__ == "__main__":
    main()
