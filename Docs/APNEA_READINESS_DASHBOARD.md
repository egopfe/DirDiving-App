# Apnea Readiness Dashboard Card

## Location

`IOSApneaDashboardView` — visible below header, **before** last session / empty state.

## Content

- Profile (first available companion profile)
- Checklist: `X/7 completed`
- Recovery alerts: ON/OFF (from haptics setting)
- Session Check: Ready / Warning / Incomplete

## Quick actions

- Open checklist → sheet with `IOSApneaChecklistView`
- Open session check → sheet with `IOSApneaSessionCheckView`
- New session (existing CTA)

Card is shown even when logbook is empty.
