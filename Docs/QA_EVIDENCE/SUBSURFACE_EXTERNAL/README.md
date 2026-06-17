# Subsurface Desktop External Validation Evidence

**Status:** PENDING  
**Scope:** Import DIR DIVING CSV exports into Subsurface desktop and compare profile/gas metadata  
**Rule:** No PASS without attached evidence files in this folder.

## Required scenarios

| Scenario ID | Profile | Expected |
|---|---|---|
| SUB-OC-AIR | OC air no-deco | Depth/time samples import |
| SUB-OC-TRIMIX | OC trimix deco | Gas columns preserved |
| SUB-MANUAL | Manual no-profile session | Metadata policy respected |
| SUB-CCR-META | CCR session metadata | CCR fields per export policy only |

## Evidence checklist

- [ ] Subsurface version and OS
- [ ] Source CSV from app export
- [ ] Screenshot of imported dive
- [ ] Tester and date
- [ ] Result: PENDING / PASS / FAIL

Internal `CSV_SUBSURFACE` automated tests do **not** replace desktop validation.
