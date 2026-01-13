#!/bin/bash

set -euo pipefail

echo "Adding new sudo user '${user}'"
useradd -m -G wheel -s /bin/bash ${user}
echo "Setup the new password for the '${user}'"
passwd ${user}

echo "Removing # before a line to make sure the new user can use sudo."
sudo sed -i '/^# *%wheel ALL=(ALL:ALL) ALL/s/^# *//' /etc/sudoers

echo "User creation was successful."
exit 0
