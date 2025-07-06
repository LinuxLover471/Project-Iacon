#!/bin/bash
echo "Copying optimizations of makepkg."
sudo cp -v "$dir"/config/rust.conf /etc/makepkg.conf.d/rust.conf
sudo cp -v "$dir"/config/makepkg.conf /etc/makepkg.conf
echo "Copying trizen repo with git clone."
git clone https://aur.archlinux.org/trizen.git ~/trizen
cd ~/trizen/
makepkg -si --noconfirm
echo "Trizen was installed successfully."
exit 0
