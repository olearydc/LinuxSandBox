#!/bin/bash
# Idempotent provisioning script for the linux-sandbox host.
# Run this against a fresh (or existing) Ubuntu 24.04 instance to bring it
# to the same state documented in HANDOVER.md / CLAUDE.md.
#
# Usage (from your local machine, not on the box itself):
#   ssh -i ~/.ssh/sandbox_oracle ubuntu@<IP> 'bash -s' < provision.sh
#
# Safe to re-run: every step checks current state before acting.

set -e

echo "=== 1. System update ==="
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo apt-get autoremove -y

echo "=== 2. Hostname ==="
if [ "$(hostname)" != "linux-sandbox" ]; then
  sudo hostnamectl set-hostname linux-sandbox
  sudo sed -i 's/127.0.1.1.*/127.0.1.1 linux-sandbox/' /etc/hosts
  grep -q '^127.0.1.1' /etc/hosts || echo '127.0.1.1 linux-sandbox' | sudo tee -a /etc/hosts
  echo "Hostname set to linux-sandbox (takes full effect on next login/reboot)."
else
  echo "Hostname already linux-sandbox, skipping."
fi

echo "=== 3. neofetch on login ==="
if ! command -v neofetch &>/dev/null; then
  sudo apt-get install -y neofetch
fi
grep -qxF 'neofetch' ~/.bashrc || echo 'neofetch' >> ~/.bashrc

echo "=== 4. Docker CE (official repo, not Ubuntu's docker.io) ==="
if ! command -v docker &>/dev/null; then
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
  echo "Docker already installed, skipping."
fi

if ! groups "$USER" | grep -q docker; then
  sudo usermod -aG docker "$USER"
  echo "Added $USER to the docker group -- log out and back in (or run 'newgrp docker') for it to take effect."
else
  echo "$USER already in docker group, skipping."
fi

echo "=== 5. Training directory ==="
mkdir -p ~/training
echo "~/training ready. Now scp the contents of this repo's training/ folder to it:"
echo "  scp -i ~/.ssh/sandbox_oracle training/*.sh ubuntu@<IP>:~/training/"
echo "  ssh -i ~/.ssh/sandbox_oracle ubuntu@<IP> 'chmod +x ~/training/*.sh'"

echo "=== 6. Login progress banner ==="
BANNER='if [ -f ~/training/course.sh ]; then echo; bash ~/training/course.sh next; echo "(run: ~/training/course.sh status for full progress)"; fi'
grep -qF "$BANNER" ~/.bashrc || echo "$BANNER" >> ~/.bashrc

echo
echo "=== Provisioning complete ==="
echo "If this was a fresh box, don't forget to also:"
echo "  1. Append your sandbox_oracle public key to ~/.ssh/authorized_keys"
echo "  2. scp the training/ scripts up (see step 5 above)"
echo "  3. Reboot if the kernel was updated in step 1 (sudo reboot)"
