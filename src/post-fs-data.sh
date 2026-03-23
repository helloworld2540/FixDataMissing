#!/system/bin/sh
# post-fs-data.sh

# tools variable
MODDIR=${0%/*}
"$MODDIR/refresh_description.sh" & # refresh description and not stuck boot