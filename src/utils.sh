#!/system/bin/sh
# utils.sh

MODDIR=${0%/*}
DAEMON_PID="$MODDIR/.daemon"
PROP="$MODDIR/module.prop"
REBOOT_FLAG="$MODDIR/.reboot"
NEXT_TIME="$MODDIR/.next_time"

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
new_dir(){
    if [ ! -e "$1" ]; then
        mkdir -p "$1"
    elif [ ! -d "$1" ]; then
        echo -e "[ERROR] "$1" is not a directory."
    fi
    return 0
}

rm_file(){
    if [ -f "$1" ]; then
        rm -f "$1"
    fi
    return 0
}

rm_dir(){
    if [ -d "$1" ]; then
        rm -rf "$1"
    fi
    return 0
}

assert_failed(){
    echo "[ERROR] Assertion failed."
}

assert(){
    if [ $1 -ne 0 ]; then
        assert_failed
        exit 1
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


kill_daemon(){
    if [ -f "$DAEMON_PID" ]; then
        kill -9 $(cat "$DAEMON_PID")
        rm -f "$DAEMON_PID"
    fi
    if [ -d "$DAEMON_PID" ]; then
        rm -rf "$DAEMON_PID"
    fi
}

write_daemon_pid(){
    if [ -d "$DAEMON_PID" ]; then
        rm -rf "$DAEMON_PID"
    fi
    echo $$ > "$DAEMON_PID"
}

# ui helper
get_bar_length(){
    local current=$1
    local total=$2
    local max_width=$3
    
    if [ -z "$total" ] || [ "$total" -eq 0 ]; then
        echo "$max_width"
        return
    fi
    echo $((current * $max_width / $total))
}
repeat_string(){
    local target=$1
    local times=$2
    local output=""
    if [ "$times" -le 0 ]; then
        echo ""
        return 0
    fi
    while [ "$times" -gt 0 ]; do
        output="${output}${target}"
        times=$(($times - 1))
    done
    echo "$output"
}
draw_ui(){
    local current=$1
    local total=$2
    local failed=$3
    local max_width=15
    local bar_length="$(get_bar_length "$current" "$total" "$max_width")"
    local another_length=$(($max_width - $bar_length))
    echo "[RUNNING] [$(repeat_string "=" $bar_length)$(repeat_string "-" $another_length)] $current/$total ($failed failed.)"
}