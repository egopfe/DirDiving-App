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
