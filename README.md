# Project Iacon

**Project Iacon** is a set of Bash scripts designed to streamline post-installation setup and configuration for Arch Linux users. It automates essential tasks and applies performance tweaks from the [Arch Wiki](https://wiki.archlinux.org), aiming to provide a faster and more consistent setup experience with minimal user intervention.

---

## ✨ Features

- **Minimal Distraction Workflow**  
  Prompts are clearly defined and asked upfront to avoid interruptions mid-process.

- **Automatic GPU Driver Installation**  
  Detects and installs the appropriate GPU drivers based on your hardware.

- **Arch Wiki-Based Performance Tweaks**  
  Applies several proven system tweaks for performance, assuming:
  - Your root (`/`) and home (`/home`) partitions are on `ext4`.

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
git clone https://github.com/linuxlover471/project-iacon.git
cd project-iacon

# Run the Prelude script as root
./Prelude.sh

# After user creation, switch to the new user
su - newuser

# Run the main setup script
./Master.sh
