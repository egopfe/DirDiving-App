# mockups/ — canonical UI reference assets

All **59** current raster mockups for DIR Diving MAIN live under `mockups/**` in this repository.

## Policy

- **Canonical root:** `mockups/**` (this directory)
- **Historical only:** `Docs/ReferenceUI/` and `Docs/ReferenceUI/archive/` — non-canonical design archives
- **Design references only:** PNG mockups are traceability references — **not** live UI and **not** App Store screenshots
- **Never** embed PNG mockups in app bundles or live SwiftUI layouts
- **Never** use mockup PNGs as App Store screenshots without separate approval
- Reference matrices: `Utils/FullComputerMockupReferenceMatrix.swift`, `Utils/ApneaMockupReferenceMatrix.swift`, `Utils/SnorkelingMockupReferenceMatrix.swift`, `Utils/MockupVisualRegressionRegistry.swift`
- Hashes and dimensions: `Docs/MOCKUP_PATH_VALIDATION_CURRENT.csv`

## Layout

```text
mockups/
├── IOS_COMPANION_ACTIVITY_SELECTION_POST_ONBOARDING.png
├── FC_UI_*.png                    # Watch Full Computer + iOS plan transfer
├── Apple_Watch/                   # Apnea + Snorkeling Watch
└── iOS/                           # Apnea + Snorkeling iOS Companion
```

## QA gates (external — not claimed by software tests)

| Gate | Status |
|------|--------|
| Physical pixel-diff on device | **PENDING** |
| Manual visual-fidelity scoring | **PENDING** |
| Smallest Watch (41 mm) physical layout | **PENDING** |
| Dynamic Type XL physical planner QA | **PENDING** |
| App Store screenshot approval | **PENDING** (separate from mockups) |

Software validation: `./Scripts/validate_mockup_visual_regression_readiness.sh`
