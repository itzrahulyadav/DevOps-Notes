#!/bin/bash

wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/vscodium-archive-keyring.gpg >/dev/null
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
sudo apt update && sudo apt install codium



curl -fsSL https://code-server.dev/install.sh | sh
code-server --auth none --bind-addr 0.0.0.0:8080

sudo systemctl stop code-server@$USER
code-server --auth none --bind-addr 0.0.0.0:8080
sudo systemctl enable --now code-server@$USER
sudo systemctl restart code-server@$USER
