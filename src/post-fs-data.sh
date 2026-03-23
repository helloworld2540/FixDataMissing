#!/system/bin/sh
# post-fs-data.sh

# tools variable
MODDIR=${0%/*}
rm -f "$REBOOT_FLAG" # clear reboot flag
rm -f "$LOCK_FILE" # clear lock file
rm -f "$DAEMON_PID" # clear daemon pid
"$MODDIR/refresh_description.sh" & # refresh description and not stuck boot