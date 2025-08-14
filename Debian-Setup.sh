#!/bin/bash

# status indicators
green='\e[1;32m[+]\e[0m'
red='\e[1;31m[-]\e[0m'

clear
echo -e "$(base64 -d <<< "CgogIF9fXyAgICAgIF8gICAgXyAgICAgICAgICAgICAgX19fICAgICAgXyAgICAgICAgICAgICAKIHwgICBcIF9fX3wgfF9fKF8pX18gXyBfIF8gX19fLyBfX3wgX19ffCB8XyBfICBfIF8gX18gCiB8IHwpIC8gLV8pICdfIFwgLyBfYCB8ICcgXF9fX1xfXyBcLyAtXykgIF98IHx8IHwgJ18gXAogfF9fXy9cX19ffF8uX18vX1xfXyxffF98fF98ICB8X19fL1xfX198XF9ffFxfLF98IC5fXy8KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfF98ICAgCgo=")\n"
echo -e "A script to setup my fresh debian install."

# Function to check if the user is part of the sudo group
check_sudo_user() {
    # Get the current username
    USERNAME=$(whoami)

    # Check if the user is part of the sudo group
    if groups $USERNAME | grep &>/dev/null '\bsudo\b'; then
        echo -e "\n$green $USERNAME is part of the sudo group. Proceeding with the rest of the script..."
    else
        echo -e "\n$red $USERNAME is not part of the sudo group. Please enter the following, and restart for changes to take effect:"
        echo -e "1. su"
        echo -e "2. sudo usermod -aG sudo $USER"
        echo -e "3. sudo reboot now"
	exit 1
    fi
}

# Call the function to check if the user is part of the sudo group
check_sudo_user

echo -e "========= APT =========="
echo -e "\n$green Running apt update..."
sudo apt-get update > /dev/null
echo -e "$green Complete"

echo -e "\n$green Running apt upgrade..."
sudo apt-get -y -qq upgrade > /dev/null
echo -e "$green Complete"

echo -e "\n$green Installing tools via apt-get..."
sudo apt-get install -y -qq linux-headers-$(uname -r) apt-transport-https adb acpi bleachbit build-essential cifs-utils cups curl dialog dkms docker.io docker-compose fastboot flameshot flatpak fonts-liberation fswatch gimp git gnome-software-plugin-flatpak gparted htop idle3 libatomic1 libu2f-udev libreoffice lm-sensors make net-tools nload nmap openvpn openssh-server pcscd pipx plasma-discover-backend-flatpak pssh python3 python3-pip python3-setuptools python3-venv qdbus screen terminator thunderbird tmux vim xclip xsel zsh > /dev/null
sudo apt-get install -y -qq wireshark
sudo usermod -a -G wireshark $USER
echo -e "$green Complete"

echo -e "========= Manual Software =========="
echo -e "\n$green Installing Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O ~/Chrome.deb
sudo dpkg -i ~/Chrome.deb;sudo apt install -y -f 2> /dev/null
echo -e "$green Complete"

echo -e "\n$green Installing Signal..."
wget -qO- https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
echo 'deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list
sudo apt-get update > /dev/null
sudo apt-get install -y -qq signal-desktop > /dev/null
echo -e "$green Complete"

echo -e "\n$green Installing Discord..."
wget -q "https://discord.com/api/download?platform=linux&format=deb" -O ~/Discord.deb
sudo dpkg -i ~/Discord.deb;sudo apt install -y -f 2> /dev/null
echo -e "$green Complete"

echo -e "\n$green Installing Joplin..."
wget -O - https://raw.githubusercontent.com/laurent22/joplin/master/Joplin_install_and_update.sh | bash
echo -e "$green Complete"

echo -e "\n$green Installing and setitng up Fusuma..."
sudo gpasswd -a $USER input
newgrp input
sudo apt-get install -y -qq libinput-tools ruby xdotool > /dev/null
sudo gem install fusuma
mkdir ~/.config/fusuma
echo -e "$green Complete"

echo -e "\n$green Installing Oh-My-ZSH and seeting up Powerlevel10k..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k > /dev/null
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
echo -e "$green Complete"

echo -e "========= Flatpak =========="
echo -e "\n$green Installing flatpak..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo -e "$green Complete"

echo -e "\n$green Installing Cryptomator..."
flatpak install --noninteractive -y flathub org.cryptomator.Cryptomator
echo -e "$green Complete"

echo -e "\n$green Installing OBS..."
flatpak install --noninteractive -y flathub com.obsproject.Studio
echo -e "$green Complete"

echo -e "========= Dotfiles/Personalization =========="
echo -e "\n$green Getting Debian-Setup..."
git clone --quiet https://github.com/Th4ntis/Debian-Setup.git ~/Debian-Setup > /dev/null
echo -e "Copying .zshrc..."
cp ~/Debian-Setup/zsh/zshrc ~/.zshrc
echo -e "Copying .aliases..."
cp ~/Debian-Setup/zsh/aliases ~/.aliases
echo -e "Copying terminator config..."
mkdir ~/.config/terminator
cp ~/Debian-Setup/terminator/config ~/.config/terminator/config
echo -e "Copying tmux files and plugins..."
cp ~/Debian-Setup/tmux/tmux.conf ~/.tmux.conf
mkdir ~/.tmux
mkdir ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm > /dev/null
git clone https://github.com/tmux-plugins/tmux-cpu ~/.tmux/plugins/tmux-cpu > /dev/null
git clone https://github.com/tmux-plugins/tmux-battery ~/.tmux/plugins/tmux-battery > /dev/null
git clone https://github.com/tmux-plugins/tmux-yank ~/.tmux/plugins/tmux-yank > /dev/null
echo -e "Copying fonts..."
sudo mkdir /usr/share/fonts/truetype/MesloLGS
sudo cp ~/Debian-Setup/fonts/*.ttf /usr/share/fonts/truetype/MesloLGS/
echo -e "Copying fusuma config..."
cp -r ~/Debian-Setup/fusuma/config.yml ~/.config/fusuma/

echo -e "\n$green Cleaning up files/folders..."
sudo rm ~/Discord.deb
rm ~/Chrome.deb
echo -e "$green Complete"

echo -e "\n$green All finished! Press Enter to reboot or CTRL+C to manually reboot later."
read -p ""
sudo reboot now
