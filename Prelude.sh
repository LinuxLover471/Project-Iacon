#!/bin/bash

# Prevent possible breakage.
set -euo pipefail

dir="$(pwd)"

echo "Hello, this is the prelude part of the master script."
echo "This script is made to assist users in installing and setting up their system with the arch wiki performance tweaks."

# Asking which kernel version the user is using to make sure the right headers are used.

kernel_header=$(uname -r)
if [[ ${kernel_header} == *"rt-lts"* ]]; then
    linux_header="linux-rt-lts-headers"
elif [[ ${kernel_header} == *"rt"* ]]; then
    linux_header="linux-rt-headers"
elif [[ ${kernel_header} == *"lts"* ]]; then
    linux_header="linux-lts-headers"
elif [[ ${kernel_header} == *"zen"* ]]; then
    linux_header="linux-zen-headers"
elif [[ ${kernel_header} == *"hardened"* ]]; then
    linux_header="linux-hardened-headers"
elif [[ ${kernel_header} == *"arch"* ]]; then
    linux_header="linux-headers"
else
    echo "Failed to find the correct linux headers, probably using a custom kernel."
    linux_header=""
fi

if [[ -n ${linux_header} ]]; then
    echo "Detected kernel headers package: ${linux_header}"
    read -p "Do you want to install this package? It is required when installing a DKMS variant of the NVIDIA driver. (Y/n): " choice
    if [[ "${choice}" =~ ^[Nn] ]]; then
        linux_header=""
    fi
fi

# Asking about installing gamemode or ananicy-cpp.

echo "Do you want to install ananicy-cpp or gamemode? WARNING: Selecting both can cause priority issues, use at your own risk."
select ananicyornot in "ananicy-cpp" "gamemode" "both"; do
    case ${ananicyornot} in
    "ananicy-cpp")
        echo "Setting to install ananicy-cpp..."
        ananicycpporgamemode="ananicy-cpp"
        break
        ;;
    "gamemode")
        echo "Setting to install gamemode..."
        ananicycpporgamemode="gamemode"
        break
        ;;
    "both")
        echo "Setting to install gamemode & ananicy-cpp..."
        ananicycpporgamemode="gamemode ananicy-cpp"
        break
        ;;
    *)
        echo "Please provide a valid input. 1,2 or 3"
        ;;
    esac
done

# Asking about the username and asking about creating a new user.

while true; do
    read -n1 -rp "Do you want to create a new (w/root privileges) user? (Required for non-root access for trizen and aur.) [Y/n]" user_choice
    user_choice="${user_choice,,}"
    echo
    if [[ -z ${user_choice} || ${user_choice} == "y" ]]; then
        echo "The script will be continuing with (yes)..."
        read -rp "What do you want to name your user? :" user
        if [[ ! ${user} =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            echo "Invalid username. Use lowercase letters, digits, '-' or '_', and start with a letter or underscore."
            continue
        fi
        break
    elif [[ ${user_choice} == "n" ]]; then
        echo "The script will be continuing with (no)."
        user=$(whoami)
        break
    else
        echo "Please provide a valid input."
    fi
done

# Exporting variables for child scripts to use.

export dir ananicycpporgamemode linux_header user ananicyornot

########### Beginning of the initial installation. ##############

cd "${dir}"/scripts/ #Enter the source directory to make sure the scripts are executed properly and less chance of failure.

echo "Installing the important pacman packages."
./0-pacman-packages.sh
echo "Starting essential commands."
./1-misc-commands.sh

if [[ -z ${user_choice} || ${user_choice} == "y" ]]; then
    echo "Creating a new user."
    ./2-user-creation.sh
else
    echo "Not creating a new user, you probably already have a new user."
fi

exit 0
