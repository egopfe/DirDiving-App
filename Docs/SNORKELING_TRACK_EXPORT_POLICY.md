# Snorkeling Track Export Policy

- GPX and KML exports use Foundation-only XML generation.
- Only **measured** surface coordinates with valid lat/lon are exported.
- Invalid or unavailable coordinates are excluded from track segments.
- Measured markers may be included as GPX waypoints / KML placemarks.
- Session summary text export is privacy-aware via `SnorkelingExportPrivacyOptions`.
- Location export requires explicit acknowledgement when the session contains GPS data.
