#!/system/bin/sh
# refresh_description.sh

# tools variable
MODDIR=${0%/*}
. "$MODDIR/utils.sh" # import utils

# original description
ORIDES="Fix Android/data, Android/obb, Android/media is missing."
NL=$'\n'

if [ -e "$REBOOT_FLAG" ]; then
    NEW_DES="[🤔 A reboot is pending.] ${NL}"
elif [ -e "$DAEMON_PID" ]; then
    local PID_DAEMON="$(cat "$DAEMON_PID")"
    NEW_DES="[✅ Deamon is running on PID $PID_DAEMON]${NL}"
    if [ "$CALL_FROM_DAEMON" = "1" ]; then
        NEW_DES="$NEW_DES- Last fix time: $(date +"%H:%M") (✅ Auto fix)${NL}"
    else
        NEW_DES="$NEW_DES- Last fix time: $(date +"%H:%M") (⭕ Manual fix)${NL}"
    fi
    NEW_DES="$NEW_DES- Next auto fix time: $(date -d @"$(cat "$NEXT_TIME")" +"%H:%M")${NL}"
    NEW_DES="$NEW_DES- Click 'action' to run fix.${NL}"
    
else
    NEW_DES="[❌ Deamon is not running.] ${NL}"
    NEW_DES="$NEW_DES- Click 'action' to run fix and start deamon.${NL}"
fi
NEW_DES="$NEW_DES$ORIDES"
sed -i "s#^description=.*#description=$NEW_DES#" "$PROP"