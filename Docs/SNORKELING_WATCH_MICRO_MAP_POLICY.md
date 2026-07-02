# Snorkeling Watch Micro-Map Policy

**Scope:** Snorkeling Watch navigation and return screens only.

## Presentation

- Compact Canvas preview shown **alongside** `DiveBearingRing`; never replaces it.
- Current position anchored near bottom center; simplified route polyline; entry bearing arrow; next waypoint dot.
- Maximum 24 downsampled route points; 180 m projection span.

## Availability

Hide micro-map when:

- Underwater
- GPS presentation is not `.tracking` or `.degraded`
- Current coordinate invalid
- No heading, entry direction, or route line to render

Unavailable copy: `snorkeling.watch.micro_map.unavailable`.

## Forbidden

- MapKit on Watch
- Pan/zoom or route editing
- Safety-critical claims ("safe route", "guaranteed return")
