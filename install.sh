#!/bin/sh

echo "Preparing to install...."
unzip ngrok-stable-linux-amd64.zip > /dev/null 2>&1; rm ngrok-stable-linux-amd64.zip 2> /dev/null
sudo mv ./ngrok /bin/ngrok; sudo chmod +x /bin/ngrok
read -p "INSERT authtoken ngrok: " key
ngrok authtoken $key
echo ""
echo "Cloud Shell already runs on Debian. Just installing the DE and some apps(Xfce amd64)...."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update -y > /dev/null 2>&1
sudo apt install openssl code wget software-properties-common apt-transport-https ufw fish apache2 php xfce4 xarchiver firefox-esr mesa-utils xfce4-goodies pv nmap nano apt-utils dialog terminator autocutsel dbus-x11 dbus neofetch perl p7zip unzip zip curl tar git python3 python3-pip net-tools openssl tigervnc-standalone-server tigervnc-xorg-extension novnc python3-websockify -y
export installer="$(pwd)"
cd ~/ 2> /dev/null
export HOME="$(pwd)"
echo "You are about to be asked to enter information for making a https certificate.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
You can just press enter, the field will be left blank. And it will still proceed"
openssl req -x509 -nodes -newkey rsa:3072 -keyout novnc.pem -out novnc.pem -days 3650
export DISPLAY=":0"
cd $HOME 2> /dev/null
sudo mkdir ~/.vnc 2> /dev/null
if [ ! -d ~/.config ] 2> /dev/null; then
  sudo mkdir ~/.config 2> /dev/null
fi
if [ ! -d ~/.config/fish ] 2> /dev/null; then
  sudo mkdir ~/.config/fish 2> /dev/null
fi
echo "set fish_greeting" > ~/.config/fish/config.fish
chmod -R 777 ~/.config 2> /dev/null
sudo printf '#!/bin/bash\ndbus-launch &> /dev/null\nautocutsel -fork\nxfce4-session\n' > ~/.vnc/xstartup
cd $installer 2> /dev/null
sudo mv ./startvps.sh /bin/startvps 2> /dev/null
sudo mv ~/.bashrc ~/.bashrc_old 2> /dev/null
echo "Your ~/.bashrc is being modified. Backed up the the old .bashrc file as .bashrc_old"
sudo mv ./setupPS.sh ~/.bashrc 2> /dev/null
sudo mv ./apache2.conf /etc/apache2/apache2.conf 2> /dev/null
sudo chmod 777 -R ~/.vnc 2> /dev/null
sudo chmod 777 ~/.bashrc 2> /dev/null
sudo chmod 777 /bin/startvps 2> /dev/null
sudo chmod 777 /etc/apache2/apache2.conf 2> /dev/null
sudo apt update -y > /dev/null 2>&1
sudo apt autoremove -y
if [ ! -d /usr/share/themes/Windows-10-Dark-master ] 2> /dev/null; then
  cd /usr/share/themes/ 2> /dev/null
  sudo cp $installer/app/Windows-10-Dark-master.zip ./
  unzip -qq Windows-10-Dark-master.zip 2> /dev/null
  rm -f Windows-10-Dark-master.zip 2> /dev/null
fi
cd $HOME 2> /dev/null
clear
printf "\n\n\n - Installation completed!\n Run: [startvps] to start VNC Server!\n\n"
exit 0
