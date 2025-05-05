#!/bin/bash

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
    echo "[!] Vui lòng chạy script với quyền root (sudo)"
    exit 1
fi


echo "[*] Kiểm tra curl..."
if ! command -v curl >/dev/null 2>&1; then
    echo "[+] curl chưa được cài, đang tiến hành cài đặt..."
    sudo apt-get update
    sudo apt-get install -y curl
else
    echo "[✓] curl đã được cài."
fi

# Thiết lập thư mục và icon
echo "[*] Thiết lập thư mục và icon Burp Suite..."
mkdir -p /usr/share/burpsuite
cp loader.jar /usr/share/burpsuite/
cp burpsuitepro.png /usr/share/burpsuite/

# Tải bản mới nhất của Burp Suite
echo "[*] Đang tải bản mới nhất của Burp Suite..."
cd /usr/share/burpsuite/
html=$(curl -s https://portswigger.net/burp/releases)
version=$(echo "$html" | grep -Po '(?<=/burp/releases/professional-community-)[0-9]+\-[0-9]+\-[0-9]+' | head -n 1)
download_url="https://portswigger-cdn.net/burp/releases/download?product=pro&version=&type=jar"

echo "[*] Phiên bản mới nhất: $version"
wget "$download_url" -O "burpsuite_pro_v$version.jar" --quiet --show-progress
sleep 2

# Tạo script khởi chạy burpsuite
echo "[*] Tạo lệnh burpsuite..."
cat <<EOF > /usr/share/burpsuite/burpsuite
#!/bin/bash
java --add-opens=java.desktop/javax.swing=ALL-UNNAMED \
     --add-opens=java.base/java.lang=ALL-UNNAMED \
     --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED \
     --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED \
     --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED \
     -javaagent:$(pwd)/loader.jar -noverify -jar $(pwd)/burpsuite_pro_v$version.jar &
wait
EOF

chmod +x /usr/share/burpsuite/burpsuite
cp /usr/share/burpsuite/burpsuite /bin/burpsuite

# Tạo keygen
echo "[*] Tạo lệnh burploader (Keygen)..."
echo "java -jar /usr/share/burpsuite/loader.jar" > /usr/bin/burploader
chmod +x /usr/bin/burploader

# Khởi động keygen + burpsuite
echo "[*] Khởi động keygen và Burp Suite..."
(java -jar /usr/share/burpsuite/loader.jar) &
sleep 3
(/bin/burpsuite)


echo "[✓] Đã hoàn tất cài đặt Burp Suite Professional!"