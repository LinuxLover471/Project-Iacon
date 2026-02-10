# Overview

**Project-Iacon** is a repository of scripts designed to assist users setup their system post-manual installation from the [Arch Wiki](https://wiki.archlinux.org/title/Main_page), with many useful features.

## Highlights

Most options listed below can be disabled on the user's command.

- **Minimal Distraction**  
  Everything is asked upfront to avoid interruptions mid-process

- **GPU Driver & Vulkan Installation**  
  Installs appropriate GPU driver and `Vulkan` support

- **Various optimizations from the Arch Wiki**  
  Applies several performance,latency and other optimizations from the [Arch Wiki](https://wiki.archlinux.org/title/Main_page)
  **WARNING:** The fast_commit option for `ext4` can be dangerous and cause corruption and require an `fsck` in case of a powercut. See: [Arch Wiki: Ext4#Enabling_fast_commit](https://wiki.archlinux.org/title/Ext4#Enabling_fast_commit)
- **DE Installation**  
  Installs a DE of choice, with various options like KDE (Minimal, Meta, Full), Gnome, XFCE and i3 (Creator's configuration!)

- **AUR helper installation [(aurutils)](https://github.com/aurutils/aurutils/)**  
  [aurutils](https://github.com/aurutils/aurutils/), an [AUR helper](https://wiki.archlinux.org/title/AUR_helpers), is also installed and setup accordingly (Required for installing legacy dkms Nvidia drivers)

- **Root-privilege User Creation**  
  Creates a new root-privilege-user instead of using `root` for the Master script

- **Graceful Error Handling**  
  Automatically handles invalid input rather than crashing

## Requirements

- Arch Linux
- `bash`
- `ext4` filesystem on `/` and `/home` partitions for `ext4` optimizations

## Usage

```bash
git clone --recursive https://github.com/asyync1024/Project-Iacon.git
git submodule update --remote --recursive
cd Project-Iacon

# Run the Prelude script as root
./Prelude.sh

# After user creation, switch to the new user
su - newuser

# Run the main setup script as new user.
./Master.sh
