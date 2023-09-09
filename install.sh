#!/bin/bash

# Print the menu for desktop environment selection
echo "Select a desktop environment:"
echo "1. KDE"
echo "2. Xfce"
echo "3. UKUI"
echo -n "Enter your choice (1/2/3) [default is KDE]: "

# Set timeout for user input (5 seconds)
read -t 10 choice

# Set the default choice if timeout occurs or invalid input is given
if [ -z "$choice" ]; then
    choice="1"
fi

# Check if the .config directory exists
config_dir="$HOME/.config"
if [ ! -d "$config_dir" ]; then
  echo "The .config directory does not exist. Creating it..."
  mkdir -p "$config_dir"
fi

# Print initial message
echo "Preparing to install...."

#Add Debian unstable to sources.list
echo "deb https://deb.debian.org/debian/ unstable main contrib non-free" | sudo tee -a /etc/apt/sources.list
echo "deb-src https://deb.debian.org/debian/ unstable main contrib non-free" | sudo tee -a /etc/apt/sources.list

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

# Backup the existing sources.list
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

# Update package list and install necessary packages
sudo apt update && sudo apt install code apt-transport-https firefox-esr mesa-utils pv nmap nano dialog autocutsel dbus-x11 dbus neofetch p7zip unzip zip tigervnc-standalone-server tigervnc-xorg-extension novnc python3-websockify -y

# Set some environment variables
cd .. || exit 1
export HOME="$(pwd)"
export DISPLAY=":0"
cd "$HOME" || exit 1
sudo rm -rf "$HOME/.vnc"
sudo mkdir "$HOME/.vnc"
clear
echo "-- SET A PASSWORD --"
vncpasswd

# Install the selected desktop environment
if [ "$choice" = "1" ]; then
    # KDE installation
    echo "You selected KDE..."
    sudo apt install ark konsole gwenview kate okular kde-plasma-desktop -y
    sudo apt remove kdeconnect -y
    sudo printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nstartplasma-x11\n' > "$HOME/.vnc/xstartup"
    # Restore the backup to HOME
    # Extract the compressed archive to home directory
    tar -xzvf "$backup_dir/kde_backup*.tar.gz" -C "$HOME" --keep-old-files
    echo "Restoration completed successfully!"

elif [ "$choice" = "2" ]; then
    # Xfce installation
    echo "You selected Xfce..."
    # Install
    sudo apt install papirus-icon-theme xfce4 xfce4-goodies terminator -y
    printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nxfce4-session\n' > "$HOME/.vnc/xstartup"
    # Define the backup source directory
    backup_dir="$HOME/google-cloud-shell-debian-de/xfce4_backup"
    # Restore the backup to .config directory
    echo "Restoring backup from $backup_dir to $config_dir..."
    cp -R "$backup_dir"/* "$config_dir"
    echo "Restoration completed successfully!"
elif [ "$choice" = "3" ]; then
    # UKUI installation
    echo "You selected UKUI..."
    # Install additional packages from experimental repository
    sudo apt install ukui* ukwm qt5-ukui-platformtheme kylin-nm -y
    sudo cp $HOME/.Xauthority /root
    sudo apt install ukui-settings-daemon ukwm -y
    # Create or update the VNC startup script using printf
    printf '#!/bin/bash\nexport GTK_IM_MODULE="fcitx"\nexport QT_IM_MODULE="fcitx"\nexport XMODIFIERS="@im=fcitx"\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nxrdb $HOME/.xresources\nlightdm &\nexec /usr/bin/ukui-session\n' > "$HOME/.vnc/xstartup"
else
    echo "Invalid choice. Installing KDE by default..."
    echo "You selected KDE..."
    sudo apt install ark konsole gwenview kate okular kde-plasma-desktop -y
    printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nstartplasma-x11\n' > "$HOME/.vnc/xstartup"
    # Restore the backup to HOME
    # Extract the compressed archive to home directory
    tar -xzvf "$backup_dir/kde_backup*.tar.gz" -C "$HOME" --keep-old-files
    echo "Restoration completed successfully!"
fi
chmod 755 $HOME/.vnc/xstartup

# Preparing VNC's desktop environment execution
if [ ! -d "$HOME/.config" ]; then
  sudo mkdir "$HOME/.config"
fi
chmod -R 777 "$HOME/.config"
cd "$HOME/google-cloud-shell-debian-de" || exit 1
sudo mv ./vps.sh /usr/bin/vps
sudo chmod +x /usr/bin/vps

# Setting permissions and cleaning up
sudo chmod 777 -R "$HOME/.vnc"
sudo chmod 777 "$HOME/.bashrc"
sudo apt update -y
sudo apt autoremove -y

# Check and install Windows-10-Dark-master theme
if [ ! -d /usr/share/themes/Windows-10-Dark-master ]; then
  cd /usr/share/themes/ || exit 1
  sudo cp "$HOME/google-cloud-shell-debian-de/app/Windows-10-Dark-master.zip" ./
  sudo unzip -qq Windows-10-Dark-master.zip
  sudo rm -f Windows-10-Dark-master.zip
fi
cd "$HOME" || exit 1

# Inform about backup and update .bashrc
sudo mv "$HOME/.bashrc" "$HOME/.bashrc_old"
echo "Your $HOME/.bashrc is being modified. Backed up the old .bashrc file as .bashrc_old"
sudo cp "$HOME/google-cloud-shell-debian-de/bashrc.sh" "$HOME/.bashrc"
sudo chmod 777 "$HOME/.bashrc"

# Install WPS-Office
cd /tmp
wget https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11701/wps-office_11.1.0.11701.XA_amd64.deb
sudo apt install ./wps-office_11.1.0.11701.XA_amd64.deb -y


# Installation completed message
echo "Installation completed!"
echo "Type vps to start VNC Server!"
exit 0
