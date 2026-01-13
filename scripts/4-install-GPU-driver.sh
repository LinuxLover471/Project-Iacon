#!/bin/bash

set -euo pipefail

function check_and_install_vulkan() {
  if [[ ${vulkansupport} == "y" ]]; then
    sudo pacman -S --noconfirm --needed vulkan-icd-loader "$@"
  else
    echo "Will not install vulkan support."
  fi
}

function install_gpu_pkg() {
  sudo pacman -S --noconfirm --needed ${gpu_pkg} "$@"
}

# Beginning of NVIDIA proprietary driver section.

if [[ ${gpu_drv} == "nvidia" ]]; then
  echo "Installing ${nvidia_version} driver and it's components."
  echo "Copying mkinitcpio.conf to setup the driver."
  sudo cp -v "${dir}"/config/mkinitcpio-nvidia.conf /etc/mkinitcpio.conf
  sudo pacman -S linux-firmware-nvidia # Install firmware to ensure driver works properly.
  if [[ ${nvidia_version} == "nvidia" ]]; then
    install_gpu_pkg
  elif [[ ${nvidia_version} == "nvidia-open" ]]; then
    install_gpu_pkg
  elif [[ ${nvidia_version} == "nvidia-dkms" ]]; then
    install_gpu_pkg
  elif [[ ${nvidia_version} == "470xx" ]]; then
    aur sync --noconfirm ${gpu_pkg}
    install_gpu_pkg
  elif [[ ${nvidia_version} == "390xx" ]]; then
    aur sync --noconfirm ${gpu_pkg}
    install_gpu_pkg
  fi
  check_and_install_vulkan

# Nouveau section.

elif [[ ${gpu_drv} == "nouveau" ]]; then
  echo "Installing Mesa."
  install_gpu_pkg linux-firmware-nvidia
  check_and_install_vulkan vulkan-nouveau

# Beginning of AMD driver section.

elif [[ ${gpu_drv} == "amd" ]]; then
  echo "Installing Mesa."
  install_gpu_pkg linux-firmware-amdgpu
  check_and_install_vulkan vulkan-radeon

#  Beginning of Intel driver section.

elif [[ ${gpu_drv} == "intel" ]]; then
  echo "Installing Mesa."
  install_gpu_pkg linux-firmware-intel
  check_and_install_vulkan vulkan-intel
fi
exit 0
