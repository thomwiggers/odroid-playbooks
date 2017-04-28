#!/bin/bash

set -e

TARGET=/dev/mmcblk0
PARTITION="${TARGET}p1"
IMAGE_URL=http://archlinuxarm.org/os/ArchLinuxARM-odroid-c2-latest.tar.gz
IMAGE_FILE=ArchLinuxARM-odroid-c2-latest.tar.gz

if [[ "$(id -u)" != "0" ]]; then
    echo "You need to run me as root!";
    exit 1
fi

if [[ ! -f "${IMAGE_FILE}" ]]; then
    echo "Downloading image"
    wget $IMAGE_URL
fi

echo "THIS WILL DESTROY THE FILESYSTEM ON $TARGET!"
echo "Do you want to continue?"
read

echo "Zeroing beginning of SD card"
dd if="/dev/zero" of="$TARGET" bs=1M count=8

echo "Partitioning SD card"
sfdisk --wipe always "$TARGET" <<DOC 
label:  dos
$PARTITION: type=83
DOC

echo "Creating file system"
mkfs.ext4 -O '^metadata_csum,^64bit' "$PARTITION"

echo "Mounting SD card"
mkdir -p sdcard
mount $PARTITION sdcard

echo "Extracting file system"
bsdtar -xpf "$IMAGE_FILE" -C sdcard

echo "flash bootloader"
cd sdcard/boot
./sd_fusing.sh "$TARGET"
cd ../../

echo "Syncing filesystems"
sync

echo "Unmounting"
umount sdcard

echo "Done"
