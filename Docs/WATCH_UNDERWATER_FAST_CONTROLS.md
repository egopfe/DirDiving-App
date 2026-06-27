# Watch Underwater Fast Controls

## Model

Apple Watch does not expose three independent app buttons. DIR Diving uses:

| Hardware | Underwater role |
|----------|-----------------|
| **Digital Crown rotation** | Change screen (existing vertical `TabView`) |
| **Action Button (Ultra)** | Primary contextual action for current screen |

## Not used

- Crown press as OK
- Side button as app command
- Double-click
- Unverified long-press gestures
- Touch as primary underwater control

## Screen → Action mapping (active session)

| Page | Action Button |
|------|---------------|
| Live (Diving) | START / STOP stopwatch (contextual) |
| Compass (Diving) | SET / UPDATE bearing (never CLEAR by default) |
| User Images (Diving, if images exist) | NEXT IMAGE |
| Settings | Blocked in Phase 1 (not in allowed pages) |
| Any + alarm/overlay | ACK (priority) |

## Page policy (Phase 1)

**Diving active:** `.live`, `.compass`, `.userImages` (when images exist)  
**Apnea / Snorkeling active:** `.live` only  
**Never during session:** `.diveLog`, `.modeSelection`, `.settings`

## Safety

- Legal acceptance required for App Intent
- Full Computer stopwatch hidden → Action unavailable on Live
- Reset stopwatch and clear bearing remain separate intents (not primary underwater)
- No activity/mode changes from Action Button
- No decompression/gas setting changes

## Configuration

Assign **Execute underwater action** shortcut to Apple Watch Ultra Action Button in watchOS Settings.

## QA

Physical Apple Watch Ultra + Water Lock testing required. See `Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_*`.

**Verdict without physical QA:** INTERNAL_READY / PHYSICAL_WATER_LOCK_QA_PENDING / NO_CLAIM_ON_SIDE_BUTTON_OR_CROWN_PRESS
