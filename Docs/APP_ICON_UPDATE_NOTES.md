# App icon update notes

**Sources:** `Docs/ReferenceIcon/ios icon.png`, `Docs/ReferenceIcon/apple watch icon.png`  
**Catalogs:** `iOSApp/Resources/Assets.xcassets/AppIcon.appiconset`, `Resources/Assets.xcassets/AppIcon.appiconset`  
**Targets:** `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` (both iOS and Watch in `project.yml`)

## Regenerate sizes

```bash
chmod +x Scripts/update_app_icons.sh
./Scripts/update_app_icons.sh
```

## If the icon still looks old in Simulator or on device

1. Xcode → **Product → Clean Build Folder**
2. Delete the app from Simulator/device
3. Optional: clear Derived Data for `DIRDiving`
4. Rebuild and reinstall

Internal UI graphics and in-app branding are unchanged.
