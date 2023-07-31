#!/bin/bash

# Define ANSI escape codes for color
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Redirect all output to /dev/null (except echo and apt outputs)
exec > >(while read -r line; do if [[ "$line" == *"Processing triggers for"* || "$line" == *"Preparing to unpack"* ]]; then echo "$line"; fi; done)
exec 2>&1

# Print initial message in green
echo -e "${GREEN}Preparing to install....${NC}"

# Unzip and move ngrok binary
echo "Unzipping and moving ngrok binary..."
unzip ngrok-stable-linux-amd64.zip >/dev/null
rm ngrok-stable-linux-amd64.zip
sudo cp ./ngrok /bin/ngrok
sudo chmod +x /bin/ngrok


# Inform about the following steps in green
echo -e "${GREEN}"
echo "Cloud Shell already runs on Debian. Just installing the DE (Xfce amd64) and some apps...."
echo -e "${NC}"

# Add Microsoft's GPG key and setup Visual Studio Code repository
echo "Adding Microsoft's GPG key and setting up VS Code repository..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# Update package list and install necessary packages
echo "Updating package list and installing necessary packages..."
sudo apt update -y >/dev/null
sudo apt install papirus-icon-theme code software-properties-common apt-transport-https ufw xfce4 xarchiver firefox-esr mesa-utils xfce4-goodies pv nmap nano apt-utils dialog terminator autocutsel dbus-x11 dbus neofetch perl p7zip unzip zip curl tar python3 python3-pip net-tools openssl tigervnc-standalone-server tigervnc-xorg-extension novnc python3-websockify -y >/dev/null

# Set some environment variables
cd .. || exit 1
export HOME="$(pwd)"
export DISPLAY=":0"
cd "$HOME" || exit 1
sudo rm -rf "$HOME/.vnc"
sudo mkdir "$HOME/.vnc"

# Preparing VNC's desktop environment execution
echo "Preparing VNC's desktop environment execution..."
if [ ! -d "$HOME/.config" ]; then
  sudo mkdir "$HOME/.config"
fi
chmod -R 777 "$HOME/.config"
sudo printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nxfce4-session\n' > "$HOME/.vnc/xstartup"
cd "$HOME/google-cloud-shell-debian-de" || exit 1
sudo cp ./startvps.sh /bin/startvps

# Setting permissions and cleaning up
echo "Setting permissions and cleaning up..."
sudo chmod 777 -R "$HOME/.vnc"
sudo chmod 777 "$HOME/.bashrc"
sudo chmod 777 /bin/startvps
sudo apt update -y >/dev/null
sudo apt autoremove -y >/dev/null

# Check and install Windows-10-Dark-master theme
echo "Checking and installing Windows-10-Dark-master theme..."
if [ ! -d /usr/share/themes/Windows-10-Dark-master ]; then
  cd /usr/share/themes/ || exit 1
  sudo cp "$HOME/google-cloud-shell-debian-de/app/Windows-10-Dark-master.zip" ./
  unzip -qq Windows-10-Dark-master.zip >/dev/null
  rm -f Windows-10-Dark-master.zip
fi
cd "$HOME" || exit 1

# Inform about backup and update .bashrc in green
echo -e "${GREEN}Creating backup of .bashrc and updating it...${NC}"
sudo mv "$HOME/.bashrc" "$HOME/.bashrc_old"
echo -e "${GREEN}Your $HOME/.bashrc is being modified. Backed up the old .bashrc file as .bashrc_old${NC}"
sudo cp "$HOME/google-cloud-shell-debian-de/setupPS.sh" "$HOME/.bashrc"
sudo chmod 777 "$HOME/.bashrc"

# Installation completed message in green
echo -e "\n\n\nInstallation completed!\nRun: startvps to start VNC Server!\n${NC}"
exit 0
