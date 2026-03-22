#!/system/bin/sh
# action.sh

MODDIR=${0%/*}
export CALL_FROM_DAEMON=0
. "$MODDIR"/fix.sh # run fix (in current shell)