#!/bin/bash

set -euo pipefail

# Getting filesystem block names for root and home partitions
root_dev=$(findmnt -n -o SOURCE /)
home_dev=$(findmnt -n -o SOURCE /home | grep '^/dev/')
# Find if the user uses RAID or not.
swapdev=$(swapon --show=NAME --noheadings)
kernel_parameters="zswap.enabled=1 zswap.max_pool_percent=35 zswap.compressor=lz4 tsc=reliable clocksource=tsc loglevel=3 quiet"

# Backup fstab in case the system gets screwed.
sudo cp /etc/fstab /etc/fstab.bak

### Mkinitcpio ###
echo "Editing mkinitcpio to use systemd HOOKS and faster compression and decompression for zstd."
sudo sed -i \
    -e '/^HOOKS=.*/ s/base udev/systemd/; s/keymap consolefont/sd-vconsole/' \
    -e 's/^#COMPRESSION="zstd"/COMPRESSION="zstd"/' \
    -e 's/^#COMPRESSION_OPTIONS=.*/COMPRESSION_OPTIONS=(--auto-threads=logical)/' \
    /etc/mkinitcpio.conf

echo "Updating mkinitcipo."
sudo mkinitcpio -P

### Insert kernel parameters. ###
if [[ ${gpu_drv} == "nvidia" ]]; then
    if [[ ${bootloader} == "grub" ]]; then
        echo "Updating GRUB config."
        sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 '${kernel_parameters}'"/' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg

    elif [[ ${bootloader} == "syslinux" ]]; then
        echo "Adding syslinux parameters."
        sudo sed -i '/^LABEL arch/,/^LABEL / {
      /^[[:space:]]*APPEND / s/$/ nvidia_drm.modeset=1 '${kernel_parameters}'/
  }' /boot/syslinux/syslinux.cfg

    else
        echo "Unknown bootloader: ${bootloader}. Skipping bootloader-specific steps."
    fi

    echo "Enabling PAT for better performance on Pentium III and newer CPUs, and enabling Preserve video memory after suspend."
    sudo cp "${dir}"/config/nvidia.conf /etc/modprobe.d/nvidia.conf
    echo "Enabling the services that are required to use Preserve memory after suspend."
    sudo systemctl enable nvidia-suspend nvidia-hibernate nvidia-resume

else
    # Bootloader parameters.
    if [[ ${bootloader} == "grub" ]]; then
        echo "Updating GRUB config."
        sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="'${kernel_parameters}'"/' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg

    elif [[ ${bootloader} == "syslinux" ]]; then
        echo "Adding syslinux parameters."
        sudo sed -i '/^LABEL arch/,/^LABEL / {
      /^[[:space:]]*APPEND / s/$/ '${kernel_parameters}'/
  }' /boot/syslinux/syslinux.cfg

    else
        echo "Unknown bootloader: ${bootloader}. Skipping bootloader-specific steps."
    fi
fi

### EXT4 Tweaks. ###
if [[ ${ext4_tweaks} == "y" ]]; then
    # Modify the old fstab.
    echo "Adding # before root partition to ensure kernel parameters have any effect."
    sudo sed -i '/\s\/\s/s/^/#/' /etc/fstab

    echo "Adding parameters for home partition."
    sudo sed -i '/\s\/home\s/s|ext4\s\+\S\+|ext4\t\trw,defaults,commit=20,relatime|' /etc/fstab

    # EXT4 Tweaks.
    echo "Appling EXT4-specific tweaks."
    if [[ ${ext4_fast_commit} == "y" ]]; then
        echo "Enabling fast_commit."
        sudo tune2fs -O fast_commit ${root_dev}
        sudo tune2fs -O fast_commit ${home_dev}
    else
        echo "Skipping fast_commit."
    fi

    # Bootloader steps.
    if [[ ${bootloader} == "grub" ]]; then
        echo "Adding rootflags in grub."
        sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="rootflags=rw,defaults,commit=20,noatime"/' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg

    elif [[ ${bootloader} == "syslinux" ]]; then
        echo "Adding rootflags in syslinux."
        sudo sed -i '/^LABEL arch/,/^LABEL / {
      /^[[:space:]]*APPEND / s/$/ rootflags=rw,defaults,commit=20,noatime/
  }' /boot/syslinux/syslinux.cfg

    else
        echo "Unknown bootloader: ${bootloader}. Skipping bootloader-specific steps."
    fi

else
    echo "Skipping EXT4-specific tweaks."
fi

# Modify swap options if present and handle RAID and no swap partition.
if [[ ${swapdev} == /dev/md* ]]; then
    echo "Warning: swap is on RAID device ${swapdev}. Enabling discard on swap can cause system lockups."
elif [[ ${swapdev} == "" ]]; then
    echo "No swap partition found."
else
    echo "Adding discard to swap."
    sudo sed -i '/\sswap\s/s|swap\s\+\S\+|swap\t\tdefaults,discard|' /etc/fstab
fi

### Makepkg ###
echo "Applying optimizations for makepkg and rust builds."

sudo sed -i \
    '/^RUSTFLAGS.*/ s/"$/ -C target-cpu=native -C link-arg=-z -C link-arg=pack-relative-relocs -C link-arg=-fuse-ld=mold"/' \
    /etc/makepkg.conf.d/rust.conf

sudo sed -i \
    -e '/^CFLAGS=.*/ s|-march=x86-64 -mtune=generic|-march=native|' \
    -e '/^[[:space:]]*-Wl,-z,pack-relative-relocs.*/ s/"/ -fuse-ld=mold"/' \
    -e 's/^#MAKEFLAGS.*/MAKEFLAGS="--jobs=$(nproc)"/' \
    -e '/^BUILDENV=.*/ s/!ccache/ccache/' \
    -e '/^OPTIONS=.*/ s/debug/!debug/' \
    -e '/^COMPRESSZST=.*/ s/-)$/--auto-threads=logical -)/' \
    -e "s/^PKGEXT=.*/PKGEXT='.pkg.tar.zst'/" \
    -e "s/^SRCEXT=.*/SRCEXT='.src.tar.zst'/" \
    /etc/makepkg.conf

### Configs & Service enables ###
echo "Copying I/O Scheduler rules."
sudo cp "${dir}"/config/60-ioschedulers.rules /etc/udev/rules.d/60-ioschedulers.rules

echo "Copying vm.swappiness configuration."
sudo cp "${dir}"/config/99-swappiness.conf /etc/sysctl.d/99-swappiness.conf

echo "Copying configuration to disable core dumps."
sudo cp "${dir}"/config/50-coredump.conf /etc/sysctl.d/50-coredump.conf

echo "Copying game compatibility vm.max_map_count tweak."
sudo cp "${dir}"/config/80-gamecompatibility.conf /etc/sysctl.d/80-gamecompatibility.conf

echo "Copying response time tweaks."
sudo cp "${dir}"/config/consistent-response-time-for-gaming.conf /etc/tmpfiles.d/consistent-response-time-for-gaming.conf

echo "Copying pcie latency tweaks and making a service."
sudo cp "${dir}"/config/set-pcie-latency.sh /usr/local/bin/
sudo cp "${dir}"/config/set-pcie-latency.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable set-pcie-latency.service

echo "Enabling fstrim.timer to optimize SSD performance."
sudo systemctl enable fstrim.timer

echo "Enabling systemd-oomd to protect against OOM."
sudo systemctl enable systemd-oomd.service

echo "Tweaks were successful."
exit 0
