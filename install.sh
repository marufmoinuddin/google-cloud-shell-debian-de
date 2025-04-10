#!/bin/bash

# Define color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Progress bar variables
TOTAL_STEPS=12
CURRENT_STEP=0

# Function to update progress bar
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    BAR_WIDTH=50
    FILLED=$((PERCENT * BAR_WIDTH / 100))
    UNFILLED=$((BAR_WIDTH - FILLED))
    printf "\r\033[999B${CYAN}Progress: ["
    printf "%${FILLED}s" | tr ' ' '#'
    printf "%${UNFILLED}s" | tr ' ' '-'
    printf "] %d%%${NC}" "$PERCENT"
}

# Trap to ensure progress bar stays at bottom
trap 'tput cnorm' EXIT
tput civis # Hide cursor

# Clear screen and start progress bar
clear
echo -e "${BLUE}Starting installation process...${NC}"
update_progress &

# Step 1: Desktop environment selection
echo -e "${YELLOW}Step 1: Select a desktop environment${NC}"
echo "1. KDE Plasma"
echo "2. Xfce"
echo "3. UKUI"
echo -n "Enter your choice (1/2/3) [default is KDE]: "
read -t 10 choice
choice=${choice:-1}
update_progress

# Step 2: Create .config directory if it doesn't exist
echo -e "${YELLOW}Step 2: Checking .config directory${NC}"
CONFIG_DIR="$HOME/.config"
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${GREEN}Creating $CONFIG_DIR...${NC}"
    mkdir -p "$CONFIG_DIR"
fi
update_progress

# Step 3: Add repositories and keys
echo -e "${YELLOW}Step 3: Adding repositories${NC}"
# Ngrok repository
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list

# Visual Studio Code repository
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
rm -f packages.microsoft.gpg

# OneDrive repository (adjusted for Ubuntu 24.04)
wget -qO - https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/obs-onedrive.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/obs-onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/ ./" | sudo tee /etc/apt/sources.list.d/onedrive.list
update_progress

# Step 4: Install dependencies for OneDrive GUI
echo -e "${YELLOW}Step 4: Installing OneDrive GUI dependencies${NC}"
sudo apt update
sudo apt install -y libllvm10 libphobos2-ldc-shared98 || {
    echo -e "${RED}Failed to install dependencies, attempting fallback...${NC}"
    wget -P /tmp http://archive.ubuntu.com/ubuntu/pool/universe/l/ldc/libphobos2-ldc-shared98_1.28.0-1ubuntu1_amd64.deb
    wget -P /tmp http://archive.ubuntu.com/ubuntu/pool/main/l/llvm-toolchain-14/libllvm14_14.0.0-1ubuntu1_amd64.deb
    sudo apt install -y /tmp/libllvm14_14.0.0-1ubuntu1_amd64.deb /tmp/libphobos2-ldc-shared98_1.28.0-1ubuntu1_amd64.deb
}
wget -O /tmp/OneDriveGUI-1.0.2-x86_64.AppImage https://github.com/bpozdena/OneDriveGUI/releases/download/v1.0.2/OneDriveGUI-1.0.2-x86_64.AppImage
chmod +x /tmp/OneDriveGUI-1.0.2-x86_64.AppImage
mkdir -p ~/.local/share/applications
cat <<EOL > ~/.local/share/applications/onedrivegui.desktop
[Desktop Entry]
Name=OneDriveGUI
Exec=/tmp/OneDriveGUI-1.0.2-x86_64.AppImage
Type=Application
Categories=Utility;
EOL
chmod +x ~/.local/share/applications/onedrivegui.desktop
update_progress

# Step 5: Backup sources.list
echo -e "${YELLOW}Step 5: Backing up sources.list${NC}"
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
update_progress

# Step 6: Install base packages
echo -e "${YELLOW}Step 6: Installing base packages${NC}"
sudo apt install -y fonts-lohit-beng-bengali onedrive ngrok nemo code apt-transport-https firefox-esr mesa-utils pv nmap nano dialog autocutsel dbus-x11 dbus neofetch p7zip-full unzip zip tigervnc-standalone-server tigervnc-xorg-extension novnc python3-websockify
update_progress

# Step 7: Install selected desktop environment
echo -e "${YELLOW}Step 7: Installing desktop environment${NC}"
case "$choice" in
    1)
        echo -e "${GREEN}Installing KDE Plasma...${NC}"
        sudo apt install -y kde-plasma-desktop ark konsole gwenview kate okular
        echo -e '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nstartplasma-x11' > "$HOME/.vnc/xstartup"
        ;;
    2)
        echo -e "${GREEN}Installing Xfce...${NC}"
        sudo apt install -y xfce4 xfce4-goodies papirus-icon-theme terminator
        echo -e '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nxfce4-session' > "$HOME/.vnc/xstartup"
        ;;
    3)
        echo -e "${GREEN}Installing UKUI...${NC}"
        sudo apt install -y ukui-desktop-environment ukwm qt5-ukui-platformtheme kylin-nm ukui-settings-daemon
        echo -e '#!/bin/bash\nexport GTK_IM_MODULE="fcitx"\nexport QT_IM_MODULE="fcitx"\nexport XMODIFIERS="@im=fcitx"\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nlightdm &\nexec /usr/bin/ukui-session' > "$HOME/.vnc/xstartup"
        ;;
    *)
        echo -e "${RED}Invalid choice, defaulting to KDE...${NC}"
        sudo apt install -y kde-plasma-desktop ark konsole gwenview kate okular
        echo -e '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nstartplasma-x11' > "$HOME/.vnc/xstartup"
        ;;
esac
chmod +x "$HOME/.vnc/xstartup"
update_progress

# Step 8: Configure VNC
echo -e "${YELLOW}Step 8: Configuring VNC${NC}"
mkdir -p "$HOME/.vnc"
chmod -R 777 "$HOME/.vnc" "$HOME/.config"
export HOME="$(pwd)"
export DISPLAY=":0"
update_progress

# Step 9: Install Windows-10-Dark theme
echo -e "${YELLOW}Step 9: Installing Windows-10-Dark theme${NC}"
if [ ! -d /usr/share/themes/Windows-10-Dark-master ]; then
    cd /usr/share/themes
    sudo wget -q https://github.com/B00merang-Project/Windows-10-Dark/releases/download/v2.2/Windows-10-Dark-master.zip
    sudo unzip -q Windows-10-Dark-master.zip
    sudo rm -f Windows-10-Dark-master.zip
fi
cd "$HOME"
update_progress

# Step 10: Update .bashrc
echo -e "${YELLOW}Step 10: Updating .bashrc${NC}"
[ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc_old"
echo -e "${GREEN}Backed up .bashrc as .bashrc_old${NC}"
echo "neofetch" > "$HOME/.bashrc" # Simplified for demo; replace with your bashrc.sh content
chmod 777 "$HOME/.bashrc"
update_progress

# Step 11: Install WPS Office
echo -e "${YELLOW}Step 11: Installing WPS Office${NC}"
cd /tmp
wget -q https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11723/wps-office_11.1.0.11723.XA_amd64.deb
sudo apt install -y ./wps-office_11.1.0.11723.XA_amd64.deb
update_progress

# Step 12: Final cleanup and setup
echo -e "${YELLOW}Step 12: Finalizing installation${NC}"
sudo apt update -y && sudo apt autoremove -y
sudo mv "$HOME/vps.sh" /usr/bin/vps 2>/dev/null || echo -e "${RED}vps.sh not found, skipping...${NC}"
sudo chmod +x /usr/bin/vps
update_progress

# Completion message
echo -e "${GREEN}Installation completed successfully!${NC}"
echo -e "${CYAN}Type 'vps' to start the VNC server.${NC}"
tput cnorm # Restore cursor
exit 0