#!/bin/bash

dir="$(dirname "$(readlink -f "$0")")"

echo "Hello, this is the prelude part of the master script."

# Asking which kernel version the user is using to make sure the right headers are used.

kernel_header=$(uname -r)
if [[ "$kernel_header" == *"rt-lts"* ]]; then
    linux_header="linux-rt-lts-headers"
elif [[ "$kernel_header" == *"rt"* ]]; then
    linux_header="linux-rt-headers"
elif [[ "$kernel_header" == *"lts"* ]]; then
    linux_header="linux-lts-headers"
elif [[ "$kernel_header" == *"zen"* ]]; then
    linux_header="linux-zen-headers"
elif [[ "$kernel_header" == *"hardened"* ]]; then
    linux_header="linux-hardened-headers"
elif [[ "$kernel_header" == *"arch"* ]]; then
    linux_header="linux-headers"
else
    echo "Failed to find the correct linux headers, probably using a custom kernel."
    linux_header=""
fi

# Asking about installing gamemode or ananicy-cpp.

echo "Do you want to install ananicy-cpp or gamemode?"
select ananicyornot in "ananicy-cpp" "gamemode"; do
    case $ananicyornot in
        "ananicy-cpp")
            echo "Setting to install ananicy-cpp..."
            ananicycpporgamemode="ananicy-cpp"
            break
            ;;
        "gamemode")
            echo "Setting to install gamemode..."
            ananicycpporgamemode="gamemode lib32-gamemode"
            break
            ;;
        *)
            echo "Please provide a valid input. 1 or 2."
            ;;
    esac
done

# Asking about installing necessary vulkan support.

while true; do
    read -n1 -rp "Do you want to install vulkan icd loader and it's lib32? It's important for vulkan support [Y/n]" vulkansupport
    vulkansupport="${vulkansupport,,}"
    echo
    if [[ -z "$vulkansupport" || "$vulkansupport" == "y" ]]; then
        echo "Setting to install vulkan support..."
        vulkan_pkg="vulkan-icd-loader lib32-vulkan-icd-loader"
        break
    elif [[ "$vulkansupport" == "n" ]]; then
        echo "Vulkan support will NOT be installed..."
        vulkan_pkg=""
        break
    else
        echo "Please provide valid input."
    fi
done

# Asking about the username and asking about creating a new user.

while true; do
    read -n1 -rp "Do you want to create a new (w/root privileges) user? (Required for non-root access for trizen and aur.) [Y/n]" user_choice
    user_choice="${user_choice,,}"
    echo
    if [[ -z "$user_choice" || "$user_choice" == "y" ]]; then
        echo "The script will be continuing with (yes)..."
        read -rp "What do you want to name your user? :" user
        break
    elif [[ "$user_choice" == "n" ]]; then
        echo "The script will be continuing with (no)."
        user=$(whoami)
        break
    else
        echo "Please provide a valid input."
    fi
done

# Exporting variables for child scripts to use.

export dir vulkan_pkg ananicycpporgamemode linux_header user ananicyornot vulkansupport

########### Beginning of the initial installation. ##############

cd "$dir"/scripts/ #Enter the source directory to make sure the scripts are executed properly and less chance of failure.

echo "Installing the important pacman packages."
./0-pacman-packages.sh
echo "Starting essential commands."
./1-misc-commands.sh

if [[ -z "$user_choice" || "$user_choice" == "y" ]]; then
    echo "Creating a new user."
    ./2-user-creation.sh
elif [[ "$user_choice" == "n" ]]; then
    echo "Not creating a new user, you probably already have a new user."
fi

exit 0
