#!/system/bin/sh
set -e

# check if busybox installed
BUSYBOX=/system/xbin/strings

if [ ! -e "$BUSYBOX" ] ; then
    echo "busybox in not installed"
    echo "4pda users should install busybox from"
    echo "http://4pda.ru/forum/index.php?showtopic=187868"
    echo "install apk, then run, then press 'install' in app"
    exit 1
fi

alias dd='busybox dd'

FRP=$(getprop ro.frp.pst)
FRPSIZE=$(wc -c $(getprop ro.frp.pst | awk '{print $1}') | awk '{print $1}')

if [ -z "$FRP" ] || [ -z "$FRPSIZE"] ; then
    echo "FRP not found, or FRP length is invalid"
    exit 1
fi

echo "backup original FRP patririon $FRP"
echo "IMPORTANT !!!!!"
echo "store this backup to PC *before* oem unlock via fastboot"

if ! dd if="$FRP" of=/sdcard/frp.img 2> /dev/null ; then
    echo "Cannot make backup, exit"
fi

echo "prepare new FRP file"
cp /sdcard/frp.img /sdcard/frp_tmp.img
# extract old digest
dd if=/sdcard/frp.img of=/sdcard/digest.img bs=1 count=32 2> /dev/null
# replace digest with 32 zero bytes
for i in $(seq 0 31) ; do echo -e '\x00' | dd of=/sdcard/frp_tmp.img bs=1 count=1 seek=$i conv=notrunc 2> /dev/null ; done
DIGEST=$(sha256sum /sdcard/frp_tmp.img | awk '{print $1}')
echo "Locked digest is $DIGEST"

# set unlock flag in FRP
echo -ne '\x01' | dd of=/sdcard/frp_tmp.img bs=1 count=1 seek=$((FRPSIZE - 1)) conv=notrunc 2> /dev/null
# re-calculate digest
DIGEST=$(sha256sum /sdcard/frp_tmp.img | awk '{print $1}')
echo "Unlocked digest is $DIGEST"

TMPFILE=$(mktemp -p /sdcard XXXXXXXX)
for i in $(seq 1 2 64) ; do
    echo -n "\x""$(expr substr $DIGEST $i 2)" >> "$TMPFILE"
done

# place unlocked digest back to FRP
dd if="$TMPFILE" of="/sdcard/frp_tmp.img" bs=1 count=32 conv=notrunc 2> /dev/null
rm -f "$TMPFILE"

# flash unlocked FRP back
if ! dd if=/sdcard/frp_tmp.img of="$FRP" ; then 
    echo "FRP is read-only"
    echo "Unlock failed"
    exit 1
fi

echo "Done. FRP is unlocked"
echo "Now you can reboot bootloader"
echo "Then run 'fasboot oem unlock'"

