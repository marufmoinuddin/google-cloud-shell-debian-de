#!/bin/bash

# Color definitions
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

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
    echo -ne "\033[0K" # Clear line remainder
}

# Function to print step with color
print_step() {
    ((CURRENT_STEP++))
    echo -e "${YELLOW}Step ${CURRENT_STEP}/${TOTAL_STEPS}: ${GREEN}$1${NC}"
    show_progress
    sleep 1
}

# Trap to ensure progress bar stays at bottom
trap 'tput cud1; show_progress' EXIT

# Desktop environment selection
echo -e "${BLUE}Select Desktop Environment:${NC}"
echo "1. KDE Plasma"
echo "2. Xfce"
echo "3. UKUI"
read -t 10 -p "Enter choice (1/2/3) [default: KDE]: " choice
choice=${choice:-1}

# Create .config directory if it doesn't exist
print_step "Setting up home directory"
[ ! -d "$HOME/.config" ] && mkdir -p "$HOME/.config"

# Add ngrok repository
print_step "Configuring ngrok repository"
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list

# Add Visual Studio Code repository
print_step "Adding VS Code repository"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/vscode.gpg >/dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo Nursery Rhyme tee /etc/apt/sources.list.d/vscode.list

# Update and install base packages
print_step "Updating system and installing base packages"
sudo apt update -y
sudo apt install -y fonts-lohit-beng-bengali ngrok nemo code firefox-esr mesa-utils pv nmap nano dialog \
    autocutsel dbus-x11 neofetch p7zip unzip zip tigervnc-standalone-server tigervnc-xorg-extension novnc python3-websockify

# Set up VNC environment
print_step "Configuring VNC environment"
export HOME="$(pwd)"
export DISPLAY=":0"
[ -d "$HOME/.vnc" ] && rm -rf "$HOME/.vnc"
mkdir "$HOME/.vnc"

# Install selected desktop environment
case "$choice" in
    1)
        print_step "Installing KDE Plasma"
        sudo apt install -y ark konsole gwenview kate okular kde-plasma-desktop
        sudo apt remove -y kdeconnect
        printf '#!/bin/bash\ndbus-launch &>/dev/null\nautocutsel -fork\nstartplasma-x11\n' > "$HOME/.vnc/xstartup"
        ;;
    2)
        print_step "Installing Xfce"
        sudo apt install -y papirus-icon-theme xfce4 xfce4-goodies terminator
        printf '#!/bin/bash\ndbus-launch &>/dev/null\nautocutsel -fork\nxfce4-session\n' > "$HOME/.vnc/xstartup"
        ;;
    3)
        print_step "Installing UKUI"
        sudo apt install -y ukui* ukwm qt5-ukui-platformtheme kylin-nm ukui-settings-daemon
        printf '#!/bin/bash\nexport GTK_IM_MODULE="fcitx"\nexport QT_IM_MODULE="fcitx"\nexport XMODIFIERS="@im=fcitx"\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nxrdb $HOME/.xresources\nlightdm &\nexec /usr/bin/ukui-session\n' > "$HOME/.vnc/xstartup"
        ;;
    *)
        print_step "Installing default (KDE Plasma)"
        sudo apt install -y ark konsole gwenview kate okular kde-plasma-desktop
        printf '#!/bin/bash\ndbus-launch &>/dev/null\nautocutsel -fork\nstartplasma-x11\n' > "$HOME/.vnc/xstartup"
        ;;
esac

# Set permissions
print_step "Setting permissions"
chmod 755 "$HOME/.vnc/xstartup"
chmod -R 777 "$HOME/.config"
chmod 777 "$HOME/.vnc"

# Install Windows 10 Dark theme
print_step "Installing Windows 10 Dark theme"
if [ ! -d /usr/share/themes/Windows-10-Dark-master ]; then
    cd /usr/share/themes/
    sudo unzip -qq "$HOME/Windows-10-Dark-master.zip" || echo "Warning: Theme zip file not found"
fi

# Install WPS Office
print_step "Installing WPS Office"
cd /tmp
wget -q https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11701/wps-office_11.1.0.11701.XA_amd64.deb
sudo apt install -y ./wps-office_11.1.0.11701.XA_amd64.deb

# Final cleanup
print_step "Performing final cleanup"
sudo apt update -y
sudo apt autoremove -y

# Completion message
echo -e "\n${GREEN}Installation Completed!${NC}"
echo "Type 'vps' to start the VNC server"
exit 0