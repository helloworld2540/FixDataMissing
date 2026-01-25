#!/bin/sh
# build.sh

ME=${0##*/}
ROOT=${0%/$ME}

# just put the script to .zip
rm -f latest_build.zip
7z a "$ROOT/latest_build.zip" "$ROOT"/*.sh "$ROOT"/changelog.md "$ROOT"/module.prop -x!"$ROOT/$ME"