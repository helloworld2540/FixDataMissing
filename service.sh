#!/system/bin/sh
# service.sh

# tools variable
MODDIR=${0%/*}
FLAG_SUCCESS="$MODDIR/.success"
FLAG_FAIL="$MODDIR/.fail"
DAEMON="$MODDIR/.daemon"

# system variable
ROOT="/storage/emulated/0"
ANDROID="$ROOT/Android"

# io helper
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
assert_failed(){
    new_file "$FLAG_FAIL"
    rm_file "$FLAG_SUCCESS"
    return 1
}
assert(){
    if [ $1 -ne 0 ]; then
        assert_failed
        return 1
    fi
    return 0
}
assert_exists(){
    if [ -e "$1" ]; then
        return 0
    else
        echo -e "[ERROR] "$1" does not exist."
        assert_failed
        return 1
    fi
}
assert_file(){
    if [ -f "$1" ]; then
        return 0
    else
        echo -e "[ERROR] "$1" is not a file."
        assert_failed
        return 1
    fi
}
assert_dir(){
    if [ -d "$1" ]; then
        return 0
    else
        echo -e "[ERROR] "$1" is not a directory."
        assert_failed
        return 1
    fi
}

# android boot helper
wait_until_login(){
    while true; do
		if [ -d "/storage/emulated/0/Android/data" ]; then
			break
		fi
		sleep 3
	done
	while ! touch /storage/emulated/0/Android/data/.WriteTest; do
		sleep 3
	done
	rm -f /storage/emulated/0/Android/data/.WriteTest
    sleep 1 # wait for system ready
}
# main
main(){
    assert_dir "$ANDROID/data" || return 1
    assert_dir "$ANDROID/obb" || return 1
    assert_dir "$ANDROID/media" || return 1

    # get app list that user install
    APP_LIST=$(pm list packages -3)
    assert $? || return 1

    for app in $APP_LIST; do
        app=${app#package:} # remove prefix
        DATA="$ANDROID/data/$app"
        OBB="$ANDROID/obb/$app"
        MEDIA="$ANDROID/media/$app"
        assert_dir "$DATA" || return 1
        assert_dir "$OBB" || return 1
        assert_dir "$MEDIA" || return 1
    done

    # all assert passed
    new_file "$FLAG_SUCCESS" 
    rm_file "$FLAG_FAIL"
}

wait_until_login
echo $$ > "$DAEMON" # kernel will create file automatically, so no need to create it manually
while true; do
    main
    source "$MODDIR/refresh_description.sh"
    sleep 300 # 5 min
done