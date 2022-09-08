#!/bin/bash
#
# my-bs.sh  Author: Th4ntis
# git clone git@github.com:Th4ntis/my-bs.git
#
# Standard Disclaimer: Author assumes no liability for any damage

# status indicators
greenplus='\e[1;33m[++]\e[0m'

# variables moved from local to global
    detected_env=""

install() {
    sudo apt -y update && sudo apt -y upgrade && sudo apt -y autoremove
    echo -e "\n $greenplus Installing list of tools through apt \n"
    sudo apt install -y linux-headers-$(uname -r) adb acpi bleachbit build-essential cifs-utils cups curl dialog dkms fastboot flameshot flatpak fonts-powerline fswatch gimp git gnome-software-plugin-flatpak gparted htop idle3 libreoffice lm-sensors make net-tools nload nmap openvpn openssh-server pcscd pssh python3 python3-pip python3-setuptools python3-venv screen steam terminator thunderbird tmux ttf-mscorefonts-installer upower vim wireshark xsel zsh
    echo -e "\n $greenplus Complete! \n"
    check_de
    timeshift_install
    brave_install
    flatpak_install
    joplin_install
    yubico_install
    sublime_install
    veracrypt_install
    cryptomator_install
    element_install
    signal_install
    discord_install
    fusuma_install
    oh-my-zsh_install
    tmux-plugins_install
    dotfile_setup
    cleanup
    finish
    }

check_de() {
    detect_xfce=$(ps -e | grep -c -E '^.* xfce4-session$')
    detect_gnome=$(ps -e | grep -c -E '^.* gnome-session-*')
    detect_kde=$(ps -e | grep -c -E '^.* kded5$')
    [ $detect_gnome -ne 0 ] && detected_env="GNOME"
    [ $detect_xfce -ne 0 ] && detected_env="XFCE"
    [ $detect_kde -ne 0 ] && detected_env="KDE"
    echo -e "\n  $greenplus Detected Environment: $detected_env"
    sleep 3
    [ $detected_env = "GNOME" ] && gnome_de
    [ $detected_env = "XFCE" ] && xfce_de
    [ $detected_env = "KDE" ] && kde_de
    [ $detected_env = "" ] && echo -e "\n  $redexclaim Unable to determine desktop environment"
    }

gnome_de () {
    # WIP
    }

xfce_de () {
    # WIP
    }

kde_de () {
    # Configures KDE shortcuts
    sed -i 's/Alt+F4/Alt+Q/' ~/.config/kglobalshortcutsrc
#    sed -i 's/Meta+Ctrl+Right/Alt+Right/' ~/.config/kglobalshortcutsrc
#    sed -i 's/Meta+Ctrl+Left/Alt+Left/' ~/.config/kglobalshortcutsrc
    cat >> ~/.config/kglobalshortcutsrc << EOF
[terminator.desktop]
_k_friendly_name=Launch Terminator
_launch=Alt+Return\t,none,Launch Terminator
EOF
    echo -e "\n $greenplus KDE config complete \n"
    sleep 2
    }

timeshift_install() {
    echo -e "\n $greenplus Installing timeshift \n"
    sudo add-apt-repository -y ppa:teejee2008/timeshift
    sudo apt update
    sudo apt install -y timeshift
    echo -e "\n $greenplus timeshift install complete \n"
    }

brave_install() {
    echo -e "\n $greenplus Installing BraveBrowser \n"
    sudo apt install apt-transport-https curl
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install brave-browser
    echo -e "\n $greenplus BraveBrowser install complete \n"
    }

flatpak_install() {
    echo -e "\n $greenplus Installing Flatpak, Bitwarden, Tor Browser, and Onion Share \n"
    sleep 2
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo # Installs Flatpak plugin and adds Flathub Repo
    flatpak install -y flathub com.bitwarden.desktop                                          # Install Bitwarden Password Manager
    flatpak install -y flathub com.github.micahflee.torbrowser-launcher                       # Installs Tor Browser
    echo -e "\n $greenplus Complete \n"
    sleep 2
    }

joplin_install() {
    echo -e "\n $greenplus Installing Joplin \n"
    sleep 2
    wget -O - https://raw.githubusercontent.com/laurent22/joplin/master/Joplin_install_and_update.sh | bash
    echo -e "\n $greenplus Complete \n"
    sleep 2
    }

yubico_install() {
    echo -e "\n $greenplus Installing Yubico Authenticator \n"
    sudo add-apt-repository -y ppa:yubico/stable
    sudo apt update
    sudo apt install -y yubioath-desktop
    echo -e "\n $greenplus yubico install complete \n"
    sleep 2
    }

sublime_install() {
    echo -e "\n $greenplus Tnstalling sublime text editor \n"
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo gpg --dearmor -o /usr/share/keyrings/sublimetext-keyring.gpg
    sudo apt update
    sudo apt install -y sublime-text
    echo -e "\n $greenplus sublime install complete \n"
    sleep 2
    }

veracrypt_install() {
    echo -e "\n $greenplus Tnstalling Veracrypt \n"
    sleep 2
    sudo apt --fix-broken install
    wget https://launchpad.net/veracrypt/trunk/1.24-update7/+download/veracrypt-1.24-Update7-Ubuntu-20.04-amd64.deb
    sudo dpkg -i veracrypt-1.24-Update7-Ubuntu-20.04-amd64.deb; sudo apt -y install -f
    rm veracrypt*
    echo -e "\n $greenplus Veracrypt install complete \n"
    sleep 2
    }

cryptomator_install() {
    echo -e "\n $greenplus Installing Cryptomator \n"
    sleep 2
    sudo add-apt-repository ppa:sebastian-stenzel/cryptomator
    sudo apt update
    sudo apt install -y cryptomator
    echo -e "\n $greenplus Cryptomator install complete \n"
    sleep 2
    }

element_install() {
    echo -e "\n $greenplus Installing Element \n"
    sleep 2
    sudo apt install -y wget apt-transport-https
    sudo wget -O /usr/share/keyrings/riot-im-archive-keyring.gpg https://packages.riot.im/debian/riot-im-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/riot-im-archive-keyring.gpg] https://packages.riot.im/debian/ default main" | sudo tee /etc/apt/sources.list.d/riot-im.list
    sudo apt update
    sudo apt -y install element-desktop
    echo -e "\n $greenplus Element install complete \n"
    sleep 2
    }

signal_install() {
    echo -e "\n $greenplus Installing Signal \n"
    sleep 2
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
    cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
    sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
    sudo apt update && sudo apt -y install signal-desktop
    echo -e "\n $greenplus Signal install complete \n"
    sleep 2
    }

discord_install() {
    echo -e "\n $greenplus Installing Discord \n"
    rm Discord.deb
    wget -O ~/Discord.deb "https://discord.com/api/download?platform=linux&format=deb"
    sudo dpkg -i ~/Discord.deb;sudo apt install -f
    sudo rm ~/Discord.deb
    echo -e "\n $greenplus Discord install complete \n"
    sleep 2
    }

fusuma_install() {
    echo -e "\n $greenplus Tnstalling Fusuma \n"
    sleep 2
    sudo gpasswd -a $USER input
    newgrp input
    sudo apt install -y libinput-tools ruby xdotool
    sudo gem install fusuma
    mkdir /home/$USER/.config/fusuma
    echo -e "\n $greenplus fusuma complete \n"
    sleep 2
    }

oh-my-zsh_install() {
    echo -e "\n $greenplus Installing Oh-My-ZSH \n"
    sleep 2
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    echo -e "\n $greenplus Oh-My-ZSH Installed \n"
    sleep 2
    }    

dotfile_setup() {
    echo -e "\n Setting up DotFiles \n"
    git clone https://github.com/Th4ntis/dotfiles.git ~/dotfiles
    cp ~/dotfiles/zsh/.zshrc ~/
    cp ~/dotfiles/tmux/.tmux.conf ~/
    cp -r ~/dotfiles/fusuma/fusuma ~/.config/
    echo -e "\n DotFiles done \n"
    sleep 2
    }

tmux-plugins_install() {
    echo -e "\n Tmux Plugins \n"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    git clone https://github.com/tmux-plugins/tmux-battery ~/.tmux/plugins/tmux-battery
    git clone https://github.com/tmux-plugins/tmux-cpu ~/.tmux/plugins/tmux-cpu
    git clone https://github.com/tmux-plugins/tmux-yank ~/.tmux/plugins/tmux-yank
    echo -e "\n Tmux Plugins Complete \n"
    sleep 2
    }

cleanup() {
    echo -e "\n Cleaning up... \n"
    sudo rm -r $HOME/dotfiles
    echo -e "\n Cleanup finshed! \n"
    sleep 2
    }

finish() {
    clear
    echo -e "All finished! Rebooting to apply all changes in 10 seconds... \n"
    sleep 10
    sudo reboot now
    }

# ascii art
asciiart=$(base64 -d <<< "IF9fX19fICAgICAgICBfX19fXyBfX19fXyAKfCAgICAgfF8gXyAgIHwgX18gIHwgICBfX3wKfCB8IHwgfCB8IHwgIHwgX18gLXxfXyAgIHwKfF98X3xffF8gIHwgIHxfX19fX3xfX19fX3wKICAgICAgfF9fX3wgICAgICAgICAgICAgIA==")

echo -e "$asciiart"
echo -e "My Buntu Script \n"

install
