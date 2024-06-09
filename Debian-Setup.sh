#!/bin/bash

# status indicators
plus='\e[1;32m[+]\e[0m'
dplus='\e[1;32m[++]\e[0m'

clean
echo -e "$(base64 -d <<< "CgogIF9fXyAgICAgIF8gICAgXyAgICAgICAgICAgICAgX19fICAgICAgXyAgICAgICAgICAgICAKIHwgICBcIF9fX3wgfF9fKF8pX18gXyBfIF8gX19fLyBfX3wgX19ffCB8XyBfICBfIF8gX18gCiB8IHwpIC8gLV8pICdfIFwgLyBfYCB8ICcgXF9fX1xfXyBcLyAtXykgIF98IHx8IHwgJ18gXAogfF9fXy9cX19ffF8uX18vX1xfXyxffF98fF98ICB8X19fL1xfX198XF9ffFxfLF98IC5fXy8KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfF98ICAgCgo=")\n"
echo -e "A script to setup my fresh debian install."
echo -e "\n $plus This script requires the current user to be a sudo user Please enter the following, and restart for changes to take effect...:"
echo -e "1. su"
echo -e "2. sudo usermod -aG sudo $USER"
echo -e "3. exit"

read -p "Press enter to continue if the user is a sudo user, or CTRL+C to stop this script for you to add the user as a sudo user and relog."

# Ensure the script is run with superuser privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo -e "\n $plus Running apt update..."
sudo apt-get update > /dev/null
echo -e "$plus Complete"

echo -e "\n $plus Running apt upgrade..."
sudo apt-get -y -qq upgrade > /dev/null
echo -e "$plus Complete"

echo -e "\n $plus Running apt autoremove..."
sudo apt-get -y -qq autoremove > /dev/null
echo -e "$plus Complete"

echo -e "\n $plus Installing tools via apt-get..."
sudo apt-get install -y -qq linux-headers-$(uname -r) apt-transport-https adb acpi bleachbit build-essential cifs-utils cups curl dialog dkms docker.io docker-compose fastboot flameshot flatpak fswatch gimp git gnome-software-plugin-flatpak gparted htop idle3 libreoffice lm-sensors make net-tools nload nmap openvpn openssh-server pcscd pipx plasma-discover-backend-flatpak pssh python3 python3-pip python3-setuptools python3-venv screen terminator thunderbird tmux vim xclip xsel zsh > /dev/null
sudo apt-get install -y -qq wireshark
sudo usermod -a -G wireshark $USER
echo -e "$plus Complete"

echo -e "\n $plus Installing flatpak..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo -e "$plus Complete"

echo -e "\n $plus Installing Oh-My-ZSH and seeting up Powerlevel10k..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k > /dev/null
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
echo -e "$plus Complete"

echo -e "\n $plus Getting dotfiles..."
git clone --quiet https://github.com/Th4ntis/dotfiles.git ~/dotfiles  > /dev/null
echo -e "$dplus Copying .zshrc..."
cp ~/dotfiles/zsh/.zshrc ~/
echo -e "$dplus Copying .aliases..."
cp ~/dotfiles/zsh/.aliases ~/.aliases
echo -e "$dplus Copying terminator config..."
mkdir ~/.config/terminator
cp ~/dotfiles/terminator/config ~/.config/terminator/
echo -e "$dplus Copying tmux files and plugins..."
cp ~/dotfiles/tmux/.tmux.conf ~/
cp -r ~/dotfiles/tmux/tpm ~/.tmux/plugins/
cp -r ~/dotfiles/tmux/tmux-battery ~/.tmux/plugins/
cp -r ~/dotfiles/tmux/tmux-cpu ~/.tmux/plugins/
cp -r ~/dotfiles/tmux/tmux-yank ~/.tmux/plugins/
echo -e "$dplus Copying fonts..."
sudo mkdir /usr/share/fonts/truetype/MesloLGS
sudo cp ~/dotfiles/*.ttg /usr/share/fonts/truetype/MesloLGS/
echo -e "$plus Complete"

echo -e "\n $plus Performing setup and install for Yubikey..."
sudo systemctl start pcscd
sudo systemctl enable pcscd
wget -q https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-latest-linux.tar.gz -O ~/Yubikey.tar.gz
tar -xf Yubikey.tar.gz && cd ~/yubico-authenticator*
sudo ./desktop_integration.sh install
echo -e "$plus Complete"

echo -e "\n $plus Installing ProtonVPN..."
wget -q https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-2_all.deb -O ~/ProtonVPN.deb
sudo dpkg -i ~/ProtonVPN.deb
sudo apt-get update > /dev/null
sudo apt-get install -y -qq proton-vpn-gnome-desktop libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator > /dev/null
echo -e "$plus Complete"

echo -e "\n $plus Installing Librewolf..."
sudo apt-get update > /dev/null
sudo apt-get install -y -qq wget gnupg lsb-release apt-transport-https ca-certificates > /deb/null
distro=$(if echo " una vanessa focal jammy bullseye vera uma" | grep -q " $(lsb_release -sc) "; then echo $(lsb_release -sc); else echo focal; fi)
wget -O- https://deb.librewolf.net/keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/librewolf.gpg
sudo tee /etc/apt/sources.list.d/librewolf.sources << EOF > /dev/null
Types: deb
URIs: https://deb.librewolf.net
Suites: $distro
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/librewolf.gpg
EOF
sudo apt-get update > /dev/null
sudo apt-get install -y -qq librewolf > /dev/null
echo -e "$plus Complete"

echo -e "\n $plus Installing Joplin..."
wget -O - https://raw.githubusercontent.com/laurent22/joplin/master/Joplin_install_and_update.sh | bash
echo -e "$plus Complete"

echo -e "\n $plus Installing Cryptomator..."
flatpak install -y flathub org.cryptomator.Cryptomator
echo -e "$plus Complete"

echo -e "\n $plus Installing Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O ~/Chrome.deb
sudo dpkg -i ~/Chrome.deb
echo -e "$plus Complete"

echo -e "\n $plus Installing Signal..."
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
	sudo tee /etc/apt/sources.list.d/signal-xenial.list
sudo apt-get update > /dev/null
sudo apt install -y -qq signal-desktop > /dev/null
echo -e "$plus Complete"

echo -e "\n $plus Installing Discord..."
wget -q https://discord.com/api/download?platform=linux&format=deb -O ~/Discord.deb
sudo dpkg -i ~/Discord.deb;sudo apt install -f
echo -e "$plus Complete"

echo -e "\n $plus Installing OBS..."
flatpak install -y flathub com.obsproject.Studio
echo -e "$plus Complete"

echo -e "\n $plus Installing and setitng up Fusuma..."
sudo gpasswd -a $USER input
newgrp input
sudo apt install -y -qq libinput-tools ruby xdotool > /dev/null
sudo gem install fusuma
mkdir /home/$USER/.config/fusuma
echo -e "$plus Complete"

echo -e "\n $plus Cleaning up files/folders..."
sudo rm -r ~/dotfiles
sudo rm ~/Discord.deb
rm ~/Chrome.deb
sudo rm ~/ProtonVPN.deb
sudo rm ~/yubico-authenticator-latest-linux.tar.gz
echo -e "$plus Complete"

echo -e "$plus All finished! Press Enter to reboot or CTRL+C to manually reboot later."
read -p ""
sudo reboot now
