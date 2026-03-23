#!/system/bin/sh
# daemon.sh

MODDIR=${0%/*}
. "$MODDIR/utils.sh" # import utils
if [ -e "$DAEMON_PID" ]; then
    echo -e "Daemon is already running."
    exit
fi
write_daemon_pid # write daemon pid to file

export DAEMON_STARTUP=1
while true; do
    export CALL_FROM_DAEMON=1
    "$MODDIR/fix.sh" # run fix
    sleep 1800 # sleep for 30 minutes
done