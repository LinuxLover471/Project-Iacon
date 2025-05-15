#!/bin/bash
# Getting filesystem types for root and home partitions
root_dev=$(findmnt -n -o SOURCE /)
home_dev=$(findmnt -n -o SOURCE /home | grep '^/dev/')


# Backup fstab in case the system gets screwed.
sudo cp /etc/fstab /etc/fstab.bak

if [[ "$bootloader" == "grub" ]]; then
    echo "Updating GRUB config."
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia_drm.modeset=1 zswap.enabled=1 rootflags=rw,defaults,commit=60,noatime usbcore.autosuspend=-1 zswap.max_pool_percent=35 zswap.accept_threshold_percent=95"/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
elif [[ "$bootloader" == "syslinux" ]]; then
    echo "Adding syslinux parameters."
    sudo sed -i '/^APPEND / s|$| loglevel=3 quiet nowatchdog nvidia_drm.modeset=1 zswap.enabled=1 rootflags=rw,defaults,commit=60,noatime usbcore.autosuspend=-1 zswap.max_pool_percent=35 zswap.accept_threshold_percent=95|' /boot/syslinux/syslinux.cfg
else
    echo "Unknown bootloader: $bootloader. Skipping bootloader-specific steps."
fi

# Build new fstab
# Comment out the root (/) line
sudo sed -i '/\s\/\s/s/^/#/' /etc/fstab

# Modify /home mount options
sudo sed -i '/\s\/home\s/s|ext4\s\+\S\+|ext4\t\trw,defaults,commit=60,noatime,noauto,x-systemd.automount|' /etc/fstab

# Modify swap options if present
sudo sed -i '/\sswap\s/s|swap\s\+\S\+|swap\t\tdefaults,discard|' /etc/fstab

echo "Masking systemd-fsck-root service to stop interfering with fstab."
sudo systemctl mask systemd-fsck-root

echo "Enabling fast_commit."
sudo tune2fs -O fast_commit "$root_dev"
sudo tune2fs -O fast_commit "$home_dev"

echo "Copying I/O Scheduler rules."
sudo cp -av "$dir"/60-ioschedulers.rules /etc/udev/rules.d/60-ioschedulers.rules

echo "Triggering udevadm to apply I/O Scheduler changes."
sudo udevadm trigger

echo "Copying vm.swappiness configuration."
sudo cp -av "$dir"/99-swappiness.conf /etc/sysctl.d/99-swappiness.conf

echo "Copying configuration to disable core dumps."
sudo cp -av "$dir"/50-coredump.conf /etc/sysctl.d/50-coredump.conf

echo "Enabling fstrim.timer to optimize SSD performance."
sudo systemctl enable fstrim.timer

echo "Enabling systemd-oomd to protect against OOM."
sudo systemctl enable systemd-oomd.service

echo "Tweaks were successful."
exit 0
