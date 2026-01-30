#!/system/bin/sh
# action.sh

# tools variable
MODDIR=${0%/*}
FLAG_SUCCESS="$MODDIR/.success"
FLAG_FAIL="$MODDIR/.fail"
FLAG_INTEGRITY_FAIL="$MODDIR/.integrity_fail"
DAEMON="$MODDIR/.daemon"

# system variable
ROOT=/storage/emulated/0
ANDROID="$ROOT/Android"

# io helper
new_dir(){
    if [ ! -e "$1" ]; then
        mkdir -p "$1"
    elif [ ! -d "$1" ]; then
        echo -e "[ERROR] "$1" is not a directory."
        return 1
    fi
    return 0
}

new_file(){
    if [ ! -e "$1" ]; then
        touch "$1"
    elif [ ! -f "$1" ]; then
        echo -e "[ERROR] "$1" is not a file."
    elif [ -w "$1" ]; then
        echo "" > "$1"
    fi
    return 0
}

rm_file(){
    if [ -f "$1" ]; then
        rm -f "$1"
    fi
    return 0
}

# assert helper
assert(){
    if [ $1 -ne 0 ]; then
        echo -e "[ERROR] Assert failed ($1)"
        exit $1
    fi
}

# main
main(){
    # makesure Android/data, Android/obb, Android/media is exist
    new_dir "$ANDROID/data"
    assert $?
    new_dir "$ANDROID/obb"
    assert $?
    new_dir "$ANDROID/media"
    assert $?

    # get app list that installed
    APP_LIST=$(pm list packages)
    assert $?

    COUNT=$(echo "$APP_LIST" | wc -l)
    FAILED=0
    for app in $APP_LIST; do
        TMP_FAILED=$FAILED
        app=${app#package:} # remove prefix
        if [ -z "$app" ]; then # skip empty line
            continue
        fi
        DATA="$ANDROID/data/$app"
        OBB="$ANDROID/obb/$app"
        MEDIA="$ANDROID/media/$app"

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
    done

    echo -e "[DONE] $FAILED fail in $COUNT apps."
}

if [ -e "$FLAG_INTEGRITY_FAIL" ]; then
    echo -e "[ERROR] Module integrity check failed. Please reinstall the module."
    exit 1
fi

main
if [ -e "$DAEMON" ]; then
    echo -e "[SYNC] Restarting daemon..."
    kill -9 $(cat "$DAEMON")
    rm -f "$DAEMON" # remove old daemon file
    echo -e "[WAIT] Waiting for daemon..."
    "$MODDIR"/service.sh &
    while [ ! -e "$DAEMON" ]; do
        sleep 1
    done
    sleep 1 # wait for description refresh
    echo -e "[Ok] Daemon restarted."
fi
