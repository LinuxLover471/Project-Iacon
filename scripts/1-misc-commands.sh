#!/bin/bash

set -euo pipefail

function setup_ananicy_cpp() {
  echo "Enabling ananicy-cpp and setting it's configuration"
  sudo systemctl enable ananicy-cpp.service
  sudo cp -r "${dir}"/ananicy-rules/* /etc/ananicy.d/
}

function setup_gamemode() {
  echo "Adding ${user} to gamemode user group."
  sudo usermod -aG gamemode ${user}
  echo "Setting up gamemode.ini for better niceness."
  sudo cp "${dir}"/config/gamemode.ini /etc/gamemode.ini
}

echo "Setting up NTP, automatic network time setup."
sudo timedatectl set-ntp true

echo "Setting up cpupower for to set schedutil governor as default."
sudo systemctl enable cpupower
sudo sed -i "s/^#GOVERNOR.*/GOVERNOR='schedutil'/" /etc/default/cpupower-service.conf

echo "setting up nftables."
sudo systemctl enable nftables

if [[ ${ananicyornot} == "ananicy-cpp" ]]; then
  setup_ananicy_cpp

elif [[ ${ananicyornot} == "gamemode" ]]; then
  setup_gamemode

else
  setup_ananicy_cpp
  setup_gamemode
fi

echo "Misc optimizations performed successfully."
exit 0
