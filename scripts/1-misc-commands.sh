#!/bin/bash

set -euo pipefail

echo "Setting up NTP, automatic network time setup."
sudo timedatectl set-ntp true

echo "Setting up cpupower for to set schedutil governor as default."
sudo systemctl enable cpupower
sudo cp -v "$dir"/config/cpupower /etc/default/cpupower

echo "setting up nftables."
sudo systemctl enable nftables

if [[ "$ananicyornot" == "ananicy-cpp" ]]; then
  echo "Enabling ananicy-cpp and setting it's configuration"
  sudo systemctl enable ananicy-cpp.service
  sudo cp -v "$dir"/Ananicy/ananicy.d/* /etc/ananicy.d/
elif [[ "$ananicyornot" == "gamemode" ]]; then
  echo "Adding $user to gamemode user group."
  sudo usermod -aG gamemode "$user"
  echo "Setting up gamemode.ini for better niceness."
  sudo cp -v "$dir"/config/gamemode.ini /etc/gamemode.ini
else
  # Ananicy-cpp.
  echo "Enabling ananicy-cpp and copying rules."
  sudo systemctl enable ananicy-cpp.service
  sudo cp -v "$dir"/Ananicy/ananicy.d/* /etc/ananicy.d/
  # Gamemode.
  echo "Adding $user to gamemode user group."
  sudo usermod -aG gamemode "$user"
  echo "Setting up gamemode.ini for better niceness."
  sudo cp -v "$dir"/config/gamemode.ini /etc/gamemode.ini
fi

echo "Misc optimizations performed successfully."
exit 0
