# Snorkeling VoiceOver — Physical Procedure

**QA ID:** SNK-QA-008 (`SNORKELING_VOICEOVER`)  
**Status:** PENDING — do not mark PASS without device walkthrough.

## Devices

- Physical Apple Watch (41 mm and 49 mm recommended)
- Paired iPhone with Snorkeling companion
- VoiceOver enabled on both devices (EN primary; repeat critical paths in IT)

## Watch walkthrough

1. Launch DIR DIVING → activity selection → select **Snorkeling**.
2. **Ready:** confirm GPS status, depth sensor, entry point, duration, and start button are announced; start hint spoken when disabled.
3. **Surface dashboard:** runtime, distance, speed, dips announced in logical order.
4. **Dip:** max depth, dip duration, vertical speed announced; decorative ring hidden from VoiceOver.
5. **Waypoint navigation:** turn guidance spoken as text (not arrow-only); GPS unavailable state announced when applicable.
6. **Return to entry:** distance/bearing guidance readable; degraded GPS announced.
7. **Save marker:** confirmation banner announced after save.
8. **Session summary:** totals and session end announced.

## iOS walkthrough

1. Open Snorkeling companion → **Dashboard** (`snorkeling.ios.dashboard`).
2. **Route planner** (`snorkeling.ios.route_planner`): map summary and waypoint list readable.
3. **Logbook** (`snorkeling.ios.logbook`): rows identify Snorkeling activity.
4. **Session detail / map** (`snorkeling.ios.map_summary`): gap warnings and fix quality announced.
5. **Export** (`snorkeling.ios.export`): privacy toggles and share action labeled.

## Expected

- EN and IT labels present for production keys in `SnorkelingLocalizationCatalog` / iOS catalog.
- No decorative-only elements exposed without labels.
- GPS degraded/unavailable states distinguishable from tracking.

## Artifacts

- Screen recording with VoiceOver audio (Watch + iOS)
- Note any missed announcements in `README.md` observed results
