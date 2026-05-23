# -*- coding: utf-8 -*-
"""Generate MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.docx from audit data."""
from __future__ import annotations

import subprocess
from pathlib import Path

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Inches, Pt

HERE = Path(__file__).resolve().parent
REPO = HERE.parent
OUT = HERE / "MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.docx"
IMG_WATCH = HERE / "ReferenceUI" / "Watch_LIVE_reference.png"
IMG_IOS = HERE / "ReferenceUI" / "iOS_Companion_reference.png"


def _git(*args: str) -> str:
    try:
        return subprocess.check_output(["git", *args], cwd=REPO, text=True).strip()
    except (subprocess.CalledProcessError, FileNotFoundError, OSError):
        return "n/d"


def para(doc: Document, text: str, bold: bool = False, size: int = 10) -> None:
    p = doc.add_paragraph()
    r = p.add_run(text)
    r.bold = bold
    r.font.size = Pt(size)


def bullets(doc: Document, items: list[str]) -> None:
    for it in items:
        doc.add_paragraph(it, style="List Bullet")


def table(doc: Document, headers: list[str], rows: list[list[str]]) -> None:
    t = doc.add_table(rows=1, cols=len(headers))
    t.style = "Table Grid"
    for i, h in enumerate(headers):
        t.rows[0].cells[i].text = h
    for row in rows:
        cells = t.add_row().cells
        for i, val in enumerate(row):
            cells[i].text = val


def main() -> None:
    doc = Document()
    head = _git("rev-parse", "HEAD")
    branch = _git("rev-parse", "--abbrev-ref", "HEAD")

    h = doc.add_heading("DIR DIVING — MAIN BRANCH COMPLETE READINESS AUDIT", 0)
    h.alignment = WD_ALIGN_PARAGRAPH.CENTER
    para(doc, f"Date: 2026-05-20 · Branch: {branch} · HEAD: {head}", bold=True)
    para(
        doc,
        "Audit-only: no code changes. Scope: Apple Watch MAIN + iOS Companion MAIN on unified main. "
        "Experimental branches not inspected except target exclusion in project.yml.",
    )

    doc.add_heading("A. Branch Confirmed", level=1)
    bullets(
        doc,
        [
            f"Branch: {branch} · HEAD: {head}",
            "project.yml valid; xcodegen generate succeeded.",
            "Experimental sources excluded from MAIN targets (Apnea, Snorkeling, Buddy, Exploration).",
            "xcodebuild: DIRDiving Watch App + DIRDiving iOS — BUILD SUCCEEDED (simulator, 2026-05-20).",
            "Bundle IDs: com.egopfe.dirdiving (Watch), com.egopfe.dirdiving.ios (iOS).",
        ],
    )

    doc.add_heading("B. Executive Summary", level=1)
    table(
        doc,
        ["Dimension", "Readiness %"],
        [
            ["Overall MAIN", "84%"],
            ["Apple Watch MAIN", "88%"],
            ["iOS Companion MAIN", "86%"],
            ["UX completeness", "80%"],
            ["Safety / disclaimers", "82%"],
            ["Compile readiness", "92%"],
        ],
    )
    para(
        doc,
        "Verdict: ready for internal/simulator testing and developer-led device QA. "
        "Not 100% for average consumer or App Store until real Ultra depth validation, "
        "physical sync QA, and release legal/asset review.",
    )

    doc.add_heading("Visual benchmarks", level=2)
    if IMG_WATCH.exists():
        doc.add_picture(str(IMG_WATCH), width=Inches(2.2))
        para(doc, "Watch reference: Watch_LIVE_reference.png")
    if IMG_IOS.exists():
        doc.add_picture(str(IMG_IOS), width=Inches(2.8))
        para(doc, "iOS reference: iOS_Companion_reference.png")

    doc.add_heading("C. Feature Inventory (summary)", level=1)
    table(
        doc,
        ["Platform", "Feature", "Complete", "Severity", "Notes"],
        [
            ["Watch", "Live dive + ascent banner", "Y", "—", "Inline banner; gauge visible"],
            ["Watch", "BUSSOLA / bearing", "Y", "—", "BUSSOLA terminology"],
            ["Watch", "GPS start/end", "Y", "—", "Compact banner ~1.4s (a75a6c3)"],
            ["Watch", "iPhone → Watch sync", "Partial", "MED", "didReceive* implemented; device QA needed"],
            ["Watch", "Alarm dismiss OK", "Y", "—", "15s cooldown"],
            ["iOS", "Logbook / detail / export", "Y", "—", ""],
            ["iOS", "Planner + Bühlmann", "Partial", "MED", "Indicative disclaimer"],
            ["iOS", "Watch import + tombstone", "Partial", "MED", "Shared key; QA on device"],
            ["Both", "Secondary i18n", "Partial", "LOW", "~240 EN keys; planner gaps remain"],
        ],
    )

    doc.add_heading("D. Navigation Map", level=1)
    para(doc, "Watch: Mode Selection → Live; tabs: Mode | Live | BUSSOLA | Settings | Images | Log.", bold=True)
    para(doc, "iOS: Logbook | Analisi | Planner | Attrezzatura | Altro.", bold=True)

    doc.add_heading("E. UI Consistency", level=1)
    bullets(
        doc,
        [
            "Watch: high match to black/neon DiveUI; GPS now compact banner (aligned with reference intent).",
            "iOS: high match to DIRTheme dark marine + cyan; verify AppIcon in Xcode archive.",
            "i18n: improved secondary pass; residual IT on planner/GPS detail possible.",
        ],
    )

    doc.add_heading("F. Settings", level=1)
    bullets(
        doc,
        [
            "Watch: ascent limits, alarms, haptics, language — persisted; settings sync to iPhone planned only.",
            "iOS: language editable; units/export read-only; cloud sync trigger; demo logbook for review.",
        ],
    )

    doc.add_heading("G. Haptics / Tones", level=1)
    bullets(
        doc,
        [
            "Watch: haptics for stopwatch, ascent alarm, alarms, compass, export — gated by toggle.",
            "Watch: alarm OK dismiss on live screen (SAF-8 fixed).",
            "iOS: no alert sounds; visual feedback only.",
        ],
    )

    doc.add_heading("H. Hardware", level=1)
    para(
        doc,
        "App Intents: manual dive, bearing, alarm acknowledge, stopwatch. "
        "Side button not mapped (documented in WatchShortcutHelpView).",
    )

    doc.add_heading("I. Sync", level=1)
    bullets(
        doc,
        [
            "FIXED: Watch didReceiveMessage / didReceiveUserInfo (a75a6c3).",
            "FIXED: dirdiving_shared_deleted_session_ids + WC tombstone broadcast.",
            "Watch → iPhone outbound queue + signed ack implemented.",
            "REMAINING: first-pairing education; per-session delivery UI; physical QA.",
        ],
    )

    doc.add_heading("J. Export", level=1)
    para(doc, "Subsurface CSV on Watch and iOS; GPX/KML not on MAIN. Share/error feedback present.")

    doc.add_heading("K. Safety", level=1)
    bullets(
        doc,
        [
            "Not presented as certified dive computer.",
            "Planner and TTV marked indicative in UI/README/More.",
            "Water submersion entitlement configured; real Ultra validation still required.",
        ],
    )

    doc.add_heading("L. Error / Empty states", level=1)
    para(doc, "Logbook and Analysis empty states with real actions (import, sync). GPS/depth failures labeled.")

    doc.add_heading("M. Bugs To Fix (top)", level=1)
    table(
        doc,
        ["#", "Title", "Sev.", "Fix type"],
        [
            ["1", "Depth entitlement not validated on real Ultra", "HIGH", "Process / QA"],
            ["2", "First-pairing sync appears broken without docs", "MED", "Process + copy"],
            ["3", "Mode Selection extra launch step", "LOW", "UI-only"],
            ["4", "UserImages tab when bundle empty", "LOW", "UI-only"],
            ["5", "Residual i18n planner/GPS detail", "LOW", "UI-only"],
            ["6", "iOS AppIcon archive completeness", "MED", "Assets"],
        ],
    )
    para(doc, "Resolved: Watch inbound WC, tombstones, GPS banner, alarm dismiss, simulator builds.", bold=True)

    doc.add_heading("N. Priority Roadmap", level=1)
    bullets(
        doc,
        [
            "Before compile/use: simulator builds OK; verify signing + entitlements on portal.",
            "Before TestFlight: Ultra depth smoke test + bidirectional sync on physical devices.",
            "Before App Store: legal/privacy, primary-flow i18n, App icon/screenshots.",
            "Post-release: skip Mode Selection, hide empty UserImages, GPX, settings sync.",
        ],
    )

    doc.add_heading("O. Final Verdict", level=1)
    table(
        doc,
        ["Question", "Answer"],
        [
            ["Ready to compile?", "Yes (simulator builds succeeded)"],
            ["Ready for internal test?", "Yes with pairing checklist"],
            ["Ready for average user?", "Conditional"],
            ["Ready for TestFlight?", "After device depth + sync QA"],
            ["Ready for App Store?", "No"],
        ],
    )

    para(doc, "Full markdown source: Docs/MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md", size=9)
    doc.save(OUT)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
