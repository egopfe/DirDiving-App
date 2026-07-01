# Diving Import / Export Center — Completion Plan

**Status:** Implemented

---

## Target UX

```
Diving Logbook → Import / Export Center
  Import tab: CSV, Subsurface XML, UDDF (unchanged flow)
  Export tab: select dives → CSV | XML | UDDF → Generate → Share

Dive Detail → Export section
  Format picker: CSV | XML | UDDF → Generate → Share
```

---

## Export rules

| Format | Single dive | Multi dive |
|--------|-------------|------------|
| CSV | ✅ via `SubsurfaceExportService` | ❌ user-friendly error |
| Subsurface XML | ✅ | ✅ |
| UDDF | ✅ | ✅ |

Demo/fake dives: excluded from export list; non-exportable with warning.

---

## Exclusions

- Subsurface Cloud, Bluetooth, USB, credentials
- Snorkeling / Apnea import-export
- Watch runtime / sync changes
- Decompression algorithm changes
