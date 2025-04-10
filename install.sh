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

# Total steps for progress bar
TOTAL_STEPS=12
CURRENT_STEP=0

# Print header
echo -e "${BLUE}=== Ubuntu 24.04 Desktop Environment Installer ===${NC}\n"

# Desktop environment selection
echo -e "${GREEN}Select a desktop environment:${NC}"
echo "1. KDE Plasma"
echo "2. Xfce"
echo "3. UKUI"
echo -n "Enter your choice (1/2/3) [default: KDE]: "
read -t 10 choice
choice=${choice:-1}
((CURRENT_STEP++))

# Ensure .config directory exists
config_dir="$HOME/.config"
[ ! -d "$config_dir" ] && mkdir -p "$config_dir"

# Start installation
echo -e "\n${BLUE}[Step $CURRENT_STEP/$TOTAL_STEPS] Preparing installation...${NC}"
show_progress $CURRENT_STEP $TOTAL_STEPS

# Update and install base packages
((CURRENT_STEP++))
echo -e "\n${BLUE}[Step $CURRENT_STEP/$TOTAL_STEPS] Updating system and installing base packages...${NC}"
sudo apt update -qq && sudo apt upgrade -y -qq
sudo apt install -y -qq curl wget gnupg software-properties-common
show_progress $CURRENT_STEP $TOTAL_STEPS

# Add repositories
((CURRENT_STEP++))
echo -e "\n${BLUE}[Step $CURRENT_STEP/$TOTAL_STEPS] Configuring repositories...${NC}"
# Ngrok
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list

# VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
rm packages.microsoft.gpg

# OneDrive
wget -qO - https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/obs-onedrive.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/obs-onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/ ./" | sudo tee /etc/apt/sources.list.d/onedrive.list
show_progress $CURRENT_STEP $TOTAL_STEPS

# Install core applications
((CURRENT_STEP++))
echo -e "\n${BLUE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing core applications...${NC}"
sudo apt update -qq
sudo apt install -y -qq fonts-lohit-beng-bengali onedrive ngrok nemo code firefox-esr mesa-utils pv nmap nano dialog \
    autocutsel dbus-x11 neofetch p7zip-full unzip zip tigervnc-standalone-server novnc python3-websockify
show_progress $CURRENT_STEP $TOTAL_STEPS

# Install OneDrive GUI
((CURRENT_STEP++))
echo -e "\n${BLUE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing OneDrive GUI...${NC}"
wget -q -O /tmp/OneDriveGUI.AppImage https://github.com/bpozdena/OneDriveGUI/releases/download/v1.0.2/OneDriveGUI-1.0.2-x86_64.AppImage
chmod +x /tmp/OneDriveGUI.AppImage
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/onedrivegui.desktop << EOL
[Desktop Entry]
Name=OneDriveGUI
Exec=/tmp/OneDriveGUI.AppImage
Type=Application
Categories=Utility;
Terminal=false
EOL
chmod +x ~/.local/share/applications/onedrivegui.desktop
show_progress $CURRENT_STEP $TOTAL_STEPS

# Install selected desktop environment
((CURRENT_STEP++))
echo -e "\n${BLUE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing desktop environment...${NC}"
case $choice in
    1)
        echo -e "${GREEN}Installing KDE Plasma...${NC}"
        sudo apt install -y -qq kde-plasma-desktop ark konsole gwenview kate okular
        echo -e '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nstartplasma-x11' > "$HOME/.vnc/xstartup"
        ;;
    2)
        echo -e "${GREEN}Installing Xfce...${NC}"
        sudo apt install -y -qq xfce4 xfce4-goodies papirus-icon-theme terminator
        echo -e '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nxfce4-session' > "$HOME/.vnc/xstartup"
        ;;
    3)
        echo -e "${GREEN}Installing UKUI...${NC}"
        sudo apt install -y -qq ukui-settings-daemon ukui-desktop-environment ukwm qt5-ukui-platformtheme kylin-nm
        echo -e '#!/bin/bash\nexport GTK_IM_MODULE="fcitx"\nexport QT_IM_MODULE="fcitx"\nexport XMODIFIERS="@im=fcitx"\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nlightdm &\nexec /usr/bin/ukui-session' > "$HOME/.vnc/xstartup"
        ;;
    *)
        echo -e "${YELLOW}Invalid choice, installing KDE Plasma as default...${NC}"
        sudo apt install -y -qq kde-plasma-desktop ark konsole gwenview kate okular
        echo -e '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nstartplasma-x11' > "$HOME/.vnc/xstartup"
        ;;
esac
chmod +x "$HOME/.vnc/xstartup"
show_progress $CURRENT_STEP $TOTAL_STEPS

# Configure VNC
((CURRENT_STEP++))
echo -e "\n${BLUE}[Step $CURRENT_STEP/$TOTAL_STEPS] Configuring VNC...${NC}"
mkdir -p "$HOME/.vnc"
chmod -R 777 "$HOME/.vnc" "$HOME/.config"
export DISPLAY=":0"
show_progress $CURRENT_STEP $TOTAL_STEPS

# Install WPS Office
((CURRENT_STEP++))
echo -e "\n${BLUE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing WPS Office...${NC}"
wget -q -P /tmp https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11723/wps-office_11.1.0.11723.XA_amd64.deb
sudo apt install -y -qq /tmp/wps-office_11.1.0.11723.XA_amd64.deb
show_progress $CURRENT_STEP $TOTAL_STEPS

# Install Windows 10 Dark theme
((CURRENT_STEP++))
echo -e "\n${BLUE}[Step $CURRENT_STEP/$TOTAL_STEPS] Installing Windows 10 Dark theme...${NC}"
if [ ! -d /usr/share/themes/Windows-10-Dark ]; then
    wget -q -P /tmp https://github.com/B00merang-Project/Windows-10-Dark/releases/download/v2.3/Windows-10-Dark.tar.xz
    sudo tar -xf /tmp/Windows-10-Dark.tar.xz -C /usr/share/themes/
fi
show_progress $CURRENT_STEP $TOTAL_STEPS

# Final cleanup
((CURRENT_STEP++))
echo -e "\n${BLUE}[Step $CURRENT_STEP/$TOTAL_STEPS] Performing cleanup...${NC}"
sudo apt autoremove -y -qq
sudo apt autoclean -y -qq
rm -rf /tmp/*.deb /tmp/*.AppImage
show_progress $CURRENT_STEP $TOTAL_STEPS

# Completion message
((CURRENT_STEP++))
echo -e "\n${GREEN}=== Installation Completed Successfully! ===${NC}"
echo "Start VNC server by running: vncserver"
echo "Access via noVNC at: http://localhost:6080/vnc.html"
show_progress $TOTAL_STEPS $TOTAL_STEPS
echo -e "\n"
exit 0