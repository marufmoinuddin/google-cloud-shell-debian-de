#!/bin/bash

# Define color variables
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;96m'
MAGENTA='\033[1;35m'
RESET='\033[0m'
BOLD='\033[1m'

# Progress bar variables
TOTAL_STEPS=10
current_step=0

# Function to print step headers
print_step() {
  echo -e "\n${MAGENTA}===== ${CYAN}$1${MAGENTA} =====${RESET}"
  
}

# Clear screen and show welcome message
clear
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${BLUE}║                                                        ║${RESET}"
echo -e "${BOLD}${BLUE}║  ${GREEN}Ubuntu 24.04 Desktop Environment Installer${BLUE}             ║${RESET}"
echo -e "${BOLD}${BLUE}║  ${YELLOW}Optimized installation script for Cloud environments${BLUE}  ║${RESET}"
echo -e "${BOLD}${BLUE}║                                                        ║${RESET}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════╝${RESET}\n"

# Print the menu for desktop environment selection
print_step "Select a desktop environment"
echo -e "${YELLOW}1. ${GREEN}KDE ${RESET}- A complete, feature-rich desktop"
echo -e "${YELLOW}2. ${GREEN}Xfce ${RESET}- Lightweight and efficient desktop"
echo -e "${YELLOW}3. ${GREEN}UKUI ${RESET}- Modern and intuitive desktop"
echo -e "${CYAN}Enter your choice (1/2/3) [default is KDE]: ${RESET}"

# Set timeout for user input (10 seconds)
read -t 10 choice

# Set the default choice if timeout occurs or invalid input is given
if [ -z "$choice" ]; then
    choice="1"
    echo -e "${YELLOW}No input received. Defaulting to KDE.${RESET}"
fi

# Check if the .config directory exists
config_dir="$HOME/.config"
if [ ! -d "$config_dir" ]; then
  echo -e "${YELLOW}The .config directory does not exist. Creating it...${RESET}"
  mkdir -p "$config_dir"
fi

print_step "Setting up system repositories"
echo -e "${GREEN}Setting up Ngrok repository...${RESET}"
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null 
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list

echo -e "${GREEN}Setting up Visual Studio Code repository...${RESET}"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# Backup the existing sources.list
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

print_step "Updating package lists"
sudo apt update

print_step "Installing common packages"
sudo apt install -y fonts-lohit-beng-bengali ngrok nemo code apt-transport-https \
    firefox mesa-utils pv nmap nano dialog autocutsel dbus-x11 dbus neofetch \
    p7zip unzip zip tigervnc-standalone-server tigervnc-xorg-extension novnc python3-websockify

# Set some environment variables
print_step "Setting up environment"
cd .. || exit 1
export HOME="$(pwd)"
export DISPLAY=":0"
cd "$HOME" || exit 1
sudo rm -rf "$HOME/.vnc"
sudo mkdir -p "$HOME/.vnc"

# Install the selected desktop environment
print_step "Installing selected desktop environment"
if [ "$choice" = "1" ]; then
    # KDE installation
    echo -e "${GREEN}Installing KDE Plasma Desktop...${RESET}"
    sudo apt install -y ark konsole gwenview kate okular kde-plasma-desktop
    sudo apt remove -y kdeconnect
    sudo printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nstartplasma-x11\n' > "$HOME/.vnc/xstartup"
    echo -e "${GREEN}KDE installation completed!${RESET}"

elif [ "$choice" = "2" ]; then
    # Xfce installation
    echo -e "${GREEN}Installing Xfce Desktop...${RESET}"
    sudo apt install -y papirus-icon-theme xfce4 xfce4-goodies terminator
    printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nxfce4-session\n' > "$HOME/.vnc/xstartup"
    echo -e "${GREEN}Xfce installation completed!${RESET}"
    
elif [ "$choice" = "3" ]; then
    # UKUI installation
    echo -e "${GREEN}Installing UKUI Desktop...${RESET}"
    sudo apt install -y ukui-desktop-environment
    sudo cp $HOME/.Xauthority /root
    # Create or update the VNC startup script
    printf '#!/bin/bash\nexport GTK_IM_MODULE="fcitx"\nexport QT_IM_MODULE="fcitx"\nexport XMODIFIERS="@im=fcitx"\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nxrdb $HOME/.xresources\nlightdm &\nexec /usr/bin/ukui-session\n' > "$HOME/.vnc/xstartup"
    echo -e "${GREEN}UKUI installation completed!${RESET}"
else
    echo -e "${YELLOW}Invalid choice. Installing KDE by default...${RESET}"
    sudo apt install -y ark konsole gwenview kate okular kde-plasma-desktop
    printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nstartplasma-x11\n' > "$HOME/.vnc/xstartup"
    echo -e "${GREEN}KDE installation completed!${RESET}"
fi

chmod 755 $HOME/.vnc/xstartup

# Preparing VNC's desktop environment execution
print_step "Setting up VNC configuration"
if [ ! -d "$HOME/.config" ]; then
  sudo mkdir "$HOME/.config"
fi
chmod -R 777 "$HOME/.config"

# Make the VPS script executable and move it to the proper location
sudo mv $HOME/google-cloud-shell-debian-de/vps.sh /usr/bin/vps
sudo chmod +x /usr/bin/vps

# Setting permissions and cleaning up
print_step "Setting permissions and cleaning up"
sudo chmod 777 -R "$HOME/.vnc"
sudo chmod 777 "$HOME/.bashrc"

sudo mv $HOME/google-cloud-shell-debian-de/vps.sh /usr/bin/vps
sudo chmod +x /usr/bin/vps

sudo apt update -y
sudo apt autoremove -y

# Check and install Windows-10-Dark-master theme
print_step "Installing system theme"
if [ -f "$HOME/google-cloud-shell-debian-de/app/Windows-10-Dark-master.zip" ]; then
  if [ ! -d /usr/share/themes/Windows-10-Dark-master ]; then
    cd /usr/share/themes/ || exit 1
    sudo cp "$HOME/google-cloud-shell-debian-de/app/Windows-10-Dark-master.zip" ./
    sudo unzip -qq Windows-10-Dark-master.zip
    sudo rm -f Windows-10-Dark-master.zip
    echo -e "${GREEN}Windows 10 Dark theme installed successfully!${RESET}"
  else
    echo -e "${YELLOW}Theme already installed, skipping...${RESET}"
  fi
else
  echo -e "${YELLOW}Theme file not found, skipping...${RESET}"
fi
cd "$HOME" || exit 1

# Backup and update .bashrc
print_step "Configuring bash environment"
if [ -f "$HOME/.bashrc" ]; then
  sudo mv "$HOME/.bashrc" "$HOME/.bashrc_old"
  echo -e "${YELLOW}Your $HOME/.bashrc is being modified. Backed up the old .bashrc file as .bashrc_old${RESET}"
fi

if [ -f "$HOME/google-cloud-shell-debian-de/bashrc.sh" ]; then
  sudo cp "$HOME/google-cloud-shell-debian-de/bashrc.sh" "$HOME/.bashrc"
  sudo chmod 777 "$HOME/.bashrc"
  echo -e "${GREEN}New .bashrc configuration installed!${RESET}"
else
  echo -e "${YELLOW}Bashrc template not found, keeping default configuration...${RESET}"
fi

# Install WPS-Office
print_step "Installing additional software"
echo -e "${GREEN}Installing WPS Office...${RESET}"
cd /tmp
wget -q https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11701/wps-office_11.1.0.11701.XA_amd64.deb
sudo apt install -y ./wps-office_11.1.0.11701.XA_amd64.deb
echo -e "${GREEN}WPS Office installed successfully!${RESET}"

# Final step - update progress to 100%
current_step=$TOTAL_STEPS


# Installation completed message with proper centering and alignment
echo 
echo -e "${PAD_STR}${BOLD}${GREEN}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${PAD_STR}${BOLD}${GREEN}║                                                  ║${RESET}"
echo -e "${PAD_STR}${BOLD}${GREEN}║           Installation completed!                ║${RESET}"
echo -e "${PAD_STR}${BOLD}${GREEN}║                                                  ║${RESET}"
echo -e "${PAD_STR}${BOLD}${GREEN}║      ${YELLOW}Type ${CYAN}vps${YELLOW} to start the VNC Server!${GREEN}         ║${RESET}"
echo -e "${PAD_STR}${BOLD}${GREEN}║                                                  ║${RESET}"
echo -e "${PAD_STR}${BOLD}${GREEN}╚══════════════════════════════════════════════════╝${RESET}"
echo

# Clear the progress bar
tput cup $(($(tput lines) - 2))
printf "                                                                  "
tput cup $(($(tput lines) - 1))

exit 0