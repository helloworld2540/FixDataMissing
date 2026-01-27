#!/system/bin/sh
# refresh_description.sh

# tools variable
MODDIR=${0%/*}
PROP="$MODDIR/module.prop"
FLAG_SUCCESS=$MODDIR/.success
FLAG_FAIL=$MODDIR/.fail

# original description
ORIDES="Fix Android/data, Android/obb, Android/media is missing."

if [ -e "$MODDIR/.integrity_fail" ]; then
    NEW_DES="[⚠️ Module integrity compromised. Reinstall recommended.] $ORIDES"
elif [ -e "$FLAG_SUCCESS" ]; then
    NEW_DES="[✅ Normal, no need to fix.] $ORIDES"
elif [ -e "$FLAG_FAIL" ]; then
    NEW_DES="[❌ Need to fix, Click action button.] $ORIDES"
else
    NEW_DES="[🤔 A reboot is pending.] $ORIDES"
fi

sed -i "s#^description=.*#description=$NEW_DES#" "$PROP"