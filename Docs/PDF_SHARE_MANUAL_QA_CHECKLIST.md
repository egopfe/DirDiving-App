# PDF share manual QA checklist

**Status:** **PENDING** — no device evidence recorded unless files exist under `Docs/QA_EVIDENCE/PDF_SHARE/`.

Automated tests validate PDF generation, file URLs, non-zero size, `%PDF` header, and protected export directory. **Mail, AirDrop, WhatsApp, and Files app behavior require manual device QA.**

## Preconditions

- Valid planner plan with safety acknowledgment
- Non-empty equipment checklist (for checklist / dive pack)
- iPhone on iOS 17+ with test Apple ID (optional for Mail)

## Scenarios

| # | Export type | Share target | Steps | Expected | Evidence file name | Status |
|---|-------------|--------------|-------|----------|-------------------|--------|
| 1 | Plan PDF | Files | Export plan → Share → Save to Files | PDF opens; disclaimer visible | `pdf_share_files_plan_YYYYMMDD.png` | PENDING |
| 2 | Briefing PDF | Mail | Export briefing → Share → Mail draft | Attachment valid; TTS label correct | `pdf_share_mail_briefing_YYYYMMDD.png` | PENDING |
| 3 | Checklist PDF | AirDrop | Export checklist → AirDrop to second device | PDF opens; YES/NO rows; switch depth in user units | `pdf_share_airdrop_checklist_YYYYMMDD.png` | PENDING |
| 4 | Dive pack | WhatsApp (if installed) | Export dive pack → Share → WhatsApp | File attaches; non-zero size | `pdf_share_whatsapp_divepack_YYYYMMDD.png` | PENDING |
| 5 | Imperial units | Files | Set units to ft/psi → checklist PDF | Switch depths in feet, not hardcoded meters | `pdf_share_imperial_checklist_YYYYMMDD.png` | PENDING |

## Evidence folder

`Docs/QA_EVIDENCE/PDF_SHARE/` — create when executing manual QA. Do not mark complete without screenshots or screen recordings.

## Automated coverage (repository)

- `PDFExportServiceTests` — plan, briefing, checklist, dive pack URLs and readability
- `BriefingPDFBuilderTests` — briefing content and Ratio Deco disclaimer
