# Debian Xfce Desktop on Google Shell
 - Run Debian with xfce DE on Google Cloud Shell

# How to install?
 - Tutorial: [Not-available]

1. Open [Google Cloud Shell](https://shell.cloud.google.com/?show=terminal)
2. Install git:
   ```bash
   sudo apt update && sudo apt install -y git
   ```
3. Go to home directory, Clone this repository then enter to that directory and exectute install.sh:

```bash
cd ~
git clone https://github.com/marufmoinuddin/google-cloud-shell-debian-de.git
cd google-cloud-shell-debian-de
sudo bash install.sh
```

4. Get authtoken ngrok [Here](https://dashboard.ngrok.com/get-started/your-authtoken) [Required ngrok account]

5. Insert your authtoken ngrok

6. Wait for install!

# How to start?

1. Use this command:

```bash
startvps
```

2. Wait a moment, you will get the IP
3. Use VNC Viewer to connect to that IP! Enjoy
 
