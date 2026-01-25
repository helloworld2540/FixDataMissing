#!/system/bin/sh
# install.sh

SKIP_UNZIP=1
unzip -d "$MODPATH" -o "$ZIPFILE"
chmod 777 "$MODPATH"/*.sh