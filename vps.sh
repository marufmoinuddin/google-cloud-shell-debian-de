#!/bin/bash

# Color definitions
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

# Set environment variables
cd ~ || exit 1
export HOME="$(pwd)"
export DISPLAY=":0"

# Clean up existing processes
pkill -f ngrok
pkill -f websockify
pkill -f xfce4-session

# Region selection
echo -e "${BLUE}Select ngrok region:${NC}"
options=("us" "eu" "ap" "au" "sa" "jp" "in" "exit")
select region in "${options[@]}"; do
    [[ "$region" == "exit" ]] && exit 0
    [[ -n "$region" ]] && break
    echo "Invalid option"
done

# Get ngrok authtoken
read -p "Enter ngrok authtoken: " key
ngrok authtoken "$key" >/dev/null 2>&1

# Start services
echo -e "${YELLOW}Starting services...${NC}"
nohup ngrok tcp --region "$region" 127.0.0.1:5900 &>/dev/null &
sleep 2
vncserver :0 -geometry 1440x900 -depth 24
websockify -D --web=/usr/share/novnc/ 8080 localhost:5900 &>/dev/null &

# Optimize network settings
sudo sysctl -w net.ipv4.tcp_keepalive_time=10000 net.ipv4.tcp_keepalive_intvl=5000 net.ipv4.tcp_keepalive_probes=100 >/dev/null

# Display connection info
echo -e "\n${GREEN}VNC Server Running${NC}"
public_url=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'tcp://[^"]*')
echo -e "VNC Address: ${CYAN}${public_url}${NC}"
echo -e "Or use browser: ${CYAN}http://localhost:8080/vnc.html${NC}"

# Keep script running with minimal resource usage
while true; do
    sleep 60
done