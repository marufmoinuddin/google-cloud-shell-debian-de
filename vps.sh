#!/bin/bash

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

# Stop the xfce4-session if it's running
if pgrep xfce4-session >/dev/null; then
    echo "Stopping xfce4-session..."
    pkill xfce4-session
    sleep 2
fi

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
sudo ngrok authtoken "$key"

# Start ngrok and VNC server
nohup sudo ngrok tcp --region "$regions" 127.0.0.1:5900 &
if pgrep Xvnc >/dev/null; then
    echo "Stopping VNC server..."
    sudo killall Xvnc
    sleep 2
fi
sudo rm -rf /tmp/* 2> /dev/null
vncserver :0

# Start websockify for VNC access via web
websockify -D --web=/usr/share/novnc/ --cert="$HOME/novnc.pem" 8080 localhost:5900 2> /dev/null 

# Configure TCP keepalive settings
sudo /sbin/sysctl -w net.ipv4.tcp_keepalive_time=10000 net.ipv4.tcp_keepalive_intvl=5000 net.ipv4.tcp_keepalive_probes=100

# Optionally, add a message after pressing Enter
echo -e "\n\nPress ${light_cyan}Enter${reset}..."
sall="$(service  --status-all 2> /dev/null | grep '\-' | awk '{print $4}')"
while IFS= read -r line; do
    nohup sudo service "$line" restart &> /dev/null 2> /dev/null &
done < <(printf '%s\n' "$sall")

# Get the public URL for the ngrok tunnel
printf "\n\nYour IP Here: "
curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p'

# Display information for accessing the VNC server
echo -e "You can also use ${light_cyan}novnc server${reset} in the browser to view your Desktop."
echo -e "Just press ${light_cyan}Web Preview${reset} (on the top right) and go to port 8080 and then press the vnc.html link."
echo -e "Or use the IP and put it into your VNC viewer."

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
