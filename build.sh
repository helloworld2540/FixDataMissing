#!/bin/sh
# build.sh

ME=${0##*/}
ROOT=${0%/$ME}

# just put the script to .zip
read -p "Update the module? (y/n): " UPDATE
if [ "$UPDATE" = "y" ]; then
    read -p "New version: " NEW_VER
    read -p "New version code: " NEW_VER_CODE
    sed -i "s/^version=.*/version=$NEW_VER/" "$ROOT/module.prop"
    sed -i "s/^versionCode=.*/versionCode=$NEW_VER_CODE/" "$ROOT/module.prop"
    read -p "Add changelog? (y/n): " ADD_LOG
    if [ "$ADD_LOG" = "y" ]; then
        echo "# $NEW_VER ($NEW_VER_CODE)" > "$ROOT/changelog.md.tmp"
        while true; do
            read -p "- " LOG_LINE
            if [ -z "$LOG_LINE" ]; then
                break
            fi
            echo "- $LOG_LINE" >> "$ROOT/changelog.md.tmp"
        done
        cat "$ROOT/changelog.md" >> "$ROOT/changelog.md.tmp"
        mv "$ROOT/changelog.md.tmp" "$ROOT/changelog.md"
        rm -f "$ROOT/changelog.md.tmp"
    fi
fi
rm -f "$ROOT/latest_build.zip"
7z a "$ROOT/latest_build.zip" "$ROOT"/*.sh "$ROOT"/changelog.md "$ROOT"/module.prop -x!"$ROOT/$ME" > /dev/null 2>&1
[ $? -eq 0 ] && echo "Build successful: latest_build.zip" || echo "Build failed."