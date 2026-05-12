# DIR DIVING iOS Experimental Features

This document tracks experimental iPhone companion work on the `codex/ios-experimental-features` branch.

The branch starts from `main-iOS` and is intended to stay aligned with the Apple Watch experimental branch:

```text
Apple Watch experimental branch: codex/experimental-features
iOS experimental branch:         codex/ios-experimental-features
Stable iOS branch:               main-iOS
```

## Branch Rules

- Keep stable iOS companion work on `main-iOS`.
- Keep exploratory iOS companion work on `codex/ios-experimental-features`.
- Do not add Apple Watch targets back into this iOS branch.
- Do not add Buddy/BLE watchOS runtime code directly to the iOS target.
- Mirror experimental Watch concepts only as iPhone companion UI, planning, status, configuration, documentation, or sync-support scaffolding.

## Initial Scope

The branch currently matches `main-iOS` and is ready for experimental iOS companion work related to:

- Buddy Assist companion status surfaces.
- Secure pairing review/status UI for data synchronized from Apple Watch.
- Experimental dive-planning tools that support Watch-side features.
- Additional analysis and validation screens for experimental Watch data.
- Documentation and presentation assets that track experimental Watch capability.

## Safety Position

Any Buddy Assist, Buddy Link, BLE proximity, secure pairing, or underwater communication feature remains experimental. The iPhone companion must not describe these features as certified dive safety, rescue, or underwater navigation systems.
