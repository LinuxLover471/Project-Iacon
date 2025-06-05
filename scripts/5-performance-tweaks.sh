#!/bin/bash
# Getting filesystem block names for root and home partitions
root_dev=$(findmnt -n -o SOURCE /)
home_dev=$(findmnt -n -o SOURCE /home | grep '^/dev/')
# Find if the user uses RAID or not.
swapdev=$(swapon --show=NAME --noheadings)

# Backup fstab in case the system gets screwed.
sudo cp /etc/fstab /etc/fstab.bak

if [[ "$bootloader" == "grub" ]]; then
    echo "Updating GRUB config."
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia_drm.modeset=1 zswap.enabled=1 rootflags=rw,defaults,commit=60,noatime usbcore.autosuspend=-1 zswap.max_pool_percent=35 zswap.accept_threshold_percent=95"/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
elif [[ "$bootloader" == "syslinux" ]]; then
    echo "Adding syslinux parameters."
sudo sed -i '/^LABEL arch/,/^LABEL / {
    /^APPEND / s/$/ nvidia-drm.modeset=1 rootflags=rw,defaults,commit=60,noatime usbcore.autosuspend=-1 quiet loglevel=3/
}' /boot/syslinux/syslinux.cfg
else
    echo "Unknown bootloader: $bootloader. Skipping bootloader-specific steps."
fi

# Modify the old fstab.
# Comment out the root (/) line to make sure the rw options in the bootloader kernel parameters work.
echo "Removing # before root partition to ensure kernel parameters have any effect."
sudo sed -i '/\s\/\s/s/^/#/' /etc/fstab

# Modify /home mount options
echo "Adding parameters for home partition."
sudo sed -i '/\s\/home\s/s|ext4\s\+\S\+|ext4\t\trw,defaults,commit=60,relatime,noauto,x-systemd.automount|' /etc/fstab

# Modify swap options if present and handle RAID and no swap partition.
if [[ $swapdev == /dev/md* ]]; then
    echo "Warning: swap is on RAID device $swapdev. Enabling discard on swap can cause system lockups."
elif [[ "$swapdev" == "" ]]; then
    echo "No swap partition found."
else
    echo "Adding discard to swap."
    sudo sed -i '/\sswap\s/s|swap\s\+\S\+|swap\t\tdefaults,discard|' /etc/fstab
fi


echo "Enabling fast_commit."
sudo tune2fs -O fast_commit "$root_dev"
sudo tune2fs -O fast_commit "$home_dev"

echo "Copying I/O Scheduler rules."
sudo cp -av "$dir"/config/60-ioschedulers.rules /etc/udev/rules.d/60-ioschedulers.rules

echo "Copying vm.swappiness configuration."
sudo cp -av "$dir"/config/99-swappiness.conf /etc/sysctl.d/99-swappiness.conf

echo "Copying configuration to disable core dumps."
sudo cp -av "$dir"/config/50-coredump.conf /etc/sysctl.d/50-coredump.conf

echo "Enabling fstrim.timer to optimize SSD performance."
sudo systemctl enable fstrim.timer

echo "Enabling systemd-oomd to protect against OOM."
sudo systemctl enable systemd-oomd.service

echo "Tweaks were successful."
exit 0
