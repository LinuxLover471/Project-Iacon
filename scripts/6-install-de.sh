#!/bin/bash
if [[ "$de_type" == "KDE" ]]; then
    if [[ "$kdetype" == "Minimal" ]]; then
        echo "Installing minimal version of KDE, with a few packages."
        sudo pacman -S --needed --noconfirm $de_pkg
        sudo systemctl enable sddm
    elif [[ "$kdetype" == "Meta" ]]; then
        echo "Installing Meta version of KDE."
        sudo pacman -S --needed --noconfirm $de_pkg
        sudo systemctl enable sddm
    elif [[ "$kdetype" == "Full" ]]; then
        echo "Installing full version of KDE."
        sudo pacman -S --needed --noconfirm $de_pkg
        sudo systemctl enable sddm
    fi
elif [[ "$de_type" == "XFCE" ]]; then
    echo "Installing XFCE."
    sudo pacman -S --noconfirm --needed $de_pkg
    sudo systemctl enable lightdm
elif [[ "$de_type" == "Gnome" ]]; then
    echo "Installing Gnome."
    sudo pacman -S --needed --noconfirm $de_pkg
    sudo systemctl enable gdm
else
  echo "Invalid DE choice: $de_type"
  exit 1
fi
exit 0
