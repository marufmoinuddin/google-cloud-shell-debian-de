#!/bin/bash

# Define color variables
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;96m'
MAGENTA='\033[1;35m'
ORANGE='\033[38;5;208m'
RESET='\033[0m'
BOLD='\033[1m'

# Progress bar variables
TOTAL_STEPS=6
current_step=0

# Clear the screen and show header
clear
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${BLUE}║                                                        ║${RESET}"
echo -e "${BOLD}${BLUE}║  ${GREEN}Ubuntu 24.04 VNC Server Control Script${BLUE}               ║${RESET}"
echo -e "${BOLD}${BLUE}║  ${YELLOW}Access your desktop environment remotely${BLUE}            ║${RESET}"
echo -e "${BOLD}${BLUE}║                                                        ║${RESET}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════╝${RESET}\n"

print_step() {
    echo -e "\n${MAGENTA}===== ${CYAN}$1${MAGENTA} =====${RESET}"
}

# Redirect error output to /dev/null and set important environment variables
cd ~ || exit 1
unset DBUS_LAUNCH
export HOME="$(pwd)"
export DISPLAY=":0"

# Kill any running ngrok and websockify processes
print_step "Cleaning up previous sessions"
echo -e "${YELLOW}Stopping any running ngrok processes...${RESET}"
sudo killall -q ngrok
echo -e "${YELLOW}Stopping any running websockify processes...${RESET}"
sudo killall -q websockify

# Stop the desktop session if it's running
if pgrep xfce4-session >/dev/null; then
    echo -e "${YELLOW}Stopping xfce4-session...${RESET}"
    pkill xfce4-session
    sleep 2
elif pgrep plasma >/dev/null; then
    echo -e "${YELLOW}Stopping KDE Plasma session...${RESET}"
    pkill plasma
    sleep 2
elif pgrep ukui-session >/dev/null; then
    echo -e "${YELLOW}Stopping UKUI session...${RESET}"
    pkill ukui-session
    sleep 2
fi

# Select the region for ngrok
print_step "Configuring ngrok"
server=""
while [[ -z $server ]]; do
    echo -e "${BLUE}Select your region:${RESET}"
    echo -e "${YELLOW} 1. ${GREEN}United States (Ohio)${RESET}"
    echo -e "${YELLOW} 2. ${GREEN}Europe (Frankfurt)${RESET}"
    echo -e "${YELLOW} 3. ${GREEN}Asia/Pacific (Singapore)${RESET}"
    echo -e "${YELLOW} 4. ${GREEN}Australia (Sydney)${RESET}"
    echo -e "${YELLOW} 5. ${GREEN}South America (Sao Paulo)${RESET}"
    echo -e "${YELLOW} 6. ${GREEN}Japan (Tokyo)${RESET}"
    echo -e "${YELLOW} 7. ${GREEN}India (Mumbai)${RESET}"
    echo -e "${YELLOW} 8. ${GREEN}Exit${RESET}"
    echo ""
    
    read -p "$(echo -e "${CYAN}Region: ${RESET}")" server

    case $server in
        1) regions="us";;
        2) regions="eu";;
        3) regions="ap";;
        4) regions="au";;
        5) regions="sa";;
        6) regions="jp";;
        7) regions="in";;
        8) 
           echo -e "${RED}Exiting...${RESET}"
           exit 0;;
        *) 
           echo -e "${RED}Invalid option. Please try again.${RESET}"
           unset server;;
    esac
done

# Read and set ngrok authtoken
echo ""
read -p "$(echo -e "${CYAN}Enter your ngrok authtoken: ${RESET}")" key
echo -e "${GREEN}Setting ngrok authtoken...${RESET}"
sudo ngrok authtoken "$key"

# Start ngrok and VNC server
print_step "Starting services"
echo -e "${GREEN}Starting ngrok tunnel in region: ${YELLOW}$regions${RESET}"
nohup sudo ngrok tcp --region "$regions" 127.0.0.1:5900 > /dev/null 2>&1 &

# Stop VNC server if already running
if pgrep Xvnc >/dev/null; then
    echo -e "${YELLOW}Stopping VNC server...${RESET}"
    sudo killall Xvnc
    sleep 2
fi

# Clean up temporary files
echo -e "${YELLOW}Cleaning temporary files...${RESET}"
sudo rm -rf /tmp/* 2> /dev/null

# Start VNC server
echo -e "${GREEN}Starting VNC server...${RESET}"
vncserver :0

# Start websockify for VNC access via web
print_step "Configuring web access"
echo -e "${GREEN}Starting NoVNC web service on port 8080...${RESET}"
websockify -D --web=/usr/share/novnc/ --cert="$HOME/novnc.pem" 8080 localhost:5900 2> /dev/null 

# Configure TCP keepalive settings
print_step "Optimizing network settings"
echo -e "${GREEN}Configuring TCP keepalive settings...${RESET}"
sudo /sbin/sysctl -w net.ipv4.tcp_keepalive_time=10000 net.ipv4.tcp_keepalive_intvl=5000 net.ipv4.tcp_keepalive_probes=100

# Restart any stopped services
echo -e "${GREEN}Restarting system services...${RESET}"
sall="$(service --status-all 2> /dev/null | grep '\-' | awk '{print $4}')"
while IFS= read -r line; do
    nohup sudo service "$line" restart &> /dev/null 2> /dev/null &
done < <(printf '%s\n' "$sall")

# Get the public URL for the ngrok tunnel
print_step "Retrieving connection information"
echo -e "${BOLD}${GREEN}Your connection information:${RESET}"
echo ""
echo -e "${CYAN}Public VNC Address: ${YELLOW}"
curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p'
echo ""

# Display information for accessing the VNC server
echo -e "${CYAN}Web Access:${RESET}"
echo -e "You can use ${YELLOW}NoVNC server${RESET} in your browser to view your Desktop."
echo -e "Press ${YELLOW}Web Preview${RESET} (on the top right) and go to port ${GREEN}8080${RESET} and then press the ${GREEN}vnc.html${RESET} link."
echo -e "Or use the IP address above with your VNC viewer."

# Final step - update progress to 100%
current_step=$TOTAL_STEPS

# Set the prompt with the default format
export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
echo ""

# Starting animation for the running service
echo -e "${BOLD}${GREEN}VNC Server is now running!${RESET}\n"

# Clear the progress bar
tput cup $(($(tput lines) - 2))
printf "                                                                  "
tput cup $(($(tput lines) - 1))

# Start a better running indicator with elapsed time counter
echo -e "${CYAN}Server runtime counter:${RESET}"
elapsed=0
while true; do
    hours=$((elapsed / 3600))
    minutes=$(( (elapsed % 3600) / 60 ))
    seconds=$((elapsed % 60))
    
    # Format time with leading zeros
    printf -v formatted_time "%02d:%02d:%02d" $hours $minutes $seconds
    
    # Show spinner animation with time
    for i in ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷; do
        echo -ne "\r${GREEN}$i ${YELLOW}Server running: ${CYAN}$formatted_time${RESET}   "
        sleep 0.1
    done
    
    elapsed=$((elapsed + 1))
done