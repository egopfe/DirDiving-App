#!/usr/bin/env bash
# Regenerate AppIcon asset catalogs from Docs/ReferenceIcon sources.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS_SRC="$ROOT/Docs/ReferenceIcon/ios icon.png"
WATCH_SRC="$ROOT/Docs/ReferenceIcon/apple watch icon.png"
IOS_DIR="$ROOT/iOSApp/Resources/Assets.xcassets/AppIcon.appiconset"
WATCH_DIR="$ROOT/Resources/Assets.xcassets/AppIcon.appiconset"

resize() { sips -z "$2" "$3" "$1" --out "$4" >/dev/null; }

echo "iOS AppIcon..."
resize "$IOS_SRC" 40 40 "$IOS_DIR/icon_20_20_2x.png"
resize "$IOS_SRC" 60 60 "$IOS_DIR/icon_20_20_3x.png"
resize "$IOS_SRC" 58 58 "$IOS_DIR/icon_29_29_2x.png"
resize "$IOS_SRC" 87 87 "$IOS_DIR/icon_29_29_3x.png"
resize "$IOS_SRC" 80 80 "$IOS_DIR/icon_40_40_2x.png"
resize "$IOS_SRC" 120 120 "$IOS_DIR/icon_40_40_3x.png"
resize "$IOS_SRC" 120 120 "$IOS_DIR/icon_60_60_2x.png"
resize "$IOS_SRC" 180 180 "$IOS_DIR/icon_60_60_3x.png"
resize "$IOS_SRC" 1024 1024 "$IOS_DIR/icon_1024_1024_1x.png"

echo "watchOS AppIcon..."
resize "$WATCH_SRC" 48 48 "$WATCH_DIR/icon_48_2x.png"
resize "$WATCH_SRC" 55 55 "$WATCH_DIR/icon_55_2x.png"
resize "$WATCH_SRC" 58 58 "$WATCH_DIR/icon_58_2x.png"
resize "$WATCH_SRC" 87 87 "$WATCH_DIR/icon_87_3x.png"
resize "$WATCH_SRC" 80 80 "$WATCH_DIR/icon_80_2x.png"
resize "$WATCH_SRC" 88 88 "$WATCH_DIR/icon_88_2x.png"
resize "$WATCH_SRC" 100 100 "$WATCH_DIR/icon_100_2x.png"
resize "$WATCH_SRC" 102 102 "$WATCH_DIR/icon_102_2x.png"
resize "$WATCH_SRC" 108 108 "$WATCH_DIR/icon_108_2x.png"
resize "$WATCH_SRC" 172 172 "$WATCH_DIR/icon_172_2x.png"
resize "$WATCH_SRC" 196 196 "$WATCH_DIR/icon_196_2x.png"
resize "$WATCH_SRC" 216 216 "$WATCH_DIR/icon_216_2x.png"
resize "$WATCH_SRC" 234 234 "$WATCH_DIR/icon_234_2x.png"
resize "$WATCH_SRC" 258 258 "$WATCH_DIR/icon_258_2x.png"
resize "$WATCH_SRC" 1024 1024 "$WATCH_DIR/icon_1024_1x.png"

echo "Done. If icons still look stale in Simulator: Product > Clean Build Folder, delete app, reset simulator."
