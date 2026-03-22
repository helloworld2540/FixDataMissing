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
    local FAILED=0
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

        # create Android/data
        new_dir "$DATA"
        if [ $? -eq 0 ]; then
            chmod 777 "$DATA"
        else
            [ $TMP_FAILED -eq $FAILED ] && FAILED=$(($FAILED + 1))
        fi

        # create Android/obb
        new_dir "$OBB"
        if [ $? -eq 0 ]; then
            chmod 777 "$OBB"
        else
            [ $TMP_FAILED -eq $FAILED ] && FAILED=$(($FAILED + 1))
        fi

        # create Android/media
        new_dir "$MEDIA"
        if [ $? -eq 0 ]; then
            chmod 777 "$MEDIA"
        else
            [ $TMP_FAILED -eq $FAILED ] && FAILED=$(($FAILED + 1))
        fi
        
        if [ $CALL_FROM_DAEMON -eq 0 ]; then
            draw_ui "$COUNTER" "$COUNT" "$FAILED"
        fi
    done

    
}

local start_time=$(date +%s)
main
local end_time=$(date +%s)
if [ $CALL_FROM_DAEMON -eq 1 ]; then
    echo $(($(date +%s) + 1800 + $(($end_time - $start_time)))) > "$NEXT_TIME" # update next time
else
    echo -e "\r[DONE] $FAILED fail in $COUNT apps in $(($end_time - $start_time))s.         "
fi
"$MODDIR/refresh_description.sh"