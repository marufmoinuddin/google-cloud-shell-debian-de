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

# Update package list and install necessary packages
sudo apt update -y 
sudo apt install papirus-icon-theme code software-properties-common apt-transport-https ufw xfce4 xarchiver firefox-esr mesa-utils xfce4-goodies pv nmap nano apt-utils dialog terminator autocutsel dbus-x11 dbus neofetch perl p7zip unzip zip curl tar python3 python3-pip net-tools openssl tigervnc-standalone-server tigervnc-xorg-extension novnc python3-websockify -y

# Set some environment variables
export installer="$(pwd)"
cd ~/ || exit 1
export HOME="$(pwd)"
export DISPLAY=":0"
cd "$HOME" || exit 1
sudo mkdir $HOME/.vnc 

#Preparing VNC's desktop environment execution
if [ ! -d $HOME/.config ] ; then
  sudo mkdir $HOME/.config 
fi
chmod -R 777 $HOME/.config 
sudo printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nxfce4-session\n' > $HOME/.vnc/xstartup

# Inform about backup and update .bashrc
sudo mv $HOME/.bashrc $HOME/.bashrc_old 
echo "Your $HOME/.bashrc is being modified. Backed up the old .bashrc file as .bashrc_old"
sudo cp ./setupPS.sh $HOME/.bashrc 

#Setting cermissions and cleaning up
sudo chmod 777 -R $HOME/.vnc 
sudo chmod 777 $HOME/.bashrc 
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
#modified
# Define color variables
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;34m'
light_cyan='\033[1;96m'
reset='\033[0m'
orange='\033[38;5;208m'

# Redirect error output to /dev/null and set important environment variables
cd ~ || exit 1
unset DBUS_LAUNCH
export HOME="$(pwd)"
export DISPLAY=":0"

# Kill any running ngrok and websockify processes
sudo killall -q ngrok
sudo killall -q websockify

# Select the region for ngrok
while [[ -z $server ]]; do
    printf "${blue}Select your region:\n${yellow} 1. United States (Ohio)\n 2. Europe (Frankfurt)\n 3. Asia/Pacific (Singapore)\n 4. Australia (Sydney)\n 5. South America (Sao Paulo)\n 6. Japan (Tokyo)\n 7. India (Mumbai)\n 8. Exit\n\n${green}"
    read -p "Region: " server

    case $server in
        1) regions="us";;
        2) regions="eu";;
        3) regions="ap";;
        4) regions="au";;
        5) regions="sa";;
        6) regions="jp";;
        7) regions="in";;
        [Kk]) exit 0;;
        *) unset server;;
    esac
done

# Read and set ngrok authtoken
read -p "Now, insert authtoken ngrok: " key
ngrok authtoken "$key"

# Start ngrok and VNC server
nohup sudo ngrok tcp --region "$regions" 127.0.0.1:5900 &> /dev/null &
vncserver -kill :0 &> /dev/null
sudo rm -rf /tmp/* 2> /dev/null
vncserver :0

# Start websockify for VNC access via web
websockify -D --web=/usr/share/novnc/ --cert="$HOME/novnc.pem" 8080 localhost:5900

# Configure TCP keepalive settings
sudo /sbin/sysctl -w net.ipv4.tcp_keepalive_time=10000 net.ipv4.tcp_keepalive_intvl=5000 net.ipv4.tcp_keepalive_probes=100

# Start all available services
sall="$(service --status-all 2> /dev/null | grep '\-' | awk '{print $4}')"
while IFS= read -r line; do
    nohup sudo service "$line" start &> /dev/null &
done < <(printf '%s\n' "$sall")

clear

# Get the public URL for the ngrok tunnel
printf "\nYour IP Here: "
curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p'

# Display information for accessing the VNC server
echo "You can also use novnc server in the browser to view your Desktop."
echo "Just press **Web Preview** (on the top right) and go to port 8080 and then press the vnc.html link."
echo "Or use the IP and put it into your VNC viewer."

# Set the prompt with the default format
export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
printf "\n\n"

# Delay loop for a specified time
seq 1 9999999999999 | while read -r i; do
    echo -en "\r Running .     $i s /9999999999999 s"
    sleep 0.1
    echo -en "\r Running ..    $i s /9999999999999 s"
    sleep 0.1
    echo -en "\r Running ...   $i s /9999999999999 s"
    sleep 0.1
    echo -en "\r Running ....  $i s /9999999999999 s"
    sleep 0.1
    echo -en "\r Running ..... $i s /9999999999999 s"
    sleep 0.1
    echo -en "\r Running     . $i s /9999999999999 s"
    sleep 0.1
    echo -en "\r Running  .... $i s /9999999999999 s"
    sleep 0.1
    echo -en "\r Running   ... $i s /9999999999999 s"
    sleep 0.1
    echo -en "\r Running    .. $i s /9999999999999 s"
    sleep 0.1
    echo -en "\r Running     . $i s /9999999999999 s"
    sleep 0.1
done
