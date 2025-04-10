#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print step messages
print_step() {
    echo -e "${BLUE}[STEP]${NC} ${GREEN}$1${NC}"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Print the menu for desktop environment selection
echo -e "${YELLOW}Please select a desktop environment to install:${NC}"
echo "1. KDE Plasma (default)"
echo "2. Xfce"
echo "3. UKUI"
echo -e "${YELLOW}You have 10 seconds to make a choice. Press Enter to select the default (1).${NC}"
echo -e "${YELLOW}Enter your choice (1-3):${NC}"
# Set timeout for user input (5 seconds)
read -t 10 choice

# Set default choice if timeout occurs or invalid input is given
if [ -z "$choice" ]; then
    choice="1"
fi

print_step "Checking system configuration..."
# Check if .config directory exists
config_dir="$HOME/.config"
if [ ! -d "$config_dir" ]; then
  print_warning "The .config directory does not exist. Creating it..."
  mkdir -p "$config_dir"
fi


# Print initial message
echo -e "${BLUE}[INFO]${NC} Starting installation..."
echo -e "${YELLOW}This script will install a desktop environment on your Google Cloud Shell instance.${NC}"
echo -e "${BLUE}Please note that this may take some time and will require some manual interaction.${NC}"
echo -e "${YELLOW}Press Ctrl+C to cancel the installation.${NC}"


print_step "Adding repositories..."

# Direct ngrok installation if repository doesn't work
wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O /tmp/ngrok.tgz
sudo tar -xzf /tmp/ngrok.tgz -C /usr/local/bin

# Add Visual Studio Code repository 
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# Add OneDrive repository
wget -qO - https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/obs-onedrive.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/obs-onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/ ./" | sudo tee /etc/apt/sources.list.d/onedrive.list

# Backup existing sources.list
print_step "Backing up existing sources.list..."
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

# Update and install base packages
print_step "Updating package list and installing base packages..."
sudo apt update && sudo apt install -y software-properties-common
sudo add-apt-repository universe
sudo apt update && sudo apt install -y \
    fonts-lohit-beng-bengali \
    onedrive \
    nemo \
    code \
    firefox \
    mesa-utils \
    pv \
    nmap \
    nano \
    dialog \
    autocutsel \
    dbus-x11 \
    dbus \
    neofetch \
    p7zip-full \
    unzip \
    zip \
    tigervnc-standalone-server \
    tigervnc-xorg-extension \
    novnc \
    python3-websockify

# Set up environment
export DISPLAY=":0"
sudo rm -rf "$HOME/.vnc"
sudo mkdir -p "$HOME/.vnc"

# Install selected desktop environment
if [ "$choice" = "1" ]; then
    # KDE installation
    print_step "Installing KDE Plasma..."
    sudo apt install -y kde-plasma-desktop ark konsole gwenview kate okular
    sudo apt remove -y kdeconnect
    printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nstartplasma-x11\n' > "$HOME/.vnc/xstartup"

elif [ "$choice" = "2" ]; then
    # Xfce installation
    print_step "Installing Xfce..."
    sudo apt install -y xfce4 xfce4-goodies papirus-icon-theme terminator
    printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nxfce4-session\n' > "$HOME/.vnc/xstartup"
    backup_dir="$HOME/google-cloud-shell-debian-de/xfce4_backup"
    cp -R "$backup_dir"/* "$config_dir" || echo "Warning: Could not copy backup files"

elif [ "$choice" = "3" ]; then
    # UKUI installation
    print_step "Installing UKUI..."
    sudo apt install -y ukui-desktop-environment
    printf '#!/bin/bash\nexport GTK_IM_MODULE="fcitx"\nexport QT_IM_MODULE="fcitx"\nexport XMODIFIERS="@im=fcitx"\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nxrdb $HOME/.Xresources\nexec ukui-session\n' > "$HOME/.vnc/xstartup"
else
    # Default to KDE if invalid choice
    print_warning "Invalid choice. Defaulting to KDE."
    sudo apt install -y kde-plasma-desktop ark konsole gwenview kate okular
    printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nstartplasma-x11\n' > "$HOME/.vnc/xstartup"
fi

# Set permissions
print_step "Setting permissions..."
chmod 755 "$HOME/.vnc/xstartup"
chmod -R 777 "$HOME/.config"
sudo mv ./vps.sh /usr/bin/vps
sudo chmod +x /usr/bin/vps

# Install Windows 10 theme
print_step "Installing Windows 10 theme..."
if [ ! -d /usr/share/themes/Windows-10-Dark-master ]; then
    cd /usr/share/themes/ || exit 1
    sudo cp "$HOME/google-cloud-shell-debian-de/app/Windows-10-Dark-master.zip" ./
    sudo unzip -qq Windows-10-Dark-master.zip
    sudo rm -f Windows-10-Dark-master.zip
fi

# Update bashrc
print_step "Updating .bashrc..."
cd "$HOME" || exit 1
sudo mv "$HOME/.bashrc" "$HOME/.bashrc_old"
sudo cp "$HOME/google-cloud-shell-debian-de/bashrc.sh" "$HOME/.bashrc"
sudo chmod 777 "$HOME/.bashrc"

# Install WPS Office
# wget -O /tmp/wps-office.deb https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11701/wps-office_11.1.0.11701.XA_amd64.deb
# sudo apt install -y /tmp/wps-office.deb

# Cleanup
print_step "Cleaning up..."
sudo apt update -y
sudo apt autoremove -y
sudo apt clean

echo -e "${GREEN}Installation completed successfully!${NC}"
echo -e "${YELLOW}Type 'vps' to start the VNC server.${NC}"
exit 0