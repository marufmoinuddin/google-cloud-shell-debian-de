#!/bin/bash

# Color definitions
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
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
    printf "\r${CYAN}Progress: ["
    printf "%${completed}s" | tr ' ' '#'
    printf "%${remaining}s" | tr ' ' '-'
    printf "] %d%%${NC}" "$percent"
    tput cup "$(tput lines)" 0 # Move cursor to bottom
}

# Function to print step with color
print_step() {
    ((CURRENT_STEP++))
    echo -e "${GREEN}Step $CURRENT_STEP/$TOTAL_STEPS: $1${NC}"
    show_progress
}

# Trap to ensure progress bar stays at bottom on exit
trap 'tput cnorm; echo' EXIT

# Hide cursor for cleaner output
tput civis

# Print the menu for desktop environment selection
print_step "Selecting Desktop Environment"
echo -e "${YELLOW}Select a desktop environment:${NC}"
echo "1. KDE Plasma"
echo "2. Xfce"
echo "3. UKUI"
echo -n "Enter your choice (1/2/3) [default is KDE]: "
read -t 10 choice
choice=${choice:-1} # Default to KDE if no input

# Ensure .config directory exists
print_step "Checking and creating .config directory"
config_dir="$HOME/.config"
[ ! -d "$config_dir" ] && mkdir -p "$config_dir"

# Add ngrok repository
print_step "Adding ngrok repository"
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list

# Add Visual Studio Code repository
print_step "Adding Visual Studio Code repository"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
rm -f packages.microsoft.gpg

# Add OneDrive repository and install GUI
print_step "Setting up OneDrive and GUI"
wget -qO - https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/obs-onedrive.gpg >/dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/obs-onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/ ./" | sudo tee /etc/apt/sources.list.d/onedrive.list
wget -O /tmp/OneDriveGUI.AppImage https://github.com/bpozdena/OneDriveGUI/releases/download/v1.0.2/OneDriveGUI-1.0.2-x86_64.AppImage
chmod +x /tmp/OneDriveGUI.AppImage
mkdir -p ~/.local/share/applications
cat <<EOL > ~/.local/share/applications/onedrivegui.desktop
[Desktop Entry]
Name=OneDriveGUI
Exec=/tmp/OneDriveGUI.AppImage
Type=Application
Categories=Utility;
EOL
chmod +x ~/.local/share/applications/onedrivegui.desktop

# Update package list and install base packages
print_step "Updating package list and installing base packages"
sudo apt update -y
sudo apt install -y fonts-lohit-beng-bengali onedrive ngrok nemo code firefox-esr mesa-utils pv nmap nano dialog autocutsel dbus-x11 neofetch p7zip-full unzip zip tigervnc-standalone-server novnc python3-websockify

# Configure VNC environment
print_step "Configuring VNC environment"
export HOME="$(pwd)"
export DISPLAY=":0"
mkdir -p "$HOME/.vnc"
chmod 755 "$HOME/.vnc"

# Install selected desktop environment
print_step "Installing selected desktop environment"
case "$choice" in
    1)
        echo -e "${BLUE}Installing KDE Plasma...${NC}"
        sudo apt install -y kde-plasma-desktop ark konsole gwenview kate okular
        echo -e '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nstartplasma-x11' > "$HOME/.vnc/xstartup"
        ;;
    2)
        echo -e "${BLUE}Installing Xfce...${NC}"
        sudo apt install -y xfce4 xfce4-goodies papirus-icon-theme terminator
        echo -e '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nxfce4-session' > "$HOME/.vnc/xstartup"
        ;;
    3)
        echo -e "${BLUE}Installing UKUI...${NC}"
        sudo apt install -y ukui-settings-daemon ukui-desktop-environment ukwm qt5-ukui-platformtheme kylin-nm
        echo -e '#!/bin/bash\nexport GTK_IM_MODULE="fcitx"\nexport QT_IM_MODULE="fcitx"\nexport XMODIFIERS="@im=fcitx"\nlightdm &\nexec /usr/bin/ukui-session' > "$HOME/.vnc/xstartup"
        ;;
    *)
        echo -e "${RED}Invalid choice, defaulting to KDE Plasma...${NC}"
        sudo apt install -y kde-plasma-desktop ark konsole gwenview kate okular
        echo -e '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nstartplasma-x11' > "$HOME/.vnc/xstartup"
        ;;
esac
chmod +x "$HOME/.vnc/xstartup"

# Install Windows-10-Dark theme
print_step "Installing Windows-10-Dark theme"
if [ ! -d /usr/share/themes/Windows-10-Dark-master ]; then
    cd /tmp
    wget -q https://github.com/B00merang-Project/Windows-10-Dark/releases/download/v2.3/Windows-10-Dark-master.zip
    sudo unzip -q Windows-10-Dark-master.zip -d /usr/share/themes/
    rm -f Windows-10-Dark-master.zip
fi

# Install WPS Office
print_step "Installing WPS Office"
cd /tmp
wget -q https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11723/wps-office_11.1.0.11723.XA_amd64.deb
sudo apt install -y ./wps-office_11.1.0.11723.XA_amd64.deb
rm -f wps-office_11.1.0.11723.XA_amd64.deb

# Final cleanup and permissions
print_step "Finalizing installation"
sudo chmod -R 777 "$HOME/.vnc" "$HOME/.config"
sudo apt autoremove -y

# Completion message
print_step "Installation completed"
echo -e "${GREEN}Installation completed successfully!${NC}"
echo -e "${YELLOW}Type 'vps' to start the VNC server.${NC}"

# Restore cursor visibility
tput cnorm
exit 0