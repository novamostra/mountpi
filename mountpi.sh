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
-n	--number			Index of Image
-u 	--umount			Unmount Image
-h	--help				Usage Menu
EOF
exit 1
}

NUMBER=1

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
    -n | --number )
      shift
      NUMBER=$1
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
  sudo umount $MOUNT_DIR
  echo 'UNMOUNTED'
  exit 0
fi

fdisk -l $IMG
sector=$(fdisk -l $IMG | sed -n -e '/^Sector size/p' | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')
echo sector $sector
start=$(fdisk -l $IMG | grep "Linux$" | head -$NUMBER | tail -1 | awk '{print $2}')
echo start $start
offset=$(($sector*$start))
echo offset $offset
mkdir -p $MOUNT_DIR
mount -v -o offset=$offset -t ext4 $IMG $MOUNT_DIR
echo 'MOUNTED'
