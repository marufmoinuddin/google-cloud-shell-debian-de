#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
ORANGE='\033[38;5;208m'
NC='\033[0m' # No Color

# Progress spinner function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "\r${YELLOW}Processing: [%c]${NC}" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r"
}

# Print step function
print_step() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Trap for clean exit
trap 'echo -e "\n${RED}Script interrupted${NC}"; cleanup; exit 1' INT TERM

# Cleanup function
cleanup() {
    sudo killall -q ngrok websockify Xvnc 2>/dev/null
    sudo rm -rf /tmp/* 2>/dev/null
}

# Set environment variables
cd ~ || { echo -e "${RED}Failed to change to home directory${NC}"; exit 1; }
export HOME="$(pwd)"
export DISPLAY=":0"
unset DBUS_LAUNCH

print_step "Stopping existing services"
for service in ngrok websockify Xvnc xfce4-session; do
    if pgrep "$service" >/dev/null; then
        echo -e "${YELLOW}Stopping $service...${NC}"
        sudo killall -q "$service" & spinner $!
        sleep 1
    fi
done

print_step "Select ngrok region"
regions=""
while [ -z "$regions" ]; do
    echo -e "${CYAN}Available regions:${NC}"
    echo "1. United States (Ohio)   2. Europe (Frankfurt)"
    echo "3. Asia/Pacific (Singapore) 4. Australia (Sydney)"
    echo "5. South America (Sao Paulo) 6. Japan (Tokyo)"
    echo "7. India (Mumbai)         8. Exit"
    read -p "Enter region number (1-8): " choice
    case $choice in
        1) regions="us";;
        2) regions="eu";;
        3) regions="ap";;
        4) regions="au";;
        5) regions="sa";;
        6) regions="jp";;
        7) regions="in";;
        8) echo -e "${GREEN}Exiting...${NC}"; exit 0;;
        *) echo -e "${RED}Invalid choice${NC}";;
    esac
done

print_step "Configuring ngrok"
read -p "Enter ngrok authtoken: " key
if [ -n "$key" ]; then
    ngrok authtoken "$key" &>/dev/null || { echo -e "${RED}Failed to set ngrok authtoken${NC}"; exit 1; }
    nohup ngrok tcp --region "$regions" 127.0.0.1:5900 &>/dev/null & spinner $!
    sleep 2
else
    echo -e "${RED}Authtoken cannot be empty${NC}"
    exit 1
fi

print_step "Starting VNC server"
sudo rm -rf /tmp/* 2>/dev/null
vncserver :0 -geometry 1920x1080 -depth 24 &>/dev/null & spinner $!
sleep 2

print_step "Starting websockify for noVNC"
[ ! -f "$HOME/novnc.pem" ] && openssl req -x509 -nodes -newkey rsa:2048 -keyout "$HOME/novnc.pem" -out "$HOME/novnc.pem" -days 365 -subj "/CN=localhost" &>/dev/null
nohup websockify --web=/usr/share/novnc/ --cert="$HOME/novnc.pem" 8080 localhost:5900 &>/dev/null & spinner $!
sleep 2

print_step "Optimizing network settings"
sudo sysctl -w net.ipv4.tcp_keepalive_time=10000 \
    net.ipv4.tcp_keepalive_intvl=5000 \
    net.ipv4.tcp_keepalive_probes=100 &>/dev/null

print_step "Getting connection details"
public_url=$(curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p')
if [ -n "$public_url" ]; then
    echo -e "${GREEN}Your VNC connection URL: ${CYAN}$public_url${NC}"
    echo -e "noVNC browser access: ${CYAN}http://localhost:8080/vnc.html${NC}"
    echo -e "${YELLOW}For browser access: Use 'Web Preview' on port 8080 and click vnc.html${NC}"
else
    echo -e "${RED}Failed to get ngrok tunnel URL${NC}"
fi

print_step "Setting up shell prompt"
export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

echo -e "\n${GREEN}Setup complete!${NC}"
echo -e "Press ${CYAN}Ctrl+C${NC} to stop the server"

# Keep-alive loop with cleaner display
while true; do
    for i in {1..5}; do
        printf "\r${ORANGE}Server running${NC} [%${i}s]    "
        sleep 1
    done
done