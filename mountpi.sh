#!/bin/bash
version=0.2
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
-a  --all                 Mount all partitions
-b  --boot                Mount boot partition
-i  --image               Image File                Required
-l  --list                List Partitions
-m  --mount_dir           Mount Directory           Required
-p  --partition_index     Partition Index
-u  --umount              Unmount Image
-h  --help                Print Instructions
EOF
exit 1
}

# If no partition number provided then select the first
PARTITION_INDEX=1
BOOT_PARTITION=false

# parse flags
while [ "$1" != "" ]; do
  case $1 in
    -a | --all )
      ALL=true
      ;;    
    -b | --boot )
      BOOT_PARTITION=true
      ;;
    -i | --image )
      shift 
      IMG=$1
      ;;
    -l | --list )
      LIST=true
      ;;
    -m | --mount_dir )
      shift  
      MOUNT_DIR=$1
      ;;
    -p | --partition_index )
      shift
      PARTITION_INDEX=$1
      ;;
    -u | --umount )
      UMOUNT=true
      ;;
    -v | --verbose )
      VERBOSE=true
      ;;
    -h | --help ) 
      print_usage
      ;;
     * )
       print_usage
   esac
   shift
done

mount_partition() {
  if [ "$1" = true ]; then
    echo 'Mounting boot partition'
  else
    echo "Mounting partition $2"  
  fi

  sector=$(fdisk -l $IMG | sed -n -e '/^Sector size/p' | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')
  if [ "$1" = true ]; then
    start=$(fdisk -l $IMG | grep "W95 FAT32 (LBA)$" | awk '{print $2}')
    offset=$(($sector*$start))
    total_sectors=$(fdisk -l $IMG | grep "W95 FAT32 (LBA)$" | awk '{print $4}')
    mount_path="$MOUNT_DIR/partition_boot"
    filesystem="vfat"
  else
    start=$(fdisk -l $IMG | grep "Linux$" | head -$2 | tail -1 | awk '{print $2}')
    offset=$(($sector*$start))
    total_sectors=$(fdisk -l $IMG | grep "Linux$" | awk '{print $4}')
    mount_path="$MOUNT_DIR/partition_$2"
    filesystem="ext4"
  fi
  sizelimit=$(($sector*$total_sectors))

  if [ "$VERBOSE" = true ]; then
    echo $sector
    echo $start
    echo $offset $MOUNT_D
    echo $total_sectors
    echo $filesystem
    echo $sizelimit
  fi
      
  mkdir -p $mount_path
  mount -v -o loop,offset=$offset,sizelimit=$sizelimit -t $filesystem $IMG $mount_path  
}

if [ -z $MOUNT_DIR ]; then
  echo 'ERROR: Missing Required Argument - Mount Directory (-m)!'
  print_usage
  exit 0
fi

# check if is unmount instruction
if [ "$UMOUNT" = true ]; then
  echo "Unmounting mounts in $MOUNT_DIR directory"
  for dir in "$MOUNT_DIR"/*/; do
    if [ -d "$dir" ]; then
        sudo umount $dir && rmdir $dir
        if [ "$VERBOSE" = true ]; then
          echo "Unmounting $dir"
        fi
    fi
  done

  exit 0
fi

# check that both the image file is provided
if [ -z $IMG ]; then
  echo 'ERROR: Missing Required Argument - Image File (-i)!'
  print_usage
  exit 0
fi

if [ "$LIST" = true ]; then
  fdisk -l $IMG
  exit 0
fi


if [ "$BOOT_PARTITION" = true ] && [ $PARTITION_INDEX -gt 1 ]; then
  echo 'ERROR: Boot Flag (-b) and Partition Index (-p) are mutually exclusive.'
  print_usage
  exit 0
fi

available_ext_partitions=$(fdisk -l $IMG | grep "Linux$" | wc -l)

if [ $PARTITION_INDEX -gt $available_ext_partitions ]; then
  echo "ERROR: Only $available_ext_partitions partition(s) available. Requested partition does not exist."
  exit 0
fi

if [ "$VERBOSE" = true ]; then
  echo "Available partitions: $available_ext_partitions"
  fdisk -l $IMG
fi

if [ "$ALL" = true ]; then
  mount_partition true 1
  for ((i = 1; i <= available_ext_partitions; i++)); do
    mount_partition false $i
  done

else
  mount_partition $BOOT_PARTITION $PARTITION_INDEX
fi


