#!/system/bin/sh
# refresh_description.sh

# tools variable
MODDIR=${0%/*}
. "$MODDIR/utils.sh" # import utils

# original description
ORIDES="Fix Android/data, Android/obb, Android/media is missing."
if [ -e "$DISABLE_FLAG" ]; then
    NEW_DES="[❌ Disabled] \\n"
elif [ -e "$REBOOT_FLAG" ]; then
    NEW_DES="[🤔 A reboot is pending.] \\n"
elif [ -e "$DAEMON_PID" ]; then
    local PID_DAEMON="$(cat "$DAEMON_PID")"
    NEW_DES="[✅ Daemon running on PID $PID_DAEMON] \\n"
    if [ "$DAEMON_STARTUP" = "1" ]; then
        NEW_DES="$NEW_DES initializing... 🤖\\n"
    else
        if [ $LOCKED -eq 1 ]; then
            NEW_DES="$NEW_DES locked: $(date +"%H:%M") 🔒"
        elif [ "$CALL_FROM_DAEMON" = "1" ]; then
            NEW_DES="$NEW_DES auto fix: $(date +"%H:%M") 🤖"
        else
            NEW_DES="$NEW_DES manual fix: $(date +"%H:%M") 🙂"
        fi
        NEW_DES="$NEW_DES | Next fix: $(date -d @"$(cat "$NEXT_TIME")" +"%H:%M")\ 🤖\\n"
    fi
else
    NEW_DES="[❌ Deamon is not running.] \\n"
    NEW_DES="$NEW_DES Click 'action' to restart deamon.\\n"
fi
NEW_DES="$NEW_DES$ORIDES"
STATIC_PROPS=$(grep -v "^description=" "$PROP")
printf "%s\ndescription=%s\n" "$STATIC_PROPS" "$NEW_DES" > "$PROP"