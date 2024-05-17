#!/bin/bash
version=0.1
echo mountpi version:$version

# check for required privileges
if [ "$EUID" -ne 0 ]
  then echo "Root privileges are required. Re-run as root."
  exit 1
fi

# help instructions
print_usage() {
cat << EOF
usage: ./mountpi.sh -i img_file -m mount_directory
-i	--image		(Required)	Image File
-m	--mount_dir	(Required)	Mount Directory
-u      --umount                        Unmount Image
-h	--help				Usage Menu
EOF
exit 1
}

# parse flags
while [ "$1" != "" ]; do
  case $1 in
    -i | --image )
      shift 
      IMG=$1
      ;;
    -m | --mount_dir )
      shift 
      MOUNT_DIR=$1
      ;;
    -u | --umount )
      shift
      UMOUNT=true
      ;;
    -h | --help ) 
      print_usage
      ;;
     * )
       print_usage
   esac
   shift
done


# check that both the image file and the mount directory where provided
if [ -z $IMG ] || [ -z $MOUNT_DIR ]; then
echo 'ERROR: Missing Required Argument(s)!'
print_usage
fi

# check if is unmount instruction
if [ "$UMOUNT" = true ]; then
  sudo umount $MOUNT_DIR/bootfs
  sudo umount $MOUNT_DIR/rootfs
  echo 'UNMOUNTED'
  exit 0
fi

fdisk -l $IMG
sector=$(fdisk -l $IMG | sed -n -e '/^Sector size/p' | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')
echo sector=$sector
bootfs_start=$(fdisk -l $IMG | grep "W95 FAT32 (LBA)$" | awk '{print $2}')
rootfs_start=$(fdisk -l $IMG | grep "Linux$" | awk '{print $2}')
echo bootfs_start=$bootfs_start
echo rootfs_start=$rootfs_start
bootfs_offset=$(($sector*$bootfs_start))
rootfs_offset=$(($sector*$rootfs_start))
echo bootfs_offset=$bootfs_offset
echo rootfs_offset=$rootfs_offset
bootfs_sectors=$(fdisk -l $IMG | grep "W95 FAT32 (LBA)$" | awk '{print $4}')
rootfs_sectors=$(fdisk -l $IMG | grep "Linux$" | awk '{print $4}')
echo bootfs_sectors=$bootfs_sectors
echo rootfs_sectors=$rootfs_sectors
bootfs_sizelimit=$(($sector*$bootfs_sectors))
rootfs_sizelimit=$(($sector*$rootfs_sectors))
echo bootfs_sizelimit=$bootfs_sizelimit
echo rootfs_sizelimit=$rootfs_sizelimit
mkdir -p $MOUNT_DIR/bootfs
mkdir -p $MOUNT_DIR/rootfs
mount -v -o loop,offset=$bootfs_offset,sizelimit=$bootfs_sizelimit -t vfat $IMG $MOUNT_DIR/bootfs
mount -v -o loop,offset=$rootfs_offset,sizelimit=$rootfs_sizelimit -t ext4 $IMG $MOUNT_DIR/rootfs
echo 'MOUNTED'
