#!/bin/bash
sudo cp -av "$dir"/config/makepkg.conf /etc/makepkg.conf
echo "Copying trizen repo with git clone."
git clone https://aur.archlinux.org/trizen.git ~/trizen
cd ~/trizen/
makepkg -si --noconfirm
echo "Trizen was installed successfully."
exit 0
