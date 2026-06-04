# App Intents Security Policy (Watch MAIN)

Safety-relevant App Intents (`StartManualDive`, `EndManualDive`, stopwatch, bearing, alarm acknowledge) call `LegalAcceptanceGate` before accessing `DiveManager` or `CompassManager`.

If legal onboarding is incomplete, intents fail with `shortcut.error.legal_acceptance_required` (EN/IT).

Action Button shortcuts remain available after acceptance; they are not removed.
