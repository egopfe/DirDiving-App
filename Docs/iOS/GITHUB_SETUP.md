# GitHub setup

The iOS companion app is integrated in the existing DIR DIVING repository on the `main-iOS` branch.

```text
main-iOS
```

## Generate Xcode Project Locally

From the **repository root** on branch `main` (unified Watch + iOS):

```bash
xcodegen generate
open DIRDiving.xcodeproj
```

The generated `.xcodeproj` is intentionally not committed (see root `.gitignore`). Use **only** the project at the repo root — not copies under `.worktrees/` or old checkouts.

## GitHub Update

```bash
git switch main-iOS
git push origin main-iOS
```
