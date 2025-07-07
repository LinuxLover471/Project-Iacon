#!/bin/bash
# Beginning of literal hell for me.

if [[ "$gpu_drv" == "nvidia" ]]; then
    echo "Copying mkinitcpio.conf to setup the driver."
    sudo cp -v "$dir"/config/mkinitcpio-nvidia.conf /etc/mkinitcpio.conf
    if [[ "$nvidia_version" == "nvidia" ]]; then
        echo "Installing default nvidia driver and it's components."
        sudo pacman -S --noconfirm --needed $gpu_pkg
    elif [[ "$nvidia_version" == "nvidia-open" ]]; then
        echo "Installing nvidia-open driver and it's components."
        sudo pacman -S --noconfirm --needed $gpu_pkg
    elif [[ "$nvidia_version" == "nvidia-dkms" ]]; then
        echo "Installing nvidia-dkms driver and it's components."
        sudo pacman -S --noconfirm --needed $gpu_pkg
    elif [[ "$nvidia_version" == "470xx" ]]; then
        echo "Installing 470xx nvidia driver and it's components."
        trizen -S --noconfirm $gpu_pkg --needed
    elif [[ "$nvidia_version" == "390xx" ]]; then
        echo "Installing 390xx nvidia driver and it's components."
        trizen -S --noconfirm $gpu_pkg
    fi

# Beginning of AMD driver section.

elif [[ "$gpu_drv" == "amd" ]]; then
    echo "Installing mesa."
    sudo pacman -S --needed --noconfirm $gpu_pkg
    echo "Copying mkinitcpio for faster boot times."
    sudo cp -v "$dir"/config/mkinitcpio-other-gpu.conf /etc/mkinitcpio.conf
    echo "Updating initramfs."
    sudo mkinitcpio -P
    if [[ "$vulkansupport" == "yes" || "$vulkansupport" == "y" ]]; then
        sudo pacman -S --noconfirm --needed vulkan-radeon
    else
        echo "Will not install vulkan support."
    fi

#  Beginning of Intel driver section.

elif [[ "$gpu_drv" == "intel" ]]; then
    echo "Installing mesa."
    sudo pacman -S --needed --noconfirm $gpu_pkg
    echo "Copying mkinitcpio for faster boot times."
    sudo cp -v "$dir"/config/mkinitcpio-other-gpu.conf /etc/mkinitcpio.conf
    echo "Updating initramfs."
    sudo mkinitcpio -P
    if [[ "$vulkansupport" == "yes" || "$vulkansupport" == "y" ]]; then
        sudo pacman -S --noconfirm --needed vulkan-intel
    else
        echo "Will not install vulkan support."
    fi
fi
exit 0
