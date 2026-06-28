# Build and XcodeGen Workflow (MAIN)

## Required workflow

1. Run `xcodegen generate` before opening or building `DIRDiving.xcodeproj`.
2. Do not manually edit generated `.xcodeproj` files.
3. Regenerate the project after every `project.yml` change.

## Validation commands

- `./Scripts/check_main_target_isolation.sh`
- `./Scripts/check_secrets.sh`
- `./Scripts/validate_main_release_readiness.sh`

## Drift policy

- `DIRDiving.xcodeproj` is generated from `project.yml`.
- CI runs `xcodegen generate` and fails if `git diff -- DIRDiving.xcodeproj` is not clean.
- Any PR touching `project.yml` must include regenerated project output.

## Scope guardrails

- MAIN targets: `DIRDiving Watch App`, `DIRDiving iOS`.
- Experimental files remain excluded per `project.yml`.
- This workflow does not certify physical QA, underwater tests, or App Store asset completeness.

## Watch entitlements (shallow depth device builds)

- Default signing uses `Config/DIRDiving.WithShallowDepth.entitlements` (`com.apple.developer.submerged-shallow-depth-and-pressure`).
- Watch `App/Info.plist` sets `DIRDepthEntitlementTier` to `shallow` so runtime capability resolution matches the signed build.
- Full Ultra depth / legacy water-submersion archives: switch `CODE_SIGN_ENTITLEMENTS` to `Config/DIRDiving.WithWaterSubmersion.entitlements` and set tier `full` when Apple approves that capability.
- Entitlement-free simulator builds are not the default on `main`; use `Config/DIRDiving.entitlements` only on a dedicated dev branch if simulation-only signing is required.
