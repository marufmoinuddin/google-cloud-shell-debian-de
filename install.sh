#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Progress bar function
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percent=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r${YELLOW}Progress: ["
    printf "%${completed}s" | tr ' ' '#'
    printf "%${remaining}s" | tr ' ' '-'
    printf "] %d%%${NC}" $percent
}

# Total steps
TOTAL_STEPS=12
CURRENT_STEP=0

# Function to print step
print_step() {
    ((CURRENT_STEP++))
    echo -e "${BLUE}Step $CURRENT_STEP/$TOTAL_STEPS: $1${NC}"
    show_progress $CURRENT_STEP $TOTAL_STEPS
    echo ""
}

# Trap to ensure clean exit
trap 'echo -e "\n${RED}Script interrupted${NC}"; exit 1' INT TERM

# Menu for desktop environment selection
echo -e "${GREEN}=== Desktop Environment Selection ===${NC}"
echo "1. KDE Plasma"
echo "2. Xfce"
echo "3. UKUI"
echo -n "Enter your choice (1-3) [default: 1]: "
read -t 10 choice
choice=${choice:-1}

# Create .config directory if it doesn't exist
[ ! -d "$HOME/.config" ] && mkdir -p "$HOME/.config"

print_step "Updating system and adding repositories"
sudo apt update -y &>/dev/null
# Add ngrok repository
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list >/dev/null
# Add VS Code repository
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/vscode.gpg >/dev/null
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

print_step "Installing base packages"
sudo apt install -y fonts-lohit-beng-bengali ngrok nemo code apt-transport-https firefox-esr mesa-utils pv nmap nano dialog autocutsel dbus-x11 dbus neofetch p7zip-full unzip zip tigervnc-standalone-server novnc python3-websockify >/dev/null 2>&1

print_step "Setting up VNC environment"
export HOME="$(pwd)"
export DISPLAY=":0"
[ -d "$HOME/.vnc" ] && rm -rf "$HOME/.vnc"
mkdir -p "$HOME/.vnc"

print_step "Installing selected desktop environment"
case $choice in
    1)
        echo -e "${GREEN}Installing KDE Plasma...${NC}"
        sudo apt install -y ark konsole gwenview kate okular kde-plasma-desktop >/dev/null 2>&1
        echo -e '#!/bin/bash\ndbus-launch &>/dev/null\nautocutsel -fork\nstartplasma-x11' > "$HOME/.vnc/xstartup"
        ;;
    2)
        echo -e "${GREEN}Installing Xfce...${NC}"
        sudo apt install -y papirus-icon-theme xfce4 xfce4-goodies terminator >/dev/null 2>&1
        echo -e '#!/bin/bash\ndbus-launch &>/dev/null\nautocutsel -fork\nxfce4-session' > "$HOME/.vnc/xstartup"
        ;;
    3)
        echo -e "${GREEN}Installing UKUI...${NC}"
        sudo apt install -y ukui-* ukwm qt5-ukui-platformtheme kylin-nm >/dev/null 2>&1
        echo -e '#!/bin/bash\nexport GTK_IM_MODULE="fcitx"\nexport QT_IM_MODULE="fcitx"\nexport XMODIFIERS="@im=fcitx"\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nlightdm &\nexec /usr/bin/ukui-session' > "$HOME/.vnc/xstartup"
        ;;
    *)
        echo -e "${YELLOW}Invalid choice, defaulting to KDE Plasma${NC}"
        sudo apt install -y ark konsole gwenview kate okular kde-plasma-desktop >/dev/null 2>&1
        echo -e '#!/bin/bash\ndbus-launch &>/dev/null\nautocutsel -fork\nstartplasma-x11' > "$HOME/.vnc/xstartup"
        ;;
esac
chmod +x "$HOME/.vnc/xstartup"

print_step "Configuring permissions"
chmod -R 777 "$HOME/.vnc" "$HOME/.config" 2>/dev/null

print_step "Installing OneDrive"
wget -qO - https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/obs-onedrive.gpg >/dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/obs-onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/ ./" | sudo tee /etc/apt/sources.list.d/onedrive.list >/dev/null
sudo apt update -y &>/dev/null
sudo apt install -y onedrive >/dev/null 2>&1

print_step "Installing OneDrive GUI"
wget -qO /tmp/OneDriveGUI.AppImage https://github.com/bpozdena/OneDriveGUI/releases/download/v1.0.3/OneDriveGUI-1.0.3-x86_64.AppImage
chmod +x /tmp/OneDriveGUI.AppImage
cat > "$HOME/.local/share/applications/onedrivegui.desktop" <<EOL
[Desktop Entry]
Name=OneDriveGUI
Exec=/tmp/OneDriveGUI.AppImage
Type=Application
Categories=Utility;
EOL
chmod +x "$HOME/.local/share/applications/onedrivegui.desktop"

print_step "Installing WPS Office"
wget -qO /tmp/wps-office.deb https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11720/wps-office_11.1.0.11720.XA_amd64.deb
sudo apt install -y /tmp/wps-office.deb >/dev/null 2>&1

print_step "Setting up VPS script"
[ -f "./vps.sh" ] && sudo mv ./vps.sh /usr/bin/vps && sudo chmod +x /usr/bin/vps

print_step "Configuring theme"
if [ ! -d /usr/share/themes/Windows-10-Dark-master ]; then
    cd /usr/share/themes/
    [ -f "$HOME/Windows-10-Dark-master.zip" ] && sudo unzip -q "$HOME/Windows-10-Dark-master.zip" && sudo rm -f Windows-10-Dark-master.zip
fi

print_step "Updating .bashrc"
[ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc_old"
[ -f "./bashrc.sh" ] && cp "./bashrc.sh" "$HOME/.bashrc" && chmod 777 "$HOME/.bashrc"

print_step "Cleaning up"
sudo apt autoremove -y &>/dev/null
rm -f /tmp/*.deb /tmp/*.AppImage packages.microsoft.gpg

echo -e "\n${GREEN}=== Installation Completed Successfully! ===${NC}"
echo "Type 'vps' to start the VNC Server"
exit 0