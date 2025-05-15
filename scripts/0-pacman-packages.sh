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

echo "Installing reflector"
sudo pacman -S --needed reflector
echo "Copying pacman.conf for multilib."
sudo cp -av "$dir"/config/pacman.conf /etc/pacman.conf
echo "Running reflector for best download performance"
sudo reflector -n 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist --download-timeout=20
echo "Forcing a mirror refresh."
sudo pacman -Syy
echo "Installing packages."
sudo pacman -S --needed --noconfirm nftables alsa-utils base-devel git cpupower ccache $ananicycpporgamemode mold $linux_header $vulkan_pkg
echo "Important packages installed successfully."
exit 0
