#!/bin/bash
# Beginning of literal hell for me.

if [[ "$gpu_drv" == "nvidia" ]]; then
    if [[ "$nvidia_version" == "nvidia" ]]; then
        echo "Installing default nvidia driver and it's components."
        sudo pacman -S --noconfirm --needed nvidia nvidia-utils lib32-nvidia-utils libxnvctrl
        "$aur_hlp" --noconfirm lib32-libxnvctrl
    elif [[ "$nvidia_version" == "nvidia-open" ]]; then
        echo "Installing nvidia-open driver and it's components."
        sudo pacman -S --noconfirm --needed nvidia-open nvidia-utils lib32-nvidia-utils libxnvctrl
        "$aur_hlp" --noconfirm lib32-libxnvctrl
    elif [[ "$nvidia_version" == "nvidia-dkms" ]]; then
        echo "Installing nvidia-dkms driver and it's components."
        sudo pacman -S --noconfirm --needed nvidia-dkms nvidia-utils lib32-nvidia-utils libxnvctrl
        "$aur_hlp" --noconfirm lib32-libxnvctrl
    elif [[ "$nvidia_version" == "470xx" ]]; then
        echo "Installing 470xx nvidia driver and it's components."
        "$aur_hlp" -S --noconfirm nvidia-470xx-dkms nvidia-470xx-utils lib32-nvidia-470xx-utils nvidia-470xx-settings libxnvctrl-470xx lib32-libxnvctrl-470xx
    elif [[ "$nvidia_version" == "390xx" ]]; then
        echo "Installing 390xx nvidia driver and it's components."
        "$aur_hlp" -S --noconfirm nvidia-390xx-dkms nvidia-390xx-utils lib32-nvidia-390xx-utils nvidia-390xx-settings libxnvctrl-390xx lib32-libxnvctrl-390xx
    fi

    echo "Copying mkinitcpio configuration to setup up the driver and get better boot times."
    sudo cp -av "$dir"/config/mkinitcpio.conf /etc/mkinitcpio.conf
    echo "Updating initramfs."
    sudo mkinitcpio -P

# Beginning of AMD driver section.

elif [[ "$gpu_drv" == "amd" ]]; then
    echo "Installing mesa and lib32-mesa."
    sudo pacman -S --needed --noconfirm mesa lib32-mesa
    if [[ "$vulkansupport" == "yes" || "$vulkansupport" == "y" ]]; then
        sudo pacman -S --noconfirm --needed vulkan-radeon lib32-vulkan-radeon
    else
        echo "Will not install vulkan support."
    fi

#  Beginning of Intel driver section.

elif [[ "$gpu_drv" == "intel" ]]; then
    echo "Installing mesa and lib32-mesa."
    sudo pacman -S --needed --noconfirm mesa lib32-mesa
    if [[ "$vulkansupport" == "yes" || "$vulkansupport" == "y" ]]; then
        sudo pacman -S --noconfirm --needed vulkan-intel lib32-vulkan-intel
    else
        echo "Will not install vulkan support."
    fi
fi
exit 0
