#!/system/bin/sh
# daemon.sh

MODDIR=${0%/*}
. "$MODDIR/utils.sh" # import utils
write_daemon_pid # write daemon pid to file

while true; do
    export CALL_FROM_DAEMON=1
    echo $(($(date +%s) + 300)) > "$NEXT_TIME" # update next time
    "$MODDIR/fix.sh" & # run fix
    sleep 300 # sleep for 5 minutes
done