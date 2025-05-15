#!/bin/bash
dir="$(dirname "$(readlink -f "$0")")" # Finds the current directory from which the script is run.
################ Asking everything at start to not mess with the user in the middle of the installation. ################

# Asking which kernel version the user is using to make sure the right headers are used.

echo "Hi, this script is made to assist users in installing and setting up their system with the arch wiki performance tweaks. You NEED to have ext4 root and home partition. ANY damage caused to your hardware or data is not my fault and it's your responsibility. If you continue, I will consider any damage your responsibility."
echo ""
while true; do
    read -rp "Which kernel are you using? Default is option 1 just press enter. [1=Normal] 2=Zen 3=LTS 4=RT 5=RT-LTS 6=Hardened. 7=None (Custom kernel)" linux_choice
    linux_choice="${linux_choice,,}"
    if [[ "$linux_choice" == "1" || "$linux_choice" == "" ]]; then
        linux_header="linux-headers"
        break
    elif [[ "$linux_choice" == "2" ]]; then
        linux_header="linux-zen-headers"
        break
    elif [[ "$linux_choice" == "3" ]]; then
        linux_header="linux-lts-headers"
        break
    elif [[ "$linux_choice" == "4" ]]; then
        linux_header="linux-rt-headers"
        break
    elif [[ "$linux_choice" == "5" ]]; then
        linux_header="linux-rt-lts-headers"
        break
    elif [[ "$linux_choice" == "6" ]]; then
        linux_header="linux-hardened-headers"
        break
    elif [[ "$linux_choice" == "7" ]]; then
        linux_header=""
        break
    else
        echo "Please provide a valid input or else."
    fi
done

# Asking about installing gamemode or ananicy-cpp.

while true; do
    read -rp "Do you want to install/use ananicy-cpp or gamemode? [1]=ananicy-cpp and [2]=gamemode." ananicyornot
    ananicyornot="${ananicyornot,,}"
    if [[ "$ananicyornot" == "1" ]]; then
        echo "Setting to install ananicy-cpp."
        ananicycpporgamemode="ananicy-cpp"
        break
    elif [[ "$ananicyornot" == "2" ]]; then
        echo "Setting to install gamemode."
        ananicycpporgamemode="gamemode lib32-gamemode"
        break
    else
        echo "Please provide a valid input."
    fi
done

# Asking about installing necessary vulkan support.

while true; do
    read -rp "Do you want vulkan support? It installs the vulkan-icd-loader and it's lib32. [Y/n] " vulkansupport
    vulkansupport="${vulkansupport,,}"
    if [[ "$vulkansupport" == "" || "$vulkansupport" == "yes" || "$vulkansupport" == "y" ]]; then
        echo "Setting to install vulkan support."
        vulkan_pkg="vulkan-icd-loader lib32-vulkan-icd-loader"
        break
    elif [[ "$vulkansupport" == "no" || "$vulkansupport" == "n" ]]; then
        echo "Vulkan support will NOT be installed."
        vulkan_pkg=""
        break
    else
        echo "Please provide valid input."
    fi
done

# Asking about the username and asking about creating a new user.

read -rp "What do you [want to/have named] your user?" user
while true; do
    read -rp "Do you want to create a new (w/root privileges) user? (Required for non-root access for trizen and aur.) [Y/n]" user_choice
    user_choice="${user_choice,,}"
    if [[ "$user_choice" == "" || "$user_choice" == "yes" || "$user_choice" == "y" ]]; then
        echo "The script will be continuing with (yes)."
        break
    elif [[ "$user_choice" == "no" || "$user_choice" == "n" ]]; then
        echo "The script will be continuing with (no)."
        break
    else
        echo "Please provide a valid input."
    fi
done

# Asking about installing trizen or not.
while true; do
    read -rp "Do you want to install trizen? (It's important for installing graphics drivers.) Also if you use something else like aurutils or not a pacman wrapper, the aur packages installation may (most likely will) fail. [Y/n] :"  trizen_choice
    trizen_choice="${trizen_choice,,}"
    if [[ "$trizen_choice" == "" || "$trizen_choice" == "yes" || "$trizen_choice" == "y" ]];then
        echo "Setting to install and use trizen."
        aur_hlp=trizen
        break
    elif [[ "$trizen_choice" == "no" || "$trizen_choice" == "n" ]]; then
        read -rp "What is the aur helper that you use?" aur_hlp
        break
    else
        echo "Please provide a valid input or I will never forgive you."
    fi
done

# Asking the user about which GPU driver to install.

while true; do
    read -rp "Do you want to install a GPU driver? [Y/n] :" gpu_choice
    gpu_choice="${gpu_choice,,}"
    if [[ "$gpu_choice" == "" || "$gpu_choice" == "yes" || "$gpu_choice" == "y" ]];then
        read -rp "Which gpu driver do you want to install then? [nvidia/amd/intel] (Type the exact name! capitalization is allowed and nothing else.)" gpu_drv
        gpu_drv="${gpu_drv,,}"
        if [[ "$gpu_drv" == "nvidia" ]];then
            read -rp "Which nvidia version do you want to install? [nvidia/nvidia-dkms/nvidia-open/470xx/390xx]" nvidia_version
            nvidia_version="${nvidia_version,,}"
            break
        elif [[ "$gpu_drv" == "amd" ]];then
            echo "Will install AMD drivers. (They are part of the kernel.)"
            break
        elif [[ "$gpu_drv" == "intel" ]];then
            echo "Will install Intel drivers."
            break
        else
            echo "Provide a valid input."
        fi
    elif [[ "$gpu_choice" == "no" || "$gpu_choice" == "n" ]]; then
        break
    else
        echo "Provide a valid input or I will just say womp womp."
    fi
done

# Asking about which bootloader the user uses.

while true; do
    read -rp "Which bootloader do you use? 1=Grub 2=Syslinux" bootloader
    bootloader="${bootloader,,}"
    if [[ "$bootloader" == "1" ]]; then
        echo "Setting up to update grub configuration."
        bootloader="grub"
        break
    elif [[ "$bootloader" == "2" ]]; then
        echo "Setting up to update syslinux configuration."
        bootloader="syslinux"
        break
    else
    echo "Provide a valid input, trust me, it's not that hard."
    fi
done

# Asking if the user wants to apply performance tweaks from the arch wiki.

while true; do
    read -rp "Do you want to apply performance tweaks [SAFE, if you are using ext4] from the arch wiki? [Y/n] :" perf_tweaks
    perf_tweaks="${perf_tweaks,,}"
    if [[ "$perf_tweaks" == "" || "$perf_tweaks" == "yes" || "$perf_tweaks" == "y" ]];then
        echo "The script will apply performance tweaks."
    break
    elif [[ "$perf_tweaks" == "no" || "$perf_tweaks" == "n" ]]; then
        echo "The script will NOT apply performance tweaks."
    break
    else
        echo "Please provide a valid input."
    fi
done

# Asking the user if they want to install a DE.

while true; do
    read -rp "Do you want to install a DE? (You will get three options, KDE, XFCE and Gnome.) [Y/n] :" de_choice
    de_choice="${de_choice,,}"
    if [[ "$de_choice" == "" || "$de_choice" == "yes" || "$de_choice" == "y" ]];then
        read -rp "Which DE do you want to install? [1=KDE 2=XFCE 3=Gnome]" de_type
        if [[ "$de_type" == "1" ]]; then
            read -rp "Which version of KDE do you want to install? [1=Minimal (With select packages.) 2=Meta 3=Full]" kdetype
            if [[ "$kdetype" == "1" ]]; then
                echo "The script will install the minimal version of KDE, with a select packages."
                break
            elif [[ "$kdetype" == "2" ]]; then
                echo "The script will install the meta version of KDE."
                break
            elif [[ "$kdetype" == "3" ]]; then
                echo "The script will install the full version of KDE."
                break
            else
                echo "Provide a valid input."
            fi
        elif [[ "$de_type" == "2" ]]; then
            echo "The system will install XFCE."
            break
        elif [[ "$de_type" == "3" ]]; then
            echo "The system will install Gnome."
            break
        fi
    elif [[ "$de_choice" == "no" || "$de_choice" == "n" ]]; then
        echo "The system will not install a DE."
        break
    else
        echo "Provide a valid input."
    fi
done

# Asking if the user wants to install zen-browser-bin.

while true; do
    read -rp "Do you want to install Zen browser? It's a fork of firefox and I choose this because of mozilla's new privacy policy. [Y/n] : " zen_choice
    zen_choice="${zen_choice,,}"
    if [[ "$zen_choice" == "" || "$zen_choice" == "yes" || "$zen_choice" == "y" ]];then
        echo "The system will install zen browser."
        break
    elif [[ "$zen_choice" == "no" || "$zen_choice" == "n" ]];then
        echo "The system will NOT install zen browser."
        break
    else
        echo "Please provide a valid input."
    fi
done

# Exporting variables for child scripts to use.

export dir vulkan_pkg ananicycpporgamemode linux_header user ananicyornot aur_hlp gpu_drv nvidia_version vulkansupport bootloader de_type kdetype

################ Start of the actual installation. #################

cd "$dir"/scripts/ #Enter the source directory to make sure the scripts are executed properly and less chance of failure.
echo "Installing the important pacman packages."
./0-pacman-packages.sh
echo "Starting essential commands."
./1-misc-commands.sh

if [[ "$user_choice" == "" || "$user_choice" == "yes" || "$user_choice" == "y" ]]; then
    echo "Creating a new user."
    ./2-user-creation.sh
elif [[ "$user_choice" == "no" || "$user_choice" == "n" ]]; then
    echo "Not creating a new user, you probably already have a new user."
fi

# AUR helper, trizen installation procedure.

if [[ "$trizen_choice" == "" || "$trizen_choice" == "yes" || "$trizen_choice" == "y" ]];then
    echo "Installing trizen."
    su - "$user" -c "cd '$dir/scripts' && ./3-install-trizen.sh" # Changing to the new user to make sure aur helper installation goes smoothly.
elif [[ "$trizen_choice" == "no" || "$trizen_choice" == "n" ]]; then
    echo "Not installing trizen."
fi

cd "$dir"/scripts/ # Getting back to the scripts folder to run the remaining scripts as it got messed up while installing trizen.

# GPU driver installation section.

if [[ "$gpu_choice" == "" || "$gpu_choice" == "yes" || "$gpu_choice" == "y" ]];then
    echo "Starting GPU installation."
    ./4-install-GPU-driver.sh
elif [[ "$trizen_choice" == "no" || "$trizen_choice" == "n" ]]; then
    echo "Skipping driver installation procedure."
fi

# Performance tweaks section.

if [[ "$perf_tweaks" == "" || "$perf_tweaks" == "yes" || "$perf_tweaks" == "y" ]];then
    echo "Starting to apply arch wiki tweaks."
    ./5-performance-tweaks.sh
elif [[ "$perf_tweaks" == "no" || "$perf_tweaks" == "n" ]];then
    echo "Skipping tweaks."
fi

# DE Installation section.

if [[ "$de_choice" == "" || "$de_choice" == "yes" || "$de_choice" == "y" ]];then
    ./6-install-de.sh
elif [[ "$de_choice" == "no" || "$de_choice" == "n" ]]; then
    echo "The system will not install a DE."
fi

# Other packages, and tweaks section.

if [[ "$zen_choice" == "" || "$zen_choice" == "yes" || "$zen_choice" == "y" ]];then
    echo "Installing Zen browser."
    su - "$user" -c "trizen --noconfirm -S zen-browser-bin"
elif [[ "$zen_choice" == "no" || "$zen_choice" == "n" ]];then
    echo "Skipping the installation of the zen browser."
fi

if [[ "$de_type" == "1" ]]; then
    echo "Stopping and disabling baloo."
    balooctl6 disable
    echo "Editing plasma-x11 service to make sure shutdowns happen normally."
#    nano "$HOME"/.config/systemd/user/plasma-kwin_x11.service
    su - "$user" -c 'echo "TimeoutStopSec=1s" >> ~/.config/systemd/user/plasma-kwin_x11.service'
fi

exit 0
