#!/system/bin/sh
# install.sh

SKIP_UNZIP=1
unzip -d "$MODPATH" -o "$ZIPFILE" -x "install.sh" -x "changelog.md"
chmod 777 "$MODPATH"/*.sh
touch "$MODPATH"/".reboot"
if [ -f "$MODDIR/.daemon" ]; then
    echo -e "killing daemon..."
    kill -9 $(cat "$MODDIR/.daemon")
    rm -f "$MODDIR/.daemon"
fi