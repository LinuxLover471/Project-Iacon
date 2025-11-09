#!/bin/bash

# Check if we're running as root or not

if [[ "$USER" == "root" ]]; then
  # Checking if the user is root and if they are, do they have sudo installed?
  if ! command -v sudo >/dev/null 2>&1; then
    echo "You're logged in as root, but sudo is not installed. Installing sudo."
    pacman -S --needed sudo
  else
    echo "sudo is already installed."
  fi
else
  # If we're not root, use `su` to switch to root
  echo "You're not root. Using su to install sudo..."
  su -c "pacman -S --needed sudo"
fi

echo "Enabling Color+ILoveCandy! Because everyone deserves some color and eye candy in their package manager!"
sudo sed -i \
  -e '/^#Color/s/^#//' \
  -e '/^Color$/a ILoveCandy' \
  /etc/pacman.conf

echo "Forcing a mirror refresh and making sure the system is up to date."
sudo pacman -Syyu
echo "Installing packages."
sudo pacman -S --needed --noconfirm nftables alsa-utils base-devel git cpupower ccache $ananicycpporgamemode $linux_header
echo "Important packages installed successfully."
exit 0
