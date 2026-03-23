#!/system/bin/sh
# service.sh

# tools variable
MODDIR=${0%/*}

. "$MODDIR/utils.sh" # import utils
wait_until_login # wait for system ready
rm -f "$REBOOT_FLAG" # clear reboot flag
rm -f "$LOCK_FILE" # clear lock file
"$MODDIR"/daemon.sh & # start daemon in background