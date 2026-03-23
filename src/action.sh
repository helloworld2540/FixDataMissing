#!/system/bin/sh
# action.sh

MODDIR=${0%/*}
. "$MODDIR/utils.sh" # import utils
if [ -e "$REBOOT_FLAG" ]; then
    echo -e "Reboot is pending, skipping..."
    exit
fi
# restart daemon
if [ ! -e "$DAEMON_PID" ]; then
    echo -e "Daemon is not running, restarting..."
    "$MODDIR"/daemon.sh &
    echo -e "Daemon restarted."
    exit
fi
# run fix
export CALL_FROM_DAEMON=0
. "$MODDIR"/fix.sh # run fix (in current shell)
