#!/bin/bash

# Define color variables
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;34m'
light_cyan='\033[1;96m'
reset='\033[0m'
orange='\033[38;5;208m'

# Function to check if commands exist
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print error messages and exit
print_error() {
    echo -e "${red}[ERROR]${reset} $1"
}

# Function to print status messages
print_status() {
    echo -e "${blue}[STATUS]${reset} $1"
}

# Redirect error output to /dev/null and set important environment variables
cd ~ || exit 1
unset DBUS_LAUNCH
export HOME="$(pwd)"
export DISPLAY=":0"

# Check if TigerVNC is installed
if ! command_exists vncserver; then
    print_error "TigerVNC is not installed. Please run the install script first."
    exit 1
fi

# Check if ngrok is installed
if ! command_exists ngrok; then
    print_error "ngrok is not installed. Please run the install script first."
    exit 1
fi

# Kill any running ngrok and websockify processes
print_status "Stopping any running services..."
sudo killall -q ngrok
sudo killall -q websockify
sudo killall -q Xtigervnc

# Create VNC directories if they don't exist
mkdir -p ~/.vnc

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
        8) exit 0;;
        *) unset server;;
    esac
done

# Read and set ngrok authtoken
read -p "Now, insert authtoken ngrok: " key
ngrok config add-authtoken "$key"

# Start ngrok for TCP tunneling
print_status "Starting ngrok tunnel..."
nohup ngrok tcp --region "$regions" 5900 > /dev/null 2>&1 &

# Kill any existing VNC server
print_status "Setting up VNC server..."
vncserver -kill :0 2>/dev/null || true

# Clean up temporary files
sudo rm -rf /tmp/.X0* /tmp/.X11* 2>/dev/null || true

# Create VNC password file (more secure)
print_status "Setting up VNC password..."
mkdir -p ~/.vnc
echo "vnc123" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Ensure VNC config directories exist
sudo mkdir -p /etc/tigervnc
if [ ! -f "/etc/tigervnc/vncserver-config-defaults" ]; then
    sudo bash -c 'echo "# TigerVNC configuration
\$SecurityTypes = \"VncAuth,TLSVnc\";
\$localhost = \"no\";
\$AlwaysShared = \"yes\";" > /etc/tigervnc/vncserver-config-defaults'
fi

# Start VNC server with proper security parameters for Ubuntu 24.04
print_status "Starting VNC server..."
# Use either password authentication or the --I-KNOW-THIS-IS-INSECURE flag
vncserver :0 -geometry 1920x1080 -depth 24 -localhost no -SecurityTypes VncAuth -PasswordFile ~/.vnc/passwd || vncserver :0 -geometry 1920x1080 -depth 24 -localhost no --I-KNOW-THIS-IS-INSECURE

# Start websockify for NoVNC
print_status "Starting NoVNC websockify..."
websockify -D --web=/usr/share/novnc/ 8080 localhost:5900 2>/dev/null

# Configure TCP keepalive settings
print_status "Optimizing network settings..."
sudo sysctl -w net.ipv4.tcp_keepalive_time=10000
sudo sysctl -w net.ipv4.tcp_keepalive_intvl=5000
sudo sysctl -w net.ipv4.tcp_keepalive_probes=100

# Pause for user input
echo -e "\n\nPress ${light_cyan}Enter${reset} to continue..."
read

# Get the public URL for the ngrok tunnel
print_status "Retrieving connection information..."
# Wait a bit to make sure ngrok API is ready
sleep 5

ngrok_url=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o '[^"]*$' | sed 's|tcp://||')

# Display connection information
echo -e "\n${green}Your IP Here:${reset} ${light_cyan}$ngrok_url${reset}"
echo -e "${yellow}VNC Password:${reset} ${light_cyan}vnc123${reset}"
echo -e "You can also use ${light_cyan}novnc server${reset} in the browser to view your Desktop."
echo -e "Just press ${light_cyan}Web Preview${reset} (on the top right) and go to port 8080 and then press the vnc.html link."
echo -e "Or use the IP and put it into your VNC viewer."

# Set the prompt with the default format
export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
printf "\n\n"

# Status indicator loop
print_status "VNC server running. Press Ctrl+C to exit."
count=0
while true; do
    animation=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    echo -en "\r ${green}${animation[count % 10]}${reset} Running... (Press Ctrl+C to exit)"
    sleep 0.1
    ((count++))
done