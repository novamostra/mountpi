# mountpi
Automated way to mount/umount a raspberry pi image under linux.

## Installation
Simply copy the repository to your computer and make the script executable
```bash
git clone https://github.com/novamostra/mountpi
sudo chmod +x mountpi/mountpi.sh
```

## Usage Instructions
```bash
sudo ./mountpi/mountpi.sh -i image_file.img -m existing_mount_directory
```

![mountpi.sh usage](images/mountpi.png?raw=true "mountpi.sh usage")

Read how it works at [novamostra.com](https://novamostra.com/2021/04/11/mountpi)
