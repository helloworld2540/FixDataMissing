#!/system/bin/sh
# daemon.sh

MODDIR=${0%/*}
. "$MODDIR/utils.sh" # import utils
write_daemon_pid # write daemon pid to file

export DAEMON_STARTUP=1
while true; do
    export CALL_FROM_DAEMON=1
    "$MODDIR/fix.sh" # run fix
    export DAEMON_STARTUP=0
    sleep 300 # sleep for 5 minutes
done