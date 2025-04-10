#!/bin/bash

# Color definitions
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

# Set environment variables
export HOME="$(pwd)"
export DISPLAY=":0"

# Clean up previous processes
sudo killall -q ngrok websockify Xvnc 2>/dev/null

# Region selection
echo -e "${BLUE}Select your ngrok region:${NC}"
echo "1. United States (Ohio)"
echo "2. Europe (Frankfurt)"
echo "3. Asia/Pacific (Singapore)"
echo "4. Australia (Sydney)"
echo "5. South America (Sao Paulo)"
echo "6. Japan (Tokyo)"
echo "7. India (Mumbai)"
echo "8. Exit"
read -p "Region: " server
case "$server" in
    1) region="us";;
    2) region="eu";;
    3) region="ap";;
    4) region="au";;
    5) region="sa";;
    6) region="jp";;
    7) region="in";;
    8) exit 0;;
    *) region="us"; echo -e "${RED}Invalid choice, defaulting to US${NC}";;
esac

# Ngrok authtoken setup
echo -e "${YELLOW}Insert your ngrok authtoken:${NC}"
read -p "Authtoken: " key
ngrok authtoken "$key" >/dev/null 2>&1

# Start ngrok and VNC server
nohup ngrok tcp --region "$region" 127.0.0.1:5900 >/dev/null 2>&1 &
vncserver :0 -geometry 1280x720 -depth 24 >/dev/null 2>&1

# Start websockify for noVNC
nohup websockify --web=/usr/share/novnc/ --cert="$HOME/novnc.pem" 8080 localhost:5900 >/dev/null 2>&1 &

# Display connection details
echo -e "${GREEN}Fetching ngrok public URL...${NC}"
sleep 2 # Wait for ngrok to initialize
public_url=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url' | sed 's/tcp:\/\///')
echo -e "${CYAN}VNC Server IP: $public_url${NC}"
echo -e "${YELLOW}For noVNC, use Web Preview on port 8080 and click vnc.html${NC}"

# Keep script running with a simple status indicator
echo -e "${GREEN}VNC Server is running. Press Ctrl+C to stop.${NC}"
while true; do
    sleep 1
    echo -ne "${CYAN}Running...${NC}\r"
done