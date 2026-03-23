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

    COUNT=$(echo "$APP_LIST" | wc -l)
    local COUNTER=0
    for app in $APP_LIST; do
        local COUNTER=$(($COUNTER + 1))
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
            draw_ui "$COUNTER" "$COUNT"
        fi
    done
}

cleanup(){
    rm_file "$LOCK_FILE"
}
update_eta(){
    local expected_start=$(cat "$NEXT_TIME" 2>/dev/null || echo $start_time)
    local drift=$(( $start_time - $expected_start ))
    [ $drift -lt 0 ] && drift=0 
    local execution_time=$(( $end_time - $start_time ))
    echo $(( $(date +%s) + 1800 + $drift + $execution_time )) > "$NEXT_TIME" # update next time
}
start_time=$(date +%s)
if [ -e "$LOCK_FILE" ]; then
    export LOCKED=1
else
    export LOCKED=0
    echo -e "Starting fix..."
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

end_time=$(date +%s)
if [ $LOCKED -eq 1 ]; then
    echo -e "Another instance is running, exiting..."
else
    if [ $CALL_FROM_DAEMON -eq 1 ]; then
        update_eta
    else
        echo -e "\r[DONE] Fixed $COUNT apps in $(($end_time - $start_time))s.         "
    fi
fi

"$MODDIR/refresh_description.sh"