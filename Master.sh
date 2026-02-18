#!/bin/bash

set -euo pipefail

dir="$(pwd)" # Finds the current directory from which the script is run.
################ Asking everything at start to not mess with the user in the middle of the installation. ################

echo "Hi, this script is made to assist users in installing and setting up their system with the arch wiki performance tweaks. You need ext4 root and ext4 home partitions for ext4-specific tweaks."
echo

# Install Vulkan support?

while true; do
    read -n1 -rp "Do you want to install necessary vulkan suppport in the GPU driver installation part? [Y/n]" vulkansupport
    vulkansupport="${vulkansupport,,}"
    echo
    if [[ -z ${vulkansupport} || ${vulkansupport} == "y" ]]; then
        echo "Setting to install vulkan support..."
        break
    elif [[ ${vulkansupport} == "n" ]]; then
        echo "Vulkan support will NOT be installed..."
        break
    else
        echo "Please provide valid input."
    fi
done

# Install aurutils?

while true; do
    read -n1 -rp "Do you want to install aurutils? (Essential for the installation of specific NVIDIA drivers) [Y/n] :" aur_choice
    aur_choice="${aur_choice,,}"
    echo
    if [[ -z ${aur_choice} || ${aur_choice} == "y" ]]; then
        echo "Setting to install and use aurutils..."
        break
    elif [[ ${aur_choice} == "n" ]]; then
        echo "aurutils will not be installed, but AUR installation, GPU drivers installation will fail."
        break
    else
        echo "Please provide a valid input."
    fi
done

# Install GPU Driver?

while true; do
    read -n1 -rp "Do you want to install a GPU driver? [Y/n] :" gpu_choice
    gpu_choice="${gpu_choice,,}"
    echo
    if [[ -z ${gpu_choice} || ${gpu_choice} == "y" ]]; then
        if lspci | grep -i "nvidia" >/dev/null; then
            read -n1 -rp "Do you want to install Nouveau(Y) or proprietary(n) driver? [Y/n] :" open_or_pro
            open_or_pro="${open_or_pro,,}"
            echo
            if [[ -z ${open_or_pro} || ${open_or_pro} == "y" ]]; then
                echo "Setting to install Nouveau."
                gpu_drv="nouveau"
                gpu_pkg="mesa"
            elif [[ ${open_or_pro} == "n" ]]; then
                gpu_drv="nvidia"
                echo "Select the version of the nvidia driver."
                select nvidia_version in "nvidia" "nvidia-open" "nvidia-dkms" "580xx" "470xx" "390xx"; do
                    case ${nvidia_version} in
                    "nvidia" | "nvidia-open" | "nvidia-dkms")
                        echo "Setting to install ${nvidia_version} package as driver."
                        gpu_pkg="${nvidia_version} nvidia-utils nvidia-settings"
                        break 2
                        ;;
                    "580xx" | "470xx" | "390xx")
                        echo "Setting to install ${nvidia_version} package as driver."
                        gpu_pkg="nvidia-${nvidia_version}-dkms nvidia-${nvidia_version}-utils nvidia-${nvidia_version}-settings"
                        break 2
                        ;;
                    *)
                        echo "Provide valid input."
                        ;;
                    esac
                done
            else
                echo "Please provide a valid input."
            fi
        elif lspci | grep -i "amd" >/dev/null; then
            gpu_drv="amd"
            echo "Setting to install amdgpu."
            gpu_pkg="mesa"
            break
        else
            gpu_drv="intel"
            echo "Setting to install intel."
            gpu_pkg="mesa"
            break
        fi
    elif [[ ${gpu_choice} == "n" ]]; then
        echo "Skipping GPU driver installation."
        break
    else
        echo "Provide a valid input."
    fi
done

# Performance Tweaks?

while true; do
    read -n1 -rp "Do you want to apply performance tweaks from the arch wiki? [Y/n] :" perf_tweaks
    perf_tweaks="${perf_tweaks,,}"
    echo
    if [[ -z ${perf_tweaks} || ${perf_tweaks} == "y" ]]; then
        echo "The script will apply performance tweaks..."

        # Which bootloader in use?
        select bootloader_choice in "grub" "syslinux"; do
            case ${bootloader_choice} in
            "grub" | "syslinux")
                echo "Setting up to update ${bootloader_choice} configuration..."
                bootloader="${bootloader_choice}"
                break
                ;;
            *)
                echo "Please provide a valid input, trust me, it's not that hard."
                ;;
            esac
        done

        # Apply EXT4-specific tweaks?
        while true; do
            read -n1 -rp "Do you want to apply EXT4-specific performance tweaks? [Y/n] :" ext4_tweaks
            ext4_tweaks="${ext4_tweaks,,}"
            echo
            if [[ -z ${ext4_tweaks} || ${ext4_tweaks} == "y" ]]; then
                echo "EXT4-specific tweaks will be applied."
                while true; do
                    echo "Fast commit is a feature that can cause system corruption and require a fsck in the case of a powercut. See README for link to a BBS thread that exhibits this issue."
                    read -n1 -rp "Do you want to enable Fast commit? [y/N] :" ext4_fast_commit
                    ext4_fast_commit="${ext4_fast_commit,,}"
                    echo
                    if [[ ${ext4_fast_commit} == "y" ]]; then
                        echo "Fast commit will be enabled."
                        break
                    elif [[ -z ${ext4_fast_commit} || ${ext4_fast_commit} == "n" ]]; then
                        echo "Fast commit will *NOT* be enabled."
                        break
                    else
                        echo "Please provide a valid input."
                    fi
                done
                break
            elif [[ ${ext4_tweaks} == "n" ]]; then
                echo "EXT4-specific tweaks will be skipped."
                break
            else
                echo "Please provide valid input."
            fi
        done
        break

    elif [[ ${perf_tweaks} == "n" ]]; then
        echo "The script will NOT apply performance tweaks..."
        break
    else
        echo "Please provide a valid input."
    fi
done

# Install a DE?

while true; do
    read -n1 -rp "Do you want to install a DE? (You will get three options, KDE, XFCE, Gnome and i3, i3 is setted up for the creator of this script.) [Y/n] :" de_choice
    de_choice="${de_choice,,}"
    echo
    if [[ -z ${de_choice} || ${de_choice} == "y" ]]; then
        echo "Select the DE to install."
        select de_type in "KDE" "XFCE" "Gnome" "i3"; do
            case ${de_type} in
            "KDE")
                select kdetype in "Minimal" "Meta" "Full"; do
                    case ${kdetype} in
                    "Minimal")
                        echo "Setting to install Minimal KDE Plasma..."
                        de_pkg="plasma-desktop konsole kate gwenview haruna ark sddm sddm-kcm dolphin plasma-nm kscreen plasma-x11-session"
                        break 3
                        ;;
                    "Meta")
                        echo "Setting to install Meta KDE Plasma..."
                        de_pkg="plasma-meta sddm sddm-kcm plasma-x11-session"
                        break 3
                        ;;
                    "Full")
                        echo "Setting to install the Full version of KDE Plasma..."
                        de_pkg="plasma sddm sddm-kcm plasma-x11-session"
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
            "i3")
                echo "Setting to install i3... more personalised for the creator."
                de_pkg="i3 polybar picom dunst rofi rofi-calc ly xorg-xrdb xorg-xauth starship alacritty nnn neovim xsel feh thunar polkit-gnome gvfs gvfs-mtp ark thunar-archive-plugin tumbler redshift inter-font ttf-fira-code noto-fonts-emoji"
                break 2
                ;;
            *)
                echo "Please provide a valid input."
                ;;
            esac
        done
    elif [[ ${de_choice} == "n" ]]; then
        echo "Aborting the installation of a DE..."
        break
    else
        echo "Please provide a valid input."
    fi
done

# Install Firefox?

while true; do
    read -n1 -rp "Do you want to install the firefox browser? [Y/n] :" firefox_choice
    firefox_choice="${firefox_choice,,}"
    echo
    if [[ ${firefox_choice} == "y" || -z ${firefox_choice} ]]; then
        echo "The system will install the firefox browser."
        break
    elif [[ ${firefox_choice} == "n" ]]; then
        echo "The system will NOT install the firefox browser."
        break
    else
        echo "Please provide a valid input."
    fi
done

# Exporting variables for child scripts to use.

export dir vulkansupport gpu_drv gpu_pkg nvidia_version bootloader ext4_tweaks ext4_fast_commit de_type kdetype de_pkg

################ Start of the actual installation. #################

cd "${dir}"/scripts/ #Enter the source directory to make sure the scripts are executed properly and less chance of failure.

# Performance tweaks section.

if [[ -z ${perf_tweaks} || ${perf_tweaks} == "y" ]]; then
    echo "Initiating application of arch wiki tweaks."
    sudo pacman -S --noconfirm --needed mold # Needed for makepkg.conf optimization.
    ./3-performance-tweaks.sh
else
    echo "Skipping tweaks."
fi

# AUR helper, trizen installation procedure.

if [[ -z ${aur_choice} || ${aur_choice} == "y" ]]; then
    echo "Installation of aurutils begins..."
    sudo pacman -S --noconfirm --needed vifm # Default pager for aurutils.
    ./4-install-aurutils.sh
else
    echo "Not installing aurutils."
fi

cd "${dir}"/scripts/ # Getting back to the scripts directory as it got messed up while installing aurutils.

# GPU driver installation section.

if [[ -z ${gpu_choice} || ${gpu_choice} == "y" ]]; then
    echo "Starting GPU installation."
    ./5-install-GPU-driver.sh
else
    echo "Skipping driver installation procedure."
fi

# DE Installation section.

if [[ -z ${de_choice} || ${de_choice} == "y" ]]; then
    ./6-install-de.sh
else
    echo "The system will not install a DE."
fi

# Other packages, and tweaks section.

if [[ -z ${firefox_choice} || ${firefox_choice} == "y" ]]; then
    echo "Installing firefox browser."
    sudo pacman -S --noconfirm --needed firefox
else
    echo "Skipping the installation of the firefox browser."
fi

if [[ ${de_type} == "KDE" ]]; then
    echo "Stopping and disabling baloo."
    balooctl6 disable
fi
exit 0
