#!/system/bin/sh
# install.sh

SKIP_UNZIP=1
unzip -d "$MODPATH" -o "$ZIPFILE" -x "install.sh" "changelog.md"
chmod 777 "$MODPATH"/*.sh
touch "$MODPATH"/".reboot"