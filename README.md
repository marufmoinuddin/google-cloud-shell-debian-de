# Debian Desktop on Google Shell
 - Run Debian with KDE or xfce DE UKUI(WIP) on Google Cloud Shell

## Introduction

Google Cloud Shell offers a powerful cloud-based development environment that enables you to manage and run your code directly from your browser. With the ability to execute commands, access tools, and utilize various resources, Google Cloud Shell provides an excellent platform for development and experimentation. 

## Home Storage and Volatile Root Storage

1. **Home Storage**: Every Google Cloud Shell user is granted a generous 5GB of persistent home storage. This space is your personal area to store files, scripts, code, and other project-related data. It remains available and accessible across sessions, providing a convenient way to continue working on your projects without worrying about losing data. Moreover, your desktop data, such as Firefox data and desktop settings, will be saved through sessions, as these are typically stored in your home storage.

2. **Volatile Root Storage**: In addition to the home storage, Google Cloud Shell also allocates a separate volatile storage space. This space is used for temporary data, session-related files, and any other short-term requirements. It ensures that your sessions remain responsive and performant, as volatile storage is optimized for speed and temporary data manipulation.


## Getting Started
 - Video Tutorial: [Coming Soon]

1. Open [Google Cloud Shell](https://shell.cloud.google.com/?show=terminal)
2. Install git:
   ```bash
   sudo apt update && sudo apt install -y git
   ```
3. Paste this code to the shell and hit Enter:

   ```bash
   cd ~
   git clone https://github.com/marufmoinuddin/google-cloud-shell-debian-de.git
   cd google-cloud-shell-debian-de
   sh install.sh
   ```
6. Wait for the install to finish. There might be some prompts you need to interact with!
7. When install finishes there will be a message saying to type `vps` and hit enter.
   
## How to start?
1. Use this command and interact with the on screen prompts:
   ```bash
   vps
   ```
(Optional. If you donot want ngrok just press Enter while in the input prompt)

2. Get authtoken ngrok [Here](https://dashboard.ngrok.com/get-started/your-authtoken) . Or You can use port 8080 to visit the desktop.
3. Insert your authtoken ngrok
2. Wait a moment, you will get the IP
3. Use VNC Viewer to connect to that IP! Or go to port 8080. Enjoy

## Coming Soon:
mount the google cloud storage on your own Desktop (I may create another repo for that) 
