#!/bin/bash

set -euo pipefail
AUR_DIR="/var/cache/pacman/aurutils"

echo "==> Copying aurutils repo with git clone."
if [[ ! -d "${HOME}/aurutils" ]]; then
    git clone https://aur.archlinux.org/aurutils.git "${HOME}/aurutils"
fi

echo "==> Entering aurutils directory."
cd "${HOME}/aurutils"

echo "==> Making the package using makepkg"
makepkg -si --noconfirm

echo "==> Creating the directory where the aurutils cache will lie."
sudo mkdir -p "${AUR_DIR}"

echo "==> Creating a local repository."
sudo tee /etc/pacman.d/aurutils >/dev/null <<EOF
[options]
CacheDir = /var/cache/pacman/pkg
CacheDir = ${AUR_DIR}
CleanMethod = KeepCurrent

[aurutils]
SigLevel = Optional TrustAll
Server = file://${AUR_DIR}
EOF

if ! grep -q 'Include = /etc/pacman.d/aurutils' /etc/pacman.conf; then
    echo "Include = /etc/pacman.d/aurutils" | sudo tee -a /etc/pacman.conf
fi

sudo install -d ${AUR_DIR} -o ${USER}

echo "==> Initializing empty repo database."
if [[ ! -f "${AUR_DIR}/aurutils.db.tar" ]]; then
    repo-add "${AUR_DIR}/aurutils.db.tar"
fi

echo "==> Synchronizing with pacman."
sudo pacman -Syu

echo "==> aurutils was installed successfully."
exit 0
