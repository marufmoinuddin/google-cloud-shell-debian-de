#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Progress bar variables
TOTAL_STEPS=12
CURRENT_STEP=0

# Function to display progress bar
show_progress() {
    local width=50
    local percent=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local completed=$((width * CURRENT_STEP / TOTAL_STEPS))
    local remaining=$((width - completed))
    printf "\r${YELLOW}Progress: ["
    printf "%${completed}s" | tr ' ' '#'
    printf "%${remaining}s" | tr ' ' '-'
    printf "] %d%%${NC}" "$percent"
}

# Function to print step with color
print_step() {
    ((CURRENT_STEP++))
    echo -e "${BLUE}Step ${CURRENT_STEP}/${TOTAL_STEPS}: $1${NC}"
    show_progress
    echo ""
}

# Trap to ensure progress bar stays at bottom
trap 'echo -ne "\033[?25h"; tput cup $(tput lines) 0' EXIT

# Hide cursor
echo -ne "\033[?25l"

print_step "Initializing setup"
# Create .config directory if it doesn't exist
config_dir="$HOME/.config"
[ ! -d "$config_dir" ] && mkdir -p "$config_dir"

# Desktop environment selection with default timeout
print_step "Selecting desktop environment"
echo "1. KDE Plasma"
echo "2. Xfce"
echo "3. UKUI"
echo -n "Enter your choice (1/2/3) [default KDE, 10s timeout]: "
read -t 10 choice
choice=${choice:-1}

print_step "Updating package sources"
# Backup sources.list
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

# Add repositories (optimized for Ubuntu 24.04)
sudo apt-get update -qq
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:ngrok/ngrok
sudo curl -s https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

print_step "Installing base packages"
sudo apt-get update -qq
sudo apt-get install -y \
    fonts-lohit-beng-bengali ngrok nemo code firefox-esr mesa-utils \
    pv nmap nano dialog autocutsel dbus-x11 neofetch p7zip-full unzip zip \
    tigervnc-standalone-server novnc python3-websockify

print_step "Setting up OneDrive"
# OneDrive setup optimized for Ubuntu 24.04
wget -qO - https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_24.04/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/obs-onedrive.gpg >/dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/obs-onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_24.04/ ./" | sudo tee /etc/apt/sources.list.d/onedrive.list
sudo apt-get update -qq
sudo apt-get install -y onedrive
wget -O /tmp/OneDriveGUI.AppImage https://github.com/bpozdena/OneDriveGUI/releases/download/v1.0.2/OneDriveGUI-1.0.2-x86_64.AppImage
chmod +x /tmp/OneDriveGUI.AppImage
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/onedrivegui.desktop << EOL
[Desktop Entry]
Name=OneDriveGUI
Exec=/tmp/OneDriveGUI.AppImage
Type=Application
Categories=Utility;
EOL
chmod +x ~/.local/share/applications/onedrivegui.desktop

print_step "Installing desktop environment"
# VNC setup
mkdir -p "$HOME/.vnc"
case "$choice" in
    1)
        echo -e "${GREEN}Installing KDE Plasma${NC}"
        sudo apt-get install -y kde-plasma-desktop ark konsole gwenview kate okular
        cat > "$HOME/.vnc/xstartup" << EOL
#!/bin/bash
dbus-launch &>/dev/null
autocutsel -fork
startplasma-x11
EOL
        ;;
    2)
        echo -e "${GREEN}Installing Xfce${NC}"
        sudo apt-get install -y xfce4 xfce4-goodies papirus-icon-theme terminator
        cat > "$HOME/.vnc/xstartup" << EOL
#!/bin/bash
dbus-launch &>/dev/null
autocutsel -fork
xfce4-session
EOL
        ;;
    3)
        echo -e "${GREEN}Installing UKUI${NC}"
        sudo add-apt-repository -y ppa:ubuntukylin-members/ukui
        sudo apt-get update -qq
        sudo apt-get install -y ukui-desktop-environment
        cat > "$HOME/.vnc/xstartup" << EOL
#!/bin/bash
export GTK_IM_MODULE="fcitx"
export QT_IM_MODULE="fcitx"
export XMODIFIERS="@im=fcitx"
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec ukui-session
EOL
        ;;
    *)
        echo -e "${YELLOW}Invalid choice, defaulting to KDE${NC}"
        sudo apt-get install -y kde-plasma-desktop ark konsole gwenview kate okular
        cat > "$HOME/.vnc/xstartup" << EOL
#!/bin/bash
dbus-launch &>/dev/null
autocutsel -fork
startplasma-x11
EOL
        ;;
esac
chmod +x "$HOME/.vnc/xstartup"

print_step "Configuring VNC"
chmod -R 777 "$HOME/.vnc"
export HOME="$(pwd)"
export DISPLAY=":0"

print_step "Installing Windows 10 Dark theme"
if [ ! -d /usr/share/themes/Windows-10-Dark ]; then
    wget -q https://github.com/B00merang-Project/Windows-10-Dark/releases/download/v2.2/Windows-10-Dark.tar.xz
    sudo tar -xf Windows-10-Dark.tar.xz -C /usr/share/themes/
    rm Windows-10-Dark.tar.xz
fi

print_step "Installing WPS Office"
wget -q https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11719/wps-office_11.1.0.11719.XA_amd64.deb
sudo dpkg -i wps-office_11.1.0.11719.XA_amd64.deb
sudo apt-get install -f -y
rm wps-office_11.1.0.11719.XA_amd64.deb

print_step "Configuring shell"
[ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc_old"
echo "neofetch" > "$HOME/.bashrc"
chmod 777 "$HOME/.bashrc"

print_step "Cleaning up"
sudo apt-get autoremove -y -qq
sudo apt-get autoclean -y -qq

print_step "Installation complete"
echo -e "${GREEN}Setup completed successfully!${NC}"
echo "Type 'vncserver' to start the VNC server"

# Show final progress and restore cursor
CURRENT_STEP=$TOTAL_STEPS
show_progress
echo -e "\n"
echo -ne "\033[?25h"
exit 0