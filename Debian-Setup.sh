#!/bin/bash

# status indicators
plus='\e[1;32m[+]\e[0m'
dplus='\e[1;32m[++]\e[0m'
seperator='\e[1;32m[==========]\e[0m'

clear
echo -e "$(base64 -d <<< "CgogIF9fXyAgICAgIF8gICAgXyAgICAgICAgICAgICAgX19fICAgICAgXyAgICAgICAgICAgICAKIHwgICBcIF9fX3wgfF9fKF8pX18gXyBfIF8gX19fLyBfX3wgX19ffCB8XyBfICBfIF8gX18gCiB8IHwpIC8gLV8pICdfIFwgLyBfYCB8ICcgXF9fX1xfXyBcLyAtXykgIF98IHx8IHwgJ18gXAogfF9fXy9cX19ffF8uX18vX1xfXyxffF98fF98ICB8X19fL1xfX198XF9ffFxfLF98IC5fXy8KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfF98ICAgCgo=")\n"
echo -e "A script to setup my fresh debian install."

# Function to check if the user is part of the sudo group
check_sudo_user() {
    # Get the current username
    USERNAME=$(whoami)

    # Check if the user is part of the sudo group
    if groups $USERNAME | grep &>/dev/null '\bsudo\b'; then
        echo -e "\n $USERNAME is part of the sudo group. Proceeding with the rest of the script..."
    else
        echo -e "\n $USERNAME is not part of the sudo group. Please enter the following, and restart for changes to take effect:"
        echo -e "1. su"
        echo -e "2. sudo usermod -aG sudo $USER"
        echo -e "3. sudo reboot now"
	exit 1
    fi
}

# Call the function to check if the user is part of the sudo group
check_sudo_user

echo -e "========= APT =========="
echo -e "\n$plus Running apt update..."
sudo apt-get update > /dev/null
echo -e "$plus Complete"

echo -e "\n$plus Running apt upgrade..."
sudo apt-get -y -qq upgrade > /dev/null
echo -e "$plus Complete"

echo -e "\n$plus Installing tools via apt-get..."
sudo apt-get install -y -qq linux-headers-$(uname -r) apt-transport-https adb acpi bleachbit build-essential cifs-utils cups curl dialog dkms docker.io docker-compose fastboot flameshot flatpak fonts-liberation fswatch gimp git gnome-software-plugin-flatpak gparted htop idle3 libatomic1 libu2f-udev libreoffice lm-sensors make net-tools nload nmap openvpn openssh-server pcscd pipx plasma-discover-backend-flatpak pssh python3 python3-pip python3-setuptools python3-venv screen terminator thunderbird tmux vim xclip xsel zsh > /dev/null
sudo apt-get install -y -qq wireshark
sudo usermod -a -G wireshark $USER
echo -e "$plus Complete"

echo -e "========= Manual Software =========="
echo -e "\n$plus Installing Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O ~/Chrome.deb
sudo dpkg -i ~/Chrome.deb;sudo apt install -y -f 2> /dev/null
echo -e "$plus Complete"

echo -e "\n$plus Installing Signal..."
wget -qO- https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
echo 'deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list
sudo apt-get update > /dev/null
sudo apt-get install -y -qq signal-desktop > /dev/null
echo -e "$plus Complete"

echo -e "\n$plus Installing Discord..."
wget -q "https://discord.com/api/download?platform=linux&format=deb" -O ~/Discord.deb
sudo dpkg -i ~/Discord.deb;sudo apt install -y -f 2> /dev/null
echo -e "$plus Complete"

echo -e "\n$plus Performing setup and install for Yubikey..."
sudo systemctl start pcscd
sudo systemctl enable pcscd
wget -q https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-latest-linux.tar.gz -O ~/Yubikey.tar.gz
tar -xf Yubikey.tar.gz && cd ~/yubico-authenticator*
./desktop_integration.sh -i
cd
echo -e "$plus Complete"

echo -e "\n$plus Installing ProtonVPN..."
wget -q -O - https://repo.protonvpn.com/debian/public_key.asc | sudo apt-key add -
echo 'deb https://repo.protonvpn.com/debian stable main' | sudo tee /etc/apt/sources.list.d/protonvpn.list
sudo apt-get update > /dev/null
sudo apt-get install -y -qq proton-vpn-gnome-desktop libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator > /dev/null
echo -e "$plus Complete"

echo -e "\n$plus Installing Librewolf..."
sudo apt-get update > /dev/null
sudo apt-get install -y -qq wget gnupg lsb-release apt-transport-https ca-certificates > /dev/null
wget -qO - https://deb.librewolf.net/keyring.gpg | sudo apt-key add -
sudo tee /etc/apt/sources.list.d/librewolf.list << EOF
deb [arch=amd64] https://deb.librewolf.net bullseye main
EOF
sudo apt-get update > /dev/null
sudo apt-get install -y -qq librewolf > /dev/null
echo -e "$plus Complete"

echo -e "\n$plus Installing Joplin..."
wget -O - https://raw.githubusercontent.com/laurent22/joplin/master/Joplin_install_and_update.sh | bash
echo -e "$plus Complete"

echo -e "\n$plus Installing and setitng up Fusuma..."
sudo gpasswd -a $USER input
newgrp input
sudo apt-get install -y -qq libinput-tools ruby xdotool > /dev/null
sudo gem install fusuma
mkdir ~/.config/fusuma
cp -r ~/dotfiles/fusuma/config.yml ~/.config/fusuma/
echo -e "$plus Complete"

echo -e "\n$plus Installing Oh-My-ZSH and seeting up Powerlevel10k..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k > /dev/null
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
echo -e "$plus Complete"

echo -e "========= Flatpak =========="
echo -e "\n$plus Installing flatpak..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo -e "$plus Complete"

echo -e "\n$plus Installing Cryptomator..."
flatpak install --noninteractive -y flathub org.cryptomator.Cryptomator
echo -e "$plus Complete"

echo -e "\n$plus Installing OBS..."
flatpak install --noninteractive -y flathub com.obsproject.Studio
echo -e "$plus Complete"

echo -e "========= Dotfiles/Personalization =========="
echo -e "\n$plus Getting dotfiles..."
git clone --quiet https://github.com/Th4ntis/dotfiles.git ~/dotfiles  > /dev/null
echo -e "$dplus Copying .zshrc..."
cp ~/dotfiles/zsh/.zshrc ~/
echo -e "$dplus Copying .aliases..."
cp ~/dotfiles/zsh/.aliases ~/.aliases
echo -e "$dplus Copying terminator config..."
mkdir ~/.config/terminator
cp ~/dotfiles/terminator/config ~/.config/terminator/.config
echo -e "$dplus Copying tmux files and plugins..."
cp ~/dotfiles/tmux/.tmux.conf ~/
mkdir ~/.tmux
mkdir ~/.tmux/plugins
cp -r ~/dotfiles/tmux/tpm ~/.tmux/plugins/
cp -r ~/dotfiles/tmux/tmux-battery ~/.tmux/plugins/
cp -r ~/dotfiles/tmux/tmux-cpu ~/.tmux/plugins/
cp -r ~/dotfiles/tmux/tmux-yank ~/.tmux/plugins/
echo -e "$dplus Copying fonts..."
sudo mkdir /usr/share/fonts/truetype/MesloLGS
sudo cp ~/dotfiles/Fonts/*.ttf /usr/share/fonts/truetype/MesloLGS/
echo -e "$plus Complete"

echo -e "\n$plus Cleaning up files/folders..."
sudo rm -r ~/dotfiles
sudo rm ~/Discord.deb
rm ~/Chrome.deb
sudo rm ~/ProtonVPN.deb
sudo rm ~/yubico-authenticator-latest-linux.tar.gz
echo -e "$plus Complete"

echo -e "\n$plus All finished! Press Enter to reboot or CTRL+C to manually reboot later."
read -p ""
sudo reboot now
