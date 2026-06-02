# Branch and Target Isolation Policy (MAIN)

## Canonical release branch

- Release candidate branch is `main`.
- Experimental branches remain isolated and are not release sources.

## MAIN target set

- `DIRDiving Watch App`
- `DIRDiving iOS`
- `DIRDiving Watch Algorithm Tests`
- `DIRDiving iOS Algorithm Tests`

## Required compatibility checks before merge/release

- [ ] Watch build passes
- [ ] iOS build passes
- [ ] Watch algorithm tests pass
- [ ] iOS algorithm tests pass
- [ ] Watch/iOS sync codec compatibility tests pass
- [ ] Manual/no-depth session round-trip checks pass
- [ ] CSV round-trip checks pass
- [ ] EN/IT localization key parity passes for Watch and iOS
- [ ] `project.yml` experimental exclusions unchanged

## Automation

- Run `./Scripts/check_main_target_isolation.sh` locally and in CI.
- Run `./Scripts/validate_main_release_readiness.sh` before release tagging.
