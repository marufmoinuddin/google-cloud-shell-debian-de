#!/bin/bash

# Define color codes
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
echo -e "${YELLOW}Stopping existing services...${NC}"
sudo killall -q ngrok websockify Xvnc 2>/dev/null
pkill -f xfce4-session 2>/dev/null && echo -e "${GREEN}Stopped xfce4-session${NC}"
sleep 2

# Region selection
echo -e "${YELLOW}Select ngrok region:${NC}"
echo "1. United States (Ohio)  2. Europe (Frankfurt)  3. Asia/Pacific (Singapore)"
echo "4. Australia (Sydney)    5. South America (Sao Paulo)  6. Japan (Tokyo)  7. India (Mumbai)"
read -p "Region (1-7): " server
case "$server" in
    1) REGION="us";;
    2) REGION="eu";;
    3) REGION="ap";;
    4) REGION="au";;
    5) REGION="sa";;
    6) REGION="jp";;
    7) REGION="in";;
    *) echo -e "${RED}Invalid choice, defaulting to US${NC}"; REGION="us";;
esac

# Ngrok authtoken
echo -e "${YELLOW}Setting up ngrok...${NC}"
read -p "Enter ngrok authtoken: " key
ngrok authtoken "$key" >/dev/null 2>&1 || { echo -e "${RED}Failed to set ngrok authtoken${NC}"; exit 1; }
nohup ngrok tcp --region "$REGION" 127.0.0.1:5900 &

# Start VNC server
echo -e "${YELLOW}Starting VNC server...${NC}"
sudo rm -rf /tmp/* 2>/dev/null
vncserver :0 -geometry 1280x720 -depth 24 || { echo -e "${RED}Failed to start VNC server${NC}"; exit 1; }

# Start websockify
echo -e "${YELLOW}Starting websockify...${NC}"
websockify -D --web=/usr/share/novnc/ 8080 localhost:5900 2>/dev/null &

# Configure TCP keepalive
sudo sysctl -w net.ipv4.tcp_keepalive_time=10000 net.ipv4.tcp_keepalive_intvl=5000 net.ipv4.tcp_keepalive_probes=100 >/dev/null

# Display connection info
echo -e "${GREEN}VNC server started!${NC}"
PUBLIC_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p')
echo -e "${CYAN}Your IP: $PUBLIC_URL${NC}"
echo -e "Access via VNC viewer or browser at http://localhost:8080/vnc.html"

# Keep script running with a simple status
echo -e "${YELLOW}Server running... Press Ctrl+C to stop.${NC}"
while true; do
    sleep 1
done