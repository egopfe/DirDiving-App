# mockups/ — canonical UI reference assets

All **current** raster mockups for DIR Diving MAIN live under `mockups/**`.

## Policy

- **Canonical:** `mockups/**` (this directory)
- **Historical only:** `Docs/ReferenceUI/archive/` (deprecated pre-three-mode references)
- **Never** embed PNG mockups in app bundles or live SwiftUI layouts
- Reference matrices: `Utils/ApneaMockupReferenceMatrix.swift`, `Utils/SnorkelingMockupReferenceMatrix.swift`, `Utils/FullComputerMockupReferenceMatrix.swift`

## Layout

```text
mockups/
├── IOS_COMPANION_ACTIVITY_SELECTION_POST_ONBOARDING.png
├── FC_UI_*.png                    # Watch Full Computer states
├── Apple_Watch/                   # Apnea + Snorkeling Watch
└── iOS/                           # Apnea + Snorkeling iOS Companion
```

Duplicate Snorkeling PNGs previously under `Docs/ReferenceUI/Snorkeling/` were removed; use paths under `mockups/` only.
