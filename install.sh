#!/bin/bash

# Define color variables
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

# Box drawing characters
HORIZ='═'
VERT='║'
TOP_LEFT='╭'
TOP_RIGHT='╮'
BOTTOM_LEFT='╰'
BOTTOM_RIGHT='╯'

# Terminal width
TERM_WIDTH=$(tput cols)

# Function to center text
center_text() {
    local text="$1"
    local width="$2"
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%${padding}s%s%${padding}s\n" "" "$text" ""
}

# Function to create a box with a title
create_box() {
    local title="$1"
    local width=$(( TERM_WIDTH - 4 ))
    
    # Top border with title
    echo -e "${BOLD}${CYAN}${TOP_LEFT}${HORIZ}${HORIZ} ${MAGENTA}${title} ${CYAN}${HORIZ}$(printf '%*s' $((width - ${#title} - 5)) | tr ' ' "${HORIZ}")${TOP_RIGHT}${RESET}"
    
    # Return so content can be added
}

# Function to close a box
close_box() {
    local width=$(( TERM_WIDTH - 4 ))
    echo -e "${BOLD}${CYAN}${BOTTOM_LEFT}$(printf '%*s' $width | tr ' ' "${HORIZ}")${BOTTOM_RIGHT}${RESET}"
}

# Function to display a spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to display download progress bar
display_download_progress() {
    local package="$1"
    local size="$2"
    local width=$(( TERM_WIDTH - 40 ))
    
    echo -e "${BOLD}${CYAN}${TOP_LEFT}${HORIZ} Downloading ${package} ${HORIZ}${HORIZ}${HORIZ}${TOP_RIGHT}${RESET}"
    echo -e "${BOLD}${CYAN}${VERT}${RESET} Total Size: ${YELLOW}${size}${RESET}${CYAN}$(printf '%*s' $((width - ${#size} - 14)) '')${VERT}${RESET}"
    echo -e "${BOLD}${CYAN}${VERT}${RESET} ${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}${CYAN}${VERT}${RESET}"
    echo -e "${BOLD}${CYAN}${BOTTOM_LEFT}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${BOTTOM_RIGHT}${RESET}"
}

# Function to create a summary table
create_summary_table() {
    local title="$1"
    shift
    local items=("$@")
    local width=$(( TERM_WIDTH - 4 ))
    
    # Create a summary box like Nala's
    echo -e "${BOLD}${CYAN}${TOP_LEFT}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${TOP_RIGHT}${RESET}"
    echo -e "${BOLD}${CYAN}${VERT} ${MAGENTA}${title}$(printf '%*s' $((width - ${#title} - 1)) '')${CYAN}${VERT}${RESET}"
    echo -e "${BOLD}${CYAN}${VERT}$(printf '%*s' $width '')${VERT}${RESET}"
    
    # Display the items
    for item in "${items[@]}"; do
        echo -e "${BOLD}${CYAN}${VERT} ${GREEN}• ${WHITE}${item}$(printf '%*s' $((width - ${#item} - 4)) '')${CYAN}${VERT}${RESET}"
    done
    
    echo -e "${BOLD}${CYAN}${VERT}$(printf '%*s' $width '')${VERT}${RESET}"
    echo -e "${BOLD}${CYAN}${BOTTOM_LEFT}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${HORIZ}${BOTTOM_RIGHT}${RESET}"
}

# Function to display installation items
display_install_items() {
    local title="$1"
    shift
    local items=("$@")
    local width=$(( TERM_WIDTH - 4 ))
    
    # Create header like Nala's
    echo -e "${BOLD}${CYAN}${TOP_LEFT}$(printf '%*s' $width | tr ' ' "${HORIZ}")${TOP_RIGHT}${RESET}"
    echo -e "${BOLD}${CYAN}${VERT} ${MAGENTA}${title}$(printf '%*s' $((width - ${#title} - 1)) '')${CYAN}${VERT}${RESET}"
    echo -e "${BOLD}${CYAN}${VERT}$(printf '%*s' $width '')${VERT}${RESET}"
    
    # Headers
    echo -e "${BOLD}${CYAN}${VERT}  ${WHITE}Package:$(printf '%50s' '')Version:$(printf '%40s' '')Size:  ${CYAN}${VERT}${RESET}"
    
    # Display the items
    for item in "${items[@]}"; do
        # Parse package, version, and size from the item
        package=$(echo "$item" | cut -d ':' -f 1)
        version=$(echo "$item" | cut -d ':' -f 2)
        size=$(echo "$item" | cut -d ':' -f 3)
        
        echo -e "${BOLD}${CYAN}${VERT}  ${GREEN}${package}$(printf '%*s' $((50 - ${#package})) '')${YELLOW}${version}$(printf '%*s' $((40 - ${#version})) '')${CYAN}${size}  ${CYAN}${VERT}${RESET}"
    done
    
    echo -e "${BOLD}${CYAN}${VERT}$(printf '%*s' $width '')${VERT}${RESET}"
    echo -e "${BOLD}${CYAN}${BOTTOM_LEFT}$(printf '%*s' $width | tr ' ' "${HORIZ}")${BOTTOM_RIGHT}${RESET}"
}

# Function to create selection menu
create_menu() {
    local title="$1"
    shift
    local options=("$@")
    local width=$(( TERM_WIDTH - 4 ))
    
    create_box "$title"
    
    # Display the options
    for i in "${!options[@]}"; do
        echo -e "${BOLD}${CYAN}${VERT} ${YELLOW}$((i+1)). ${GREEN}${options[$i]}${RESET}$(printf '%*s' $((width - ${#options[$i]} - 5)) '')${BOLD}${CYAN}${VERT}${RESET}"
    done
    
    # Bottom of the menu
    echo -e "${BOLD}${CYAN}${VERT}$(printf '%*s' $width '')${VERT}${RESET}"
    close_box
    
    echo -e "${CYAN}Enter your choice (1-${#options[@]}) [default is 1]: ${RESET}"
}

# Function to display progress bar (similar to Nala's)
display_progress() {
    local message="$1"
    local current="$2"
    local total="$3"
    local width=$(( TERM_WIDTH - 40 ))
    local completed=$(( width * current / total ))
    local remaining=$(( width - completed ))
    
    echo -ne "\r${BOLD}${CYAN}${VERT} ${message} ${GREEN}"
    printf '%*s' "$completed" | tr ' ' '━'
    printf '%*s' "$remaining" | tr ' ' '╺'
    echo -ne " ${WHITE}${current}/${total} ${CYAN}${VERT}${RESET}"
}

# Clear screen and show welcome message
clear
echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${BLUE}║                                                        ║${RESET}"
echo -e "${BOLD}${BLUE}║  ${GREEN}Ubuntu 24.04 Desktop Environment Installer${BLUE}             ║${RESET}"
echo -e "${BOLD}${BLUE}║  ${YELLOW}Optimized installation script for Cloud environments${BLUE}  ║${RESET}"
echo -e "${BOLD}${BLUE}║                                                        ║${RESET}"
echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════╝${RESET}\n"

# Display desktop environment options
create_menu "Select a desktop environment" "KDE - A complete, feature-rich desktop" "Xfce - Lightweight and efficient desktop" "UKUI - Modern and intuitive desktop"

# Read user choice with timeout
read -t 10 choice

# Set default choice
if [ -z "$choice" ]; then
    choice="1"
    echo -e "${YELLOW}No input received. Defaulting to KDE.${RESET}"
fi

# Create a summary table of what will be installed
echo
create_summary_table "Installation Summary" "Desktop Environment: $([ "$choice" = "1" ] && echo "KDE" || [ "$choice" = "2" ] && echo "Xfce" || echo "UKUI")" "Additional Software: VSCode, Firefox, WPS Office, Ngrok" "Total disk space required: ~800 MB"

# Ask for confirmation
echo -e "\n${CYAN}Do you want to continue? [Y/n] ${RESET}"
read -t 10 confirm
if [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
    echo -e "${RED}Installation aborted.${RESET}"
    exit 1
fi

echo

# Begin installation with progress tracking
create_box "Installation Progress"

# List of installation steps
steps=("Setting up system repositories" "Updating package lists" "Installing common packages" "Setting up environment" "Installing selected desktop environment" "Setting up VNC configuration" "Setting permissions and cleaning up" "Installing system theme" "Configuring bash environment" "Installing additional software")
total_steps=${#steps[@]}

# Simulate installation process with progress updates
for i in $(seq 0 $(( total_steps - 1 ))); do
    # Display current step
    echo -e "${BOLD}${CYAN}${VERT} ${MAGENTA}${steps[$i]}${RESET}$(printf '%*s' $((TERM_WIDTH - ${#steps[$i]} - 6)) '')${BOLD}${CYAN}${VERT}${RESET}"
    
    # Display progress bar
    display_progress "Progress:" $(( i + 1 )) $total_steps
    echo
    
    # Simulate some work for each step (replace with actual commands)
    case $i in
        0)
            echo -e "${BOLD}${CYAN}${VERT} ${GREEN}Setting up Ngrok repository...${RESET}$(printf '%*s' $((TERM_WIDTH - 30)) '')${BOLD}${CYAN}${VERT}${RESET}"
            sleep 1
            echo -e "${BOLD}${CYAN}${VERT} ${GREEN}Setting up Visual Studio Code repository...${RESET}$(printf '%*s' $((TERM_WIDTH - 42)) '')${BOLD}${CYAN}${VERT}${RESET}"
            sleep 1
            ;;
        1)
            echo -e "${BOLD}${CYAN}${VERT} ${GREEN}Updating package lists...${RESET}$(printf '%*s' $((TERM_WIDTH - 26)) '')${BOLD}${CYAN}${VERT}${RESET}"
            display_download_progress "package information" "10.5 MB"
            sleep 1
            ;;
        2)
            # Show installation items
            local_items=("firefox:2.24.7-1.2ubuntu7.3:211 KB" "ngrok:1:3.27-3.1build1:31 KB" "nemo:2.3.12-1ubuntu0.24.04.1:158 KB")
            display_install_items "Installing common packages" "${local_items[@]}"
            sleep 2
            ;;
        *)
            # Simulate some work
            sleep 1
            ;;
    esac
done

close_box

# Installation completed message
echo -e "\n${BOLD}${GREEN}╔════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${GREEN}║            Installation completed!             ║${RESET}"
echo -e "${BOLD}${GREEN}║                                                ║${RESET}"
echo -e "${BOLD}${GREEN}║  ${YELLOW}Type ${CYAN}vps${YELLOW} to start the VNC Server!${GREEN}          ║${RESET}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════╝${RESET}\n"

exit 0