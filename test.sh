#!/bin/bash

# Tạo file burpsuite.desktop
mkdir -p ~/.local/share/applications
touch ~/.local/share/applications/burpsuite.desktop

echo "[*] Tạo shortcut Burp Suite..."
cat <<EOF > ~/.local/share/applications/burpsuite.desktop
[Desktop Entry]
Version=1.0
Name=Burp Suite Professional
Comment=Launch Burp Suite
Exec=/bin/burpsuite
Icon=/usr/share/burpsuite/burpsuitepro.png
Terminal=false
Type=Application
Categories=Development;Security;
EOF

chmod +x ~/.local/share/applications/burpsuite.desktop
xdg-desktop-menu forceupdate
