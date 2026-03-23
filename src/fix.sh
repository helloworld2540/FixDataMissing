#!/system/bin/sh
# fix.sh

MODDIR=${0%/*}
. "$MODDIR/utils.sh" # import utils

log(){
    if [ $CALL_FROM_DAEMON -eq 0 ]; then
        echo "$1"
    fi
}

main(){
    # makesure Android/data, Android/obb, Android/media is exist
    new_dir "$ANDROID/data"
    assert $?
    new_dir "$ANDROID/obb"
    assert $?
    new_dir "$ANDROID/media"
    assert $?

    # get app list that installed
    log "Getting app list..."
    local APP_LIST=$(pm list packages)
    assert $?

    local COUNT=$(echo "$APP_LIST" | wc -l)
    local COUNTER=0
    for app in $APP_LIST; do
        local COUNTER=$(($COUNTER + 1))
        local TMP_FAILED=$FAILED
        local app=${app#package:} # remove prefix
        if [ -z "$app" ]; then # skip empty line
            continue
        fi
        local DATA="$ANDROID/data/$app"
        local OBB="$ANDROID/obb/$app"
        local MEDIA="$ANDROID/media/$app"

        # create directory
        mkdir -p -m 777 "$DATA"
        mkdir -p -m 777 "$OBB"
        mkdir -p -m 777 "$MEDIA"
        
        if [ $CALL_FROM_DAEMON -eq 0 ]; then
            draw_ui "$COUNTER" "$COUNT" "$FAILED"
        fi
    done

    
}
cleanup(){
    rm_file "$LOCK_FILE"
}
local start_time=$(date +%s)
if [ -e "$LOCK_FILE" ]; then
    export LOCKED=1
else
    export LOCKED=0
    # add lock
    rm_dir "$LOCK_FILE"
    echo $$ > "$LOCK_FILE"
    trap cleanup EXIT INT TERM
    if [ $DAEMON_STARTUP -eq 1 ]; then
        "$MODDIR/refresh_description.sh"
        export DAEMON_STARTUP=0
    fi
    main
fi

local end_time=$(date +%s)
if [ $CALL_FROM_DAEMON -eq 1 ]; then
    echo $(($(date +%s) + 1800 + $(($end_time - $start_time)))) > "$NEXT_TIME" # update next time
else
    echo -e "\r[DONE] Fixed $COUNT apps in $(($end_time - $start_time))s.         "
fi

if [ $LOCKED -eq 1 ]; then
    echo -e "Another instance is running, exiting..."
    "$MODDIR/refresh_description.sh"
    exit
fi