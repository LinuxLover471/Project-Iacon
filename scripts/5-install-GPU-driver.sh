#!/bin/bash

set -euo pipefail

function check_and_install_vulkan() {
    if [[ ${vulkansupport} == "y" ]]; then
        sudo pacman -S --noconfirm --needed vulkan-icd-loader "$@"
    else
        echo "==> Will not install vulkan support."
    fi
}

function install_gpu_pkg() {
    sudo pacman -S --noconfirm --needed ${gpu_pkg} "$@"
}

# Beginning of NVIDIA proprietary driver section.

if [[ ${gpu_drv} == "nvidia" ]]; then
    echo "==> Installing ${nvidia_version} driver and it's components."
    echo "==> Adding nvidia modules to mkinitcpio.conf to setup the driver."
    sudo sed -i \
        -e "/^MODULES.*/ s/)$/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/" \
        -e '/^HOOKS=.*/ s/ kms//' \
        /etc/mkinitcpio.conf
    case "${nvidia_version}" in
    "nvidia" | "nvidia-open" | "nvidia-dkms")
        install_gpu_pkg linux-firmware-nvidia
        ;;
    "580xx" | "470xx" | "390xx")
        aur sync --noconfirm ${gpu_pkg}
        install_gpu_pkg linux-firmware-nvidia
        ;;
    esac
    check_and_install_vulkan

    echo "==> Enabling PAT and Preserve Memory after suspend."
    sudo cp "${dir}"/config/nvidia.conf /etc/modprobe.d/nvidia.conf
    echo "==> Enabling services required for Preserve Memory after suspend."
    sudo systemctl enable nvidia-suspend nvidia-hibernate nvidia-resume

# Nouveau section.

elif [[ ${gpu_drv} == "nouveau" ]]; then
    echo "==> Installing Mesa."
    install_gpu_pkg linux-firmware-nvidia
    check_and_install_vulkan vulkan-nouveau

# Beginning of AMD driver section.

elif [[ ${gpu_drv} == "amd" ]]; then
    echo "==> Installing Mesa."
    install_gpu_pkg linux-firmware-amdgpu
    check_and_install_vulkan vulkan-radeon

#  Beginning of Intel driver section.

elif [[ ${gpu_drv} == "intel" ]]; then
    echo "==> Installing Mesa."
    install_gpu_pkg linux-firmware-intel
    check_and_install_vulkan vulkan-intel
fi
exit 0
