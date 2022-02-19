#!/bin/bash
#
# my-bs.sh  Author: Th4ntis
# git clone git@github.com:Th4ntis/my-bs.git
#
# Standard Disclaimer: Author assumes no liability for any damage

# status indicators
    greenplus='\e[1;33m[++]\e[0m'
    greenminus='\e[1;33m[--]\e[0m'
    redexclaim='\e[1;31m[!!]\e[0m'
    blinkexclaim='\e[1;31m[\e[5;31m!!\e[0m\e[1;31m]\e[0m'

# variables moved from local to global
    detected_env=""

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
    echo -e "\n $greenplus Gnome detected - Disabling Power Savings"
    # ac power
    sudo -i -u $USER gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing      # Disables automatic suspend on charging)
     echo -e "  $greenplus org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing"
    sudo -i -u $USER gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0         # Disables Inactive AC Timeout
     echo -e "  $greenplus org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0"
    # battery power
    sudo -i -u $USER gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type nothing # Disables automatic suspend on battery)
     echo -e "  $greenplus org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type nothing"
    sudo -i -u $USER gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0    # Disables Inactive Battery Timeout
     echo -e "  $greenplus org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0"
     setup
    }

xfce_de () {
    if [ $USER = "root" ]
     then
      echo -e "\n $greenplus XFCE Detected - disabling xfce power management \n"
      eval wget $raw_xfce -O /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
      echo -e "\n  $greenplus XFCE power management disabled for user: $USER \n"
    else
      echo -e "\n  $greenplus XFCE Detected - disabling xfce power management \n"
      eval wget $raw_xfce -O /home/$USER/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
      echo -e "\n  $greenplus XFCE power management disabled for user: $USER \n"
    fi
    setup
    }

kde_de () {
    sed -i 's/Ctrl+Alt+T/Alt+Return/' ~/.config/kglobalshortcutsrc
    sed -i 's/Alt+F4/Alt+Q/' ~/.config/kglobalshortcutsrc
    sed -i 's/Meta+Ctrl+Right/Alt+Right/' ~/.config/kglobalshortcutsrc
    sed -i 's/Meta+Ctrl+Left/Alt+Left/' ~/.config/kglobalshortcutsrc
    echo -e "\n $greenplus kde_de complete \n"
    sleep 2
    setup
    }

setup(){
    sudo apt -y update && sudo apt -y upgrade && sudo apt -y autoremove

    echo -e "\n $greenplus Installing list of tools through apt \n"
    sudo apt install -y linux-headers-$(uname -r) adb bleachbit build-essential cifs-utils clementine cups curl dialog dkms fastboot flameshot flatpak gimp git gnome-software-plugin-flatpak gparted hexchat htop idle3 ipcalc krita libreoffice make network-manager-gnome network-manager-openvpn network-manager-pptp network-manager-strongswan network-manager-vpnc net-tools nload nmap openvpn openssh-server pssh python3 python3-pip python3-setuptools python3-venv screen steam terminator thunderbird tmux ttf-mscorefonts-installer vim wireshark
    echo -e "\n $greenplus Complete! \n"

    # Configures KDE shortcuts
    sed -i 's/Alt+F4/Alt+Q/' ~/.config/kglobalshortcutsrc
    sed -i 's/Meta+Ctrl+Right/Alt+Right/' ~/.config/kglobalshortcutsrc
    sed -i 's/Meta+Ctrl+Left/Alt+Left/' ~/.config/kglobalshortcutsrc
    echo -e "\n $greenplus KDE Shortcuts complete \n"
    sleep 2

    echo -e "\n $greenplus Installing timeshift \n"
    sudo apt-add-repository -y ppa:teejee2008/ppa >/dev/null 2>&1
    sudo apt update >/dev/null 2>&1
    sudo apt install -y timeshift >/dev/null 2>&1
    echo -e "\n $greenplus timeshift install complete \n"

    echo -e "\n $greenplus Installing Flatpak, Bitwarden, Tor Browser, and Onion Share \n"
    sleep 2
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo # Installs Flatpak plugin and adds Flathub Repo
    flatpak install -y flathub com.bitwarden.desktop                                          # Install Bitwarden Password Manager
    flatpak install -y flathub com.github.micahflee.torbrowser-launcher                       # Installs Tor Browser
    flatpak install -y flathub org.onionshare.OnionShare                                      # Install Onion Share
    echo -e "\n $greenplus Complete \n \n"
    sleep 2

    echo -e "\n $greenplus Installing Yubico Authenticator \n"
    sudo add-apt-repository -y ppa:yubico/stable >/dev/null 2>&1
    sudo apt update >/dev/null 2>&1
    sudo apt install -y yubioath-desktop >/dev/null 2>&1
    echo -e "\n $greenplus yubico install complete \n \n"
    sleep 2

    echo -e "\n $greenplus Tnstalling sublime text editor"
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    sudo apt install -y apt-transport-https
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y sublime-text
    echo -e "\n $greenplus sublime install complete \n"
    sleep 2

    # Installs Veracrypt
    sudo apt --fix-broken install
    wget https://launchpad.net/veracrypt/trunk/1.24-update7/+download/veracrypt-1.24-Update7-Ubuntu-20.04-amd64.deb
    sudo dpkg -i veracrypt-1.24-Update7-Ubuntu-20.04-amd64.deb; sudo apt -y install -f
    rm veracrypt*

    # Installs Element Chat Client
    sudo apt install -y wget apt-transport-https
    sudo wget -O /usr/share/keyrings/riot-im-archive-keyring.gpg https://packages.riot.im/debian/riot-im-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/riot-im-archive-keyring.gpg] https://packages.riot.im/debian/ default main" | sudo tee /etc/apt/sources.list.d/riot-im.list
    sudo apt update
    sudo apt -y install element-desktop

    # Installs Signal Desktop
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
    cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
    sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
    sudo apt update && sudo apt -y install signal-desktop

    # Installs Fusuma for touchpad Gestures
    sudo gpasswd -a $USER input
    newgrp input
    sudo apt install -y libinput-tools ruby xdotool
    sudo gem install fusuma
    mkdir /home/$USER/.config/fusuma
    echo -e "\n $greenplus fusuma complete \n"
    sleep 2

    clear
    echo -e "All finished! Reboot to apply all changes"
    }

check_de