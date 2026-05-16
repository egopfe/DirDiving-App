# GitHub setup

The iOS companion app is integrated in the existing DIR DIVING repository on the `main-iOS` branch.

```text
main-iOS
```

## Generate Xcode Project Locally

From the repository root:

```bash
xcodegen generate
open DIRDiving.xcodeproj
```

The generated `.xcodeproj` is intentionally not committed because it can be regenerated from `project.yml`.

## GitHub Update

```bash
git switch main-iOS
git push origin main-iOS
```
