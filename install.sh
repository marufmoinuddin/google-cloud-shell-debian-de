#!/bin/bash

# Print initial message
echo "Preparing to install...."

# Unzip and move ngrok binary
unzip ngrok-stable-linux-amd64.zip 
rm ngrok-stable-linux-amd64.zip 
sudo mv ./ngrok /bin/ngrok
sudo chmod +x /bin/ngrok

# Read and set ngrok authtoken
read -p "INSERT authtoken ngrok: " key
ngrok authtoken "$key"

# Inform about the following steps
echo ""
echo "Cloud Shell already runs on Debian. Just installing the DE (Xfce amd64) and some apps...."

# Add Microsoft's GPG key and setup Visual Studio Code repository
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg 
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ 
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# Update package list and install necessary packages
sudo apt update -y 
sudo apt install fish code software-properties-common apt-transport-https ufw xfce4 xarchiver firefox-esr mesa-utils xfce4-goodies pv nmap nano apt-utils dialog terminator autocutsel dbus-x11 dbus neofetch perl p7zip unzip zip curl tar python3 python3-pip net-tools openssl tigervnc-standalone-server tigervnc-xorg-extension novnc python3-websockify -y

# Set some environment variables
export installer="$(pwd)"
cd ~/ || exit 1
export HOME="$(pwd)"
export DISPLAY=":0"
cd "$HOME" || exit 1
sudo mkdir ~/.vnc 

# Set up Fish shell configuration
if [ ! -d ~/.config ] ; then
  sudo mkdir ~/.config 
fi
if [ ! -d ~/.config/fish ] ; then
  sudo mkdir ~/.config/fish 
fi
echo "set fish_greeting" > ~/.config/fish/config.fish
chmod -R 777 ~/.config 
sudo printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nxfce4-session\n' > ~/.vnc/xstartup
cd "$installer" || exit 1
sudo mv ./startvps.sh /bin/startvps 
sudo mv ~/.bashrc ~/.bashrc_old 

# Inform about backup and update .bashrc
echo "Your ~/.bashrc is being modified. Backed up the old .bashrc file as .bashrc_old"
sudo mv ./setupPS.sh ~/.bashrc 
sudo chmod 777 -R ~/.vnc 
sudo chmod 777 ~/.bashrc 
sudo chmod 777 /bin/startvps 
sudo apt update -y 
sudo apt autoremove -y 

# Check and install Windows-10-Dark-master theme
if [ ! -d /usr/share/themes/Windows-10-Dark-master ] ; then
  cd /usr/share/themes/ || exit 1
  sudo cp "$installer"/app/Windows-10-Dark-master.zip ./ 
  unzip -qq Windows-10-Dark-master.zip 
  rm -f Windows-10-Dark-master.zip 
fi
cd "$HOME" || exit 1
clear

# Installation completed message
printf "\n\n\n - Installation completed!\n Run: [startvps] to start VNC Server!\n\n"
exit 0
