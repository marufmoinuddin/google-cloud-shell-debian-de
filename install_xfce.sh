#!/bin/bash

# Print initial message
echo "Preparing to install...."

# Unzip and move ngrok binary
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip 
rm ngrok-stable-linux-amd64.zip 
sudo mv ./ngrok /bin/ngrok
sudo chmod +x /bin/ngrok

# Inform about the following steps
echo ""
echo "Cloud Shell already runs on Debian. Just installing the DE (Xfce amd64) and some apps...."

# Add Microsoft's GPG key and setup Visual Studio Code repository
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg 
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ 
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# Add Linux Mint repository to sources list
echo "deb [trusted=yes] http://packages.linuxmint.com elsie main upstream import backport" >> /etc/apt/sources.list

# Import the GPG key for the Linux Mint repository
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com A6616109451BBBF2

# Update package list and install necessary packages
sudo apt update -y 
sudo apt install papirus-icon-theme expect mintinstall code software-properties-common apt-transport-https ufw xfce4 xarchiver firefox-esr mesa-utils xfce4-goodies pv nmap nano apt-utils dialog terminator autocutsel dbus-x11 dbus neofetch perl p7zip unzip zip curl tar python3 python3-pip net-tools openssl tigervnc-standalone-server tigervnc-xorg-extension novnc python3-websockify -y

# Set some environment variables
cd .. || exit 1
export HOME="$(pwd)"
export DISPLAY=":0"
cd "$HOME" || exit 1
sudo rm -rf "$HOME/.vnc"
sudo mkdir "$HOME/.vnc"

# Preparing VNC's desktop environment execution
if [ ! -d "$HOME/.config" ]; then
  sudo mkdir "$HOME/.config"
fi
chmod -R 777 "$HOME/.config"
sudo printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nxfce4-session\n' > "$HOME/.vnc/xstartup"
cd "$HOME/google-cloud-shell-debian-de" || exit 1
sudo mv ./vps.sh /bin/vps
sudo chmod +x /bin/vps

# Setting permissions and cleaning up
sudo chmod 777 -R "$HOME/.vnc"
sudo chmod 777 "$HOME/.bashrc"
sudo chmod 777 /bin/vps 
sudo apt update -y 
sudo apt autoremove -y 

# Define the backup source directory
backup_dir="$HOME/google-cloud-shell-debian-de/xfce4_backup"

# Check if the backup directory exists
if [ ! -d "$backup_dir" ]; then
  echo "Backup directory does not exist: $backup_dir"
  exit 1
fi

# Check if the .config directory exists
config_dir="$HOME/.config"
if [ ! -d "$config_dir" ]; then
  echo "The .config directory does not exist. Creating it..."
  mkdir -p "$config_dir"
fi

# Restore the backup to .config directory
echo "Restoring backup from $backup_dir to $config_dir..."
cp -R "$backup_dir"/* "$config_dir"

echo "Restoration completed successfully!"


# Check and install Windows-10-Dark-master theme
if [ ! -d /usr/share/themes/Windows-10-Dark-master ]; then
  cd /usr/share/themes/ || exit 1
  sudo cp "$HOME/google-cloud-shell-debian-de/app/Windows-10-Dark-master.zip" ./ 
  unzip -qq Windows-10-Dark-master.zip 
  rm -f Windows-10-Dark-master.zip 
fi
cd "$HOME" || exit 1

# Inform about backup and update .bashrc
sudo mv "$HOME/.bashrc" "$HOME/.bashrc_old"
echo "Your $HOME/.bashrc is being modified. Backed up the old .bashrc file as .bashrc_old"
sudo cp "$HOME/google-cloud-shell-debian-de/setupPS.sh" "$HOME/.bashrc"
sudo chmod 777 "$HOME/.bashrc"

# Install WPS-Office
cd /tmp
wget https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11701/wps-office_11.1.0.11701.XA_amd64.deb
sudo apt install ./wps-office_11.1.0.11701.XA_amd64.deb -y

# Installation completed message
printf "\n\n\nInstallation completed!\n Run: vps to start VNC Server!\n\n"
exit 0
