# mountpi
Automated way to mount/umount a raspberry pi image under linux.

![mountpi.sh usage](images/mountpi.png?raw=true "mountpi.sh usage")

## Installation
Simply copy the repository to your computer and make the script executable
```bash
git clone https://github.com/novamostra/mountpi
sudo chmod +x mountpi/mountpi.sh
```

## v0.2 Changelog
+ **Added** - List image partitions usign the list flag (-l) 
+ **Added**  - Mount the boot partition using the boot flag (-b)
+ **Added**  - Mount any ext4 partition by specifying it's index (-p)
+ **Added**  - Mount all image's partitions using all flag (-a)
+ **Added**  - More information during script execution using verbose flag (-v)
* **Fixed** - Unmounting no longer requires the image name, only the mount directory.
* **Fixed** - Flags and parameters handling optimization

## Usage Instructions

1) Clone the Git Repository
```bash
git clone https://github.com/novamostra/mountpi
```
2) Add Execution Permission
```bash
sudo chmod +x mountpi/mountpi.sh
```

## Functionality
- List image partitions:

```
sudo ./mountpi -i path/to/raspberry.img -l
```

- Mount all the partitions of an image to a specified directory:

```
sudo ./mountpi -i path/to/raspberry.img -m path/to/mnt/directory -a
```

This command will create in `path/to/mnt/directory` one subdirectory for each partition. For the boot partition the subdirectory will be named `partition_boot` while for each `ext4` partition an `partition_[parition_index]`  subdirectory will be created.

- To unmount all partitions run:

```
sudo ./mountpi -u -m path/to/mnt/directory
```

This will unmount all the partitions and remove the directories.

- Mount only the boot partition:

```
sudo ./mountpi -i path/to/raspberry.img -m path/to/mnt/directory -b
```

- Mount a specific ext4 partition:

```
sudo ./mountpi -i path/to/raspberry.img -m path/to/mnt/directory -p 2
```

This will mount the second ext4 partition of the image. If `-p` parameter is omitted then it defaults to 1, so the first ext4 partition will be mounted.

## Read more
Read more about how it works at [novamostra.com](https://novamostra.com/2021/04/11/mountpi) and [here about v0.2](https://novamostra.com/2025/08/17/mountpi-0-2-released/)

## Contributions
Special thanks to [@pevsonic](https://github.com/pevsonic) and [RobertLauferElektrobit](https://github.com/RobertLauferElektrobit) for their valuable contributions to the code.
