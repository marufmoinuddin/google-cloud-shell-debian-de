#!/bin/bash

# Print initial message
echo "Preparing to install...."

# Unzip and move ngrok binary
unzip ngrok-stable-linux-amd64.zip 
rm ngrok-stable-linux-amd64.zip 
sudo cp ./ngrok /bin/ngrok
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
sudo cp ./startvps.sh /bin/startvps 

# Setting permissions and cleaning up
sudo chmod 777 -R "$HOME/.vnc"
sudo chmod 777 "$HOME/.bashrc"
sudo chmod 777 /bin/startvps 
sudo apt update -y 
sudo apt autoremove -y 

# Define the backup source directory
backup_dir="$HOME/google-cloud-shell-debian-de/xfce4_backup"

# Function to restore files and directories using cp
restore_files() {
    source_path="$1"
    if [ -d "$source_path" ]; then
        if [ ! -d "$HOME/.config/xfce4/$(basename $source_path)" ]; then
            cp -r "$backup_dir/$(basename $source_path)" "$HOME/.config/xfce4"
        else
            echo "Skipped: $source_path already exists."
        fi
    fi
}

# Restore all XFCE4 settings and configurations
restore_files "$HOME/.config/xfce4"
restore_files "$HOME/.config/xfce4-session"
restore_files "$HOME/.config/xfce4-panel"
restore_files "$HOME/.config/xfce4-desktop"
restore_files "$HOME/.config/xfce4/xfconf"
restore_files "$HOME/.config/Thunar"

# Restore themes and icons (optional)
restore_files "$HOME/.themes"
restore_files "$HOME/.icons"

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

# Installation completed message
printf "\n\n\nInstallation completed!\n Run: startvps to start VNC Server!\n\n"
exit 0
