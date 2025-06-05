#!/bin/bash
dir="$(dirname "$(readlink -f "$0")")" # Finds the current directory from which the script is run.
################ Asking everything at start to not mess with the user in the middle of the installation. ################

echo "Hi, this script is made to assist users in installing and setting up their system with the arch wiki performance tweaks. You NEED to have ext4 root and home partition for the performance tweaks. ANY damage caused to your hardware or data is not my fault and it's your responsibility. If you continue, I will consider any damage your responsibility."
echo ""

# Asking about installing necessary vulkan support.

while true; do
        read -n1 -rp "Do you want to install necessary vulkan suppport In the GPU driver installation part? [Y/n]" vulkansupport
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

# Asking about installing trizen or not.

while true; do
    read -n1 -rp "Do you want to install trizen? (It's important for installing some older nvidia graphics drivers.) Also if you use something else like aurutils or not a pacman wrapper, the aur packages installation may (most likely will) fail. [Y/n] :"  trizen_choice
    trizen_choice="${trizen_choice,,}"
    echo
    if [[ -z "$trizen_choice" || "$trizen_choice" == "y" ]];then
        echo "Setting to install and use trizen..."
        break
    elif [[ "$trizen_choice" == "n" ]]; then
        echo "Then, trizen will not be installed, but AUR installation, GPU drivers, zen browser installation will fail."
        break
    else
        echo "Please provide a valid input or I will never forgive you."
    fi
done

# Asking the user about which GPU driver to install.

while true; do
    read -n1 -rp "Do you want to install a GPU driver? [Y/n] :" gpu_choice
    gpu_choice="${gpu_choice,,}"
    echo
    if [[ -z "$gpu_choice" || "$gpu_choice" == "y" ]];then
        if lspci | grep -i "nvidia" >/dev/null; then
            gpu_drv="nvidia"
            echo "Select the version of the nvidia driver."
            select nvidia_version in "nvidia" "nvidia-open" "nvidia-dkms" "470xx" "390xx"; do
                case $nvidia_version in
                    "nvidia")
                        echo "Setting to install nvidia package as driver."
                        gpu_pkg="nvidia nvidia-utils lib32-nvidia-utils libxnvctrl"
                        break 2
                        ;;
                    "nvidia-open")
                        echo "Setting to install nvidia-open package as driver."
                        gpu_pkg="nvidia-open nvidia-utils lib32-nvidia-utils libxnvctrl"
                        break 2
                        ;;
                    "nvidia-dkms")
                        echo "Setting to install nvidia-dkms packages as driver."
                        gpu_pkg="nvidia-dkms nvidia-utils lib32-nvidia-utils libxnvctrl"
                        break 2
                        ;;
                    "470xx")
                        echo "Setting to install 470xx package as driver."
                        gpu_pkg="nvidia-470xx-dkms nvidia-470xx-utils lib32-nvidia-470xx-utils nvidia-470xx-settings libxnvctrl-470xx lib32-libxnvctrl-470xx"
                        break 2
                        ;;
                    "390xx")
                        echo "Setting to install 390xx package as driver."
                        gpu_pkg="nvidia-390xx-dkms nvidia-390xx-utils lib32-nvidia-390xx-utils nvidia-390xx-settings libxnvctrl-390xx lib32-libxnvctrl-390xx"
                        break 2
                        ;;
                    *)
                        echo "Provide valid input."
                        ;;
                esac
                done
        elif lspci | grep -i "amd" >/dev/null; then
            gpu_drv="amd"
            echo "Setting to install amdgpu."
            gpu_pkg="mesa lib32-mesa xf86-video-amdgpu"
            break
        else
            gpu_drv="intel"
            echo "Setting to install intel."
            gpu_pkg="mesa lib32-mesa xf86-video-intel"
            break
        fi
    elif [[ "$gpu_choice" == "n" ]]; then
        echo "Skipping GPU driver installation."
        break
    else
        echo "Provide a valid input or I will just say womp womp."
    fi
done

# Asking about which bootloader the user uses.

select bootloader_choice in "Grub" "Syslinux"; do
    case $bootloader_choice in
        "Grub")
            echo "Setting up to update grub configuration..."
            bootloader="grub"
            break
            ;;
        "Syslinux")
            echo "Setting up to update syslinux configuration..."
            bootloader="syslinux"
            break
            ;;
        *)
            echo "Please provide a valid input, trust me, it's not that hard."
            ;;
        esac
done

# Asking if the user wants to apply performance tweaks from the arch wiki.

while true; do
    read -n1 -rp "Do you want to apply performance tweaks [SAFE, if you are using ext4 for root and home partitions.] from the arch wiki? [Y/n] :" perf_tweaks
    perf_tweaks="${perf_tweaks,,}"
    echo
    if [[ -z "$perf_tweaks" || "$perf_tweaks" == "y" ]];then
        echo "The script will apply performance tweaks..."
        break
    elif [[ "$perf_tweaks" == "n" ]]; then
        echo "The script will NOT apply performance tweaks..."
        break
    else
        echo "Please provide a valid input."
    fi
done

# Asking the user if they want to install a DE.

while true; do
    read -n1 -rp "Do you want to install a DE? (You will get three options, KDE, XFCE and Gnome.) [Y/n] :" de_choice
    de_choice="${de_choice,,}"
    echo
    if [[ -z "$de_choice" || "$de_choice" == "y" ]];then
        echo "Select the DE to install."
        select de_type in "KDE" "XFCE" "Gnome"; do
            case $de_type in
                "KDE")
                    select kdetype in "Minimal" "Meta" "Full"; do
                        case $kdetype in
                            "Minimal")
                                echo "Setting to install Minimal KDE Plasma..."
                                de_pkg="plasma-desktop konsole kate gwenview haruna partitionmanager ark sddm sddm-kcm dolphin plasma-nm kscreen"
                                break 3
                                ;;
                            "Meta")
                                echo "Setting to install Meta KDE Plasma..."
                                de_pkg="plasma-meta sddm"
                                break 3
                                ;;
                            "Full")
                                echo "Setting to install the Full version of KDE Plasma..."
                                de_pkg="plasma sddm"
                                break 3
                                ;;
                            *)
                                echo "Please provide a valid input."
                                ;;
                        esac
                    done
                    ;;
                "XFCE")
                    echo "Setting to install XFCE..."
                    de_pkg="xfce4 xfce4-goodies lightdm"
                    break 2
                    ;;
                "Gnome")
                    echo "Setting to install Gnome..."
                    de_pkg="gnome gdm"
                    break 2
                    ;;
                *)
                    echo "Please provide a valid input."
                    ;;
            esac
        done
    elif [[ "$de_choice" == "n" ]]; then
        echo "Aborting the installation of a DE..."
        break
    else
        echo "Please provide a valid input."
    fi
done

# Asking if the user wants to install zen-browser-bin.

while true; do
    read -n1 -rp "Do you want to install Zen browser? It's a fork of firefox and I choose this because of mozilla's new privacy policy. [Y/n] :" zen_choice
    zen_choice="${zen_choice,,}"
    echo
    if [[ "$zen_choice" == "y" || -z "$zen_choice" ]];then
        echo "The system will install zen browser."
        break
    elif [[ "$zen_choice" == "n" ]];then
        echo "The system will NOT install zen browser."
        break
    else
        echo "Please provide a valid input."
    fi
done

# Exporting variables for child scripts to use.

export dir vulkansupport gpu_drv gpu_pkg nvidia_version bootloader de_type kdetype de_pkg

################ Start of the actual installation. #################

cd "$dir"/scripts/ #Enter the source directory to make sure the scripts are executed properly and less chance of failure.

# AUR helper, trizen installation procedure.

if [[ -z "$trizen_choice" || "$trizen_choice" == "y" ]];then
    echo "Installing trizen."
    ./3-install-trizen.sh # Changing to the new user to make sure aur helper installation goes smoothly.
elif [[ "$trizen_choice" == "no" || "$trizen_choice" == "n" ]]; then
    echo "Not installing trizen."
fi

cd "$dir"/scripts/ # Getting back to the scripts folder to run the remaining scripts as it got messed up while installing trizen.

# GPU driver installation section.

if [[ -z "$gpu_choice" || "$gpu_choice" == "y" ]];then
    echo "Starting GPU installation."
    ./4-install-GPU-driver.sh
elif [[ "$gpu_choice" == "no" || "$gpu_choice" == "n" ]]; then
    echo "Skipping driver installation procedure."
fi

# Performance tweaks section.

if [[ -z "$perf_tweaks" || "$perf_tweaks" == "y" ]];then
    echo "Starting to apply arch wiki tweaks."
    ./5-performance-tweaks.sh
elif [[ "$perf_tweaks" == "no" || "$perf_tweaks" == "n" ]];then
    echo "Skipping tweaks."
fi

# DE Installation section.

if [[ -z "$de_choice" || "$de_choice" == "y" ]];then
    ./6-install-de.sh
elif [[ "$de_choice" == "no" || "$de_choice" == "n" ]]; then
    echo "The system will not install a DE."
fi

# Other packages, and tweaks section.

if [[ -z "$zen_choice" || "$zen_choice" == "y" ]];then
    echo "Installing Zen browser."
    trizen --noconfirm -S zen-browser-bin
elif [[ "$zen_choice" == "no" || "$zen_choice" == "n" ]];then
    echo "Skipping the installation of the zen browser."
fi

if [[ "$de_type" == "KDE" ]]; then
    echo "Stopping and disabling baloo."
    balooctl6 disable
    echo "Editing plasma-x11 service to make sure shutdowns happen normally."
#    nano "$HOME"/.config/systemd/user/plasma-kwin_x11.service
    echo "TimeoutStopSec=3s" >> /home/"$USER"/.config/systemd/user/plasma-kwin_x11.service
fi
exit 0
