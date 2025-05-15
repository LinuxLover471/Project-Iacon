#!/bin/bash
if [[ "$de_type" == "1" ]]; then
    if [[ "$kdetype" == "1" ]]; then
        echo "Installing minimal version of KDE, with a few packages."
        sudo pacman -S --needed --noconfirm plasma-desktop konsole kate gwenview haruna partitionmanager ark sddm sddm-kcm dolphin plasma-nm kscreen
        sudo systemctl enable sddm
    elif [[ "$kdetype" == "2" ]]; then
        echo "Installing Meta version of KDE."
        sudo pacman -S --needed --noconfirm plasma-meta sddm
        sudo systemctl enable sddm
    elif [[ "$kdetype" == "3" ]]; then
        echo "Installing full version of KDE."
        sudo pacman -S --needed --noconfirm plasma sddm
        sudo systemctl enable sddm
    fi
elif [[ "$de_type" == "2" ]]; then
    echo "Installing XFCE."
    sudo pacman -S --noconfirm --needed xfce4 xfce4-goodies lightdm
    sudo systemctl enable lightdm
elif [[ "$de_type" == "3" ]]; then
    echo "Installing Gnome."
    sudo pacman -S --needed --noconfirm gnome gdm
    sudo systemctl enable gdm
else
  echo "Invalid DE choice: $de_type"
  exit 1
fi
exit 0
