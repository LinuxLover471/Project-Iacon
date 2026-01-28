# Project Iacon

**Project Iacon** is a set of Bash scripts designed to streamline post-installation setup and configuration for Arch Linux users. It automates essential tasks and applies performance and latency tweaks from the [Arch Wiki](https://wiki.archlinux.org), aiming to provide a faster and more consistent setup experience with minimal user intervention.

WARNING: The fast_commit option for ext4 can be dangerous and cause corruption and require an fsck in the case of a powercut see: https://bbs.archlinux.org/viewtopic.php?id=311780

---

## ✨ Features

- **Minimal Distraction Workflow**  
  Prompts are clearly defined and asked upfront to avoid interruptions mid-process.

- **Automatic GPU Driver Installation**  
  Detects and installs the appropriate GPU drivers based on your hardware.

- **Arch Wiki-Based Performance Tweaks**  
  Applies several proven system tweaks for performance, assuming:
  - Your root (`/`) and home (`/home`) partitions are on `ext4`.
  IF you don't have a root and /home partition as ext4, you can apply other safe tweaks.

- **Automatic User Creation**  
  Adds a new user and sets up defaults to reduce post-install steps.

- **Graceful Error Handling**  
  Handles invalid input and unexpected conditions without crashing.

---

## 📦 Requirements

- Arch Linux (base system)
- `bash`
- `ext4` filesystem for `/` and `/home` (to enable all performance tweaks)

---

## 🛠️ Usage

```bash
git clone --recursive https://github.com/linuxlover471/Project-Iacon.git
cd Project-Iacon

# Run the Prelude script as root
./Prelude.sh

# After user creation, switch to the new user
su - newuser

# Run the main setup script
./Master.sh
