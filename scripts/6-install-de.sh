#!/bin/bash
if [[ "$de_type" == "1" ]]; then
    if [[ "$kdetype" == "1" ]]; then
        echo "Installing minimal version of KDE, with a few packages."
        sudo pacman -S --needed --noconfirm "$de_pkg"
        sudo systemctl enable sddm
    elif [[ "$kdetype" == "2" ]]; then
        echo "Installing Meta version of KDE."
        sudo pacman -S --needed --noconfirm "$de_pkg"
        sudo systemctl enable sddm
    elif [[ "$kdetype" == "3" ]]; then
        echo "Installing full version of KDE."
        sudo pacman -S --needed --noconfirm "$de_pkg"
        sudo systemctl enable sddm
    fi
elif [[ "$de_type" == "2" ]]; then
    echo "Installing XFCE."
    sudo pacman -S --noconfirm --needed "$de_pkg"
    sudo systemctl enable lightdm
elif [[ "$de_type" == "3" ]]; then
    echo "Installing Gnome."
    sudo pacman -S --needed --noconfirm "$de_pkg"
    sudo systemctl enable gdm
else
  echo "Invalid DE choice: $de_type"
  exit 1
fi
exit 0
