#!/bin/bash

# Define color variables for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

# Progress bar function
progress_bar() {
    local progress=$1
    local total=$2
    local width=50
    local percentage=$((progress * 100 / total))
    local completed=$((width * progress / total))
    local remaining=$((width - completed))
    
    printf "\r${BLUE}[${GREEN}"
    printf "%0.s█" $(seq 1 $completed)
    printf "%0.s░" $(seq 1 $remaining)
    printf "${BLUE}] ${WHITE}%d%%${RESET} - %s" $percentage "${3}"
}

# Function to print colorful section headers
print_section() {
    echo -e "\n${BOLD}${PURPLE}════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${YELLOW}  $1${RESET}"
    echo -e "${BOLD}${PURPLE}════════════════════════════════════════════════════════════════${RESET}\n"
}

# Function to print step information
print_step() {
    echo -e "${CYAN}[STEP]${RESET} ${WHITE}$1${RESET}"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

# Function to print information messages
print_info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}[WARNING]${RESET} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    print_error "This script requires root privileges. Please run with sudo."
    exit 1
fi

# Initialize variables
total_steps=15
current_step=0

# Display welcome message
clear
print_section "Ubuntu 24.04 Desktop Environment Setup Script"
print_info "This script will install a desktop environment and VNC server for remote access."

# Print the menu for desktop environment selection
print_section "Desktop Environment Selection"
echo -e "${WHITE}Select a desktop environment:${RESET}"
echo -e "${CYAN}1. ${WHITE}KDE Plasma${RESET}"
echo -e "${CYAN}2. ${WHITE}Xfce${RESET}"
echo -e "${CYAN}3. ${WHITE}UKUI${RESET}"
echo -ne "${YELLOW}Enter your choice (1/2/3) [default is KDE]: ${RESET}"

# Set timeout for user input (10 seconds)
read -t 10 choice

# Set the default choice if timeout occurs or invalid input is given
if [ -z "$choice" ]; then
    choice="1"
    print_info "No input received, defaulting to KDE Plasma."
fi

# Update progress
((current_step++))
progress_bar $current_step $total_steps "Desktop environment selected"

# Check if the .config directory exists
print_step "Checking for .config directory..."
config_dir="$HOME/.config"
if [ ! -d "$config_dir" ]; then
    print_info "The .config directory does not exist. Creating it..."
    mkdir -p "$config_dir"
fi

# Update progress
((current_step++))
progress_bar $current_step $total_steps "Config directory checked"

# Setup ngrok repository
print_step "Setting up ngrok repository..."
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list >/dev/null

# Update progress
((current_step++))
progress_bar $current_step $total_steps "Ngrok repository setup complete"

# Add Visual Studio Code repository
print_step "Setting up Visual Studio Code repository..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# Update progress
((current_step++))
progress_bar $current_step $total_steps "VS Code repository setup complete"

# Backup the existing sources.list
print_step "Backing up sources.list..."
cp /etc/apt/sources.list /etc/apt/sources.list.backup

# Update progress
((current_step++))
progress_bar $current_step $total_steps "Sources list backed up"

# Update package list
print_step "Updating package lists..."
apt update

# Update progress
((current_step++))
progress_bar $current_step $total_steps "Package lists updated"

# Install common packages
print_step "Installing common packages..."
apt install -y fonts-lohit-beng-bengali ngrok nemo code apt-transport-https firefox mesa-utils \
    pv nmap nano dialog autocutsel dbus-x11 dbus neofetch p7zip unzip zip \
    tigervnc-standalone-server tigervnc-xorg-extension novnc python3-websockify

# Update progress
((current_step++))
progress_bar $current_step $total_steps "Common packages installed"

# Set some environment variables
print_step "Setting up environment variables..."
export HOME=$(eval echo ~$SUDO_USER)
export DISPLAY=":0"

# Create VNC directory if it doesn't exist
if [ ! -d "$HOME/.vnc" ]; then
    print_info "Creating VNC directory..."
    mkdir -p "$HOME/.vnc"
fi

# Update progress
((current_step++))
progress_bar $current_step $total_steps "Environment setup complete"

# Install the selected desktop environment
print_step "Installing selected desktop environment..."
case "$choice" in
    "1")
        print_info "Installing KDE Plasma desktop environment..."
        apt install -y ark konsole gwenview kate okular kde-plasma-desktop
        # Remove kdeconnect to avoid network issues
        apt remove -y kdeconnect
        cat > "$HOME/.vnc/xstartup" << EOF
#!/bin/bash
dbus-launch &> /dev/null
autocutsel -fork
startplasma-x11
EOF
        ;;
    "2")
        print_info "Installing Xfce desktop environment..."
        apt install -y papirus-icon-theme xfce4 xfce4-goodies terminator
        cat > "$HOME/.vnc/xstartup" << EOF
#!/bin/bash
dbus-launch &> /dev/null
autocutsel -fork
xfce4-session
EOF
        ;;
    "3")
        print_info "Installing UKUI desktop environment..."
        apt install -y ukui* ukwm qt5-ukui-platformtheme kylin-nm
        cp $HOME/.Xauthority /root
        apt install -y ukui-settings-daemon ukwm
        cat > "$HOME/.vnc/xstartup" << EOF
#!/bin/bash
export GTK_IM_MODULE="fcitx"
export QT_IM_MODULE="fcitx"
export XMODIFIERS="@im=fcitx"
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
xrdb $HOME/.xresources
lightdm &
exec /usr/bin/ukui-session
EOF
        ;;
    *)
        print_warning "Invalid choice. Installing KDE by default..."
        apt install -y ark konsole gwenview kate okular kde-plasma-desktop
        cat > "$HOME/.vnc/xstartup" << EOF
#!/bin/bash
dbus-launch &> /dev/null
autocutsel -fork
startplasma-x11
EOF
        ;;
esac

chmod 755 $HOME/.vnc/xstartup

# Update progress
((current_step++))
progress_bar $current_step $total_steps "Desktop environment installed"

# Install Windows 10 Dark theme
print_step "Setting up Windows 10 Dark theme..."
if [ ! -d "/usr/share/themes/Windows-10-Dark-master" ]; then
    mkdir -p /tmp/theme
    wget -q -O /tmp/theme/Windows-10-Dark-master.zip https://github.com/B00merang-Project/Windows-10-Dark/archive/refs/heads/master.zip
    cd /usr/share/themes/ || exit 1
    unzip -qq /tmp/theme/Windows-10-Dark-master.zip
    rm -f /tmp/theme/Windows-10-Dark-master.zip
fi

# Update progress
((current_step++))
progress_bar $current_step $total_steps "Windows 10 Dark theme installed"

# Install WPS Office
print_step "Installing WPS Office..."
cd /tmp || exit 1
wget -q https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11701/wps-office_11.1.0.11701.XA_amd64.deb
apt install -y ./wps-office_11.1.0.11701.XA_amd64.deb

# Update progress
((current_step++))
progress_bar $current_step $total_steps "WPS Office installed"

# Creating the VPS script
print_step "Creating VPS script..."
cat > /usr/bin/vps << 'EOF'
#!/bin/bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

# Progress indicator function
show_spinner() {
    local pid=$1
    local message=$2
    local spin='-\|/'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r${CYAN}[WAIT]${RESET} ${message} ${YELLOW}${spin:$i:1}${RESET}"
        sleep 0.1
    done
    printf "\r${GREEN}[DONE]${RESET} ${message}${RESET}        \n"
}

# Function to display the progress bar
show_progress_bar() {
    local width=50
    while true; do
        for i in $(seq 1 $width); do
            completed=$i
            remaining=$((width - completed))
            percentage=$((i * 100 / width))
            
            # Print the progress bar
            printf "\r${BLUE}[${GREEN}"
            printf "%0.s█" $(seq 1 $completed)
            printf "%0.s░" $(seq 1 $remaining)
            printf "${BLUE}] ${WHITE}%d%%${RESET} - VNC Server Running" $percentage
            
            sleep 0.5
        done
    done
}

# Function to print section headers
print_section() {
    echo -e "\n${BOLD}${PURPLE}════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${YELLOW}  $1${RESET}"
    echo -e "${BOLD}${PURPLE}════════════════════════════════════════════════════════════════${RESET}\n"
}

# Redirect error output to /dev/null and set important environment variables
cd ~ || exit 1
unset DBUS_LAUNCH
export HOME="$(pwd)"
export DISPLAY=":0"

print_section "VNC Server Manager"

# Kill any running ngrok and websockify processes
echo -e "${CYAN}[STEP]${RESET} Terminating existing services..."
sudo killall -q ngrok
sudo killall -q websockify

# Stop any running desktop sessions
if pgrep xfce4-session >/dev/null; then
    echo -e "${CYAN}[STEP]${RESET} Stopping xfce4-session..."
    pkill xfce4-session
    sleep 2
fi

# Select the region for ngrok
print_section "Ngrok Region Selection"
while [[ -z $server ]]; do
    echo -e "${WHITE}Select your region:${RESET}"
    echo -e "${CYAN}1. ${WHITE}United States (Ohio)${RESET}"
    echo -e "${CYAN}2. ${WHITE}Europe (Frankfurt)${RESET}"
    echo -e "${CYAN}3. ${WHITE}Asia/Pacific (Singapore)${RESET}"
    echo -e "${CYAN}4. ${WHITE}Australia (Sydney)${RESET}"
    echo -e "${CYAN}5. ${WHITE}South America (Sao Paulo)${RESET}"
    echo -e "${CYAN}6. ${WHITE}Japan (Tokyo)${RESET}"
    echo -e "${CYAN}7. ${WHITE}India (Mumbai)${RESET}"
    echo -e "${CYAN}8. ${WHITE}Exit${RESET}"
    echo ""
    read -p "${GREEN}Region: ${RESET}" server

    case $server in
        1) regions="us";;
        2) regions="eu";;
        3) regions="ap";;
        4) regions="au";;
        5) regions="sa";;
        6) regions="jp";;
        7) regions="in";;
        8) echo -e "${YELLOW}Exiting...${RESET}"; exit 0;;
        *) echo -e "${RED}Invalid option. Please try again.${RESET}"; unset server;;
    esac
done

# Read and set ngrok authtoken
echo ""
read -p "${GREEN}Enter your ngrok authtoken: ${RESET}" key
echo -e "${CYAN}[STEP]${RESET} Setting ngrok authtoken..."
sudo ngrok authtoken "$key" &>/dev/null &
pid=$!
show_spinner $pid "Setting ngrok authtoken"

# Start ngrok
echo -e "${CYAN}[STEP]${RESET} Starting ngrok tunnel..."
nohup sudo ngrok tcp --region "$regions" 127.0.0.1:5900 &>/dev/null &

# Stop any running VNC server
if pgrep Xvnc >/dev/null; then
    echo -e "${CYAN}[STEP]${RESET} Stopping VNC server..."
    sudo killall Xvnc
    sleep 2
fi

# Clean up temporary files
echo -e "${CYAN}[STEP]${RESET} Cleaning temporary files..."
sudo rm -rf /tmp/* 2>/dev/null

# Start VNC server
echo -e "${CYAN}[STEP]${RESET} Starting VNC server..."
vncserver :0 &>/dev/null &
pid=$!
show_spinner $pid "Starting VNC server"

# Start websockify for NoVNC
echo -e "${CYAN}[STEP]${RESET} Setting up NoVNC web access..."
sudo mkdir -p /tmp/ssl_cert
sudo openssl req -new -x509 -days 365 -nodes -out /tmp/ssl_cert/novnc.pem -keyout /tmp/ssl_cert/novnc.pem -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" &>/dev/null
websockify -D --web=/usr/share/novnc/ --cert="/tmp/ssl_cert/novnc.pem" 8080 localhost:5900 &>/dev/null &
pid=$!
show_spinner $pid "Setting up NoVNC"

# Configure TCP keepalive settings
echo -e "${CYAN}[STEP]${RESET} Optimizing network settings..."
sudo /sbin/sysctl -w net.ipv4.tcp_keepalive_time=10000 net.ipv4.tcp_keepalive_intvl=5000 net.ipv4.tcp_keepalive_probes=100 &>/dev/null

# Restart services
echo -e "${CYAN}[STEP]${RESET} Restarting services..."
sall="$(service --status-all 2>/dev/null | grep '\-' | awk '{print $4}')"
while IFS= read -r line; do
    nohup sudo service "$line" restart &>/dev/null 2>/dev/null &
done < <(printf '%s\n' "$sall")

# Wait for ngrok to establish the tunnel
echo -e "${CYAN}[STEP]${RESET} Waiting for ngrok to establish connection..."
sleep 5

# Get the public URL for the ngrok tunnel
echo ""
print_section "Connection Information"
echo -ne "${WHITE}Your VNC Address: ${GREEN}"
curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p'
echo -e "${RESET}"

# Display information for accessing the VNC server
echo -e "${BLUE}[INFO]${RESET} You can use ${WHITE}NoVNC server${RESET} in your browser to view your Desktop."
echo -e "${BLUE}[INFO]${RESET} Access via: ${WHITE}http://localhost:8080/vnc.html${RESET}"
echo -e "${BLUE}[INFO]${RESET} Or use the address above with your VNC viewer."
echo ""

# Set the prompt with the default format
export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
echo -e "${GREEN}[SUCCESS]${RESET} VNC server is now running!"
echo ""

# Start progress bar in background
show_progress_bar &
progress_pid=$!

# Trap to kill the progress bar when the script exits
trap "kill $progress_pid 2>/dev/null" EXIT

# Keep the script running
wait
EOF
chmod +x /usr/bin/vps

# Update progress
((current_step++))
progress_bar $current_step $total_steps "VPS script created"

# Final cleanup
print_step "Running final cleanup..."
apt update -y
apt autoremove -y

# Update progress
((current_step++))
progress_bar $current_step $total_steps "Cleanup complete"

# Create .bashrc with vps alias
print_step "Updating .bashrc..."
if [ -f "$HOME/.bashrc" ]; then
    cp "$HOME/.bashrc" "$HOME/.bashrc_backup_$(date +%Y%m%d%H%M%S)"
    print_info "Your original .bashrc has been backed up."
fi

cat > "$HOME/.bashrc" << 'EOF'
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command
shopt -s checkwinsize

# make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# VPS shortcut
alias vps='sudo vps'

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Set neofetch to run on startup
neofetch
EOF

# Update progress
((current_step++))
progress_bar $current_step $total_steps "Bashrc updated"

# Set correct permissions
print_step "Setting permissions..."
chmod 777 -R "$HOME/.vnc"
chmod 644 "$HOME/.bashrc"

# Update progress
((current_step++))
progress_bar $current_step $total_steps "Permissions set"

# Installation completed message
print_section "Installation Complete!"
print_success "All components have been successfully installed!"
print_info "Type ${WHITE}vps${RESET} to start the VNC Server."

# Final progress bar
progress_bar $total_steps $total_steps "Setup complete!"
echo -e "\n"

exit 0