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

# Cài Java JDK 21 nếu chưa có
if ! command -v javac >/dev/null 2>&1; then
    echo "[+] Đang cài đặt Java JDK 21..."
    mkdir -p /usr/local/java/jdk21
    curl -L https://download.oracle.com/java/21/archive/jdk-21_linux-x64_bin.tar.gz -o jdk21.tar.gz
    tar -xf jdk21.tar.gz -C /usr/local/java/jdk21 --strip-components=1
    rm jdk21.tar.gz

    echo "export JAVA_HOME=/usr/local/java/jdk21" | tee -a /etc/environment
    echo 'export PATH=$PATH:$JAVA_HOME/bin' | tee -a /etc/environment

    export JAVA_HOME=/usr/local/java/jdk21
    export PATH=$PATH:$JAVA_HOME/bin

    update-alternatives --install /usr/bin/java java /usr/local/java/jdk21/bin/java 1
    update-alternatives --install /usr/bin/javac javac /usr/local/java/jdk21/bin/javac 1

    echo "[✓] Đã cài đặt Java JDK 21."
else
    echo "[✓] Java JDK đã có sẵn."
fi

# Cài Java JRE 8 nếu cần (nếu java chưa có)
if ! java -version 2>&1 | grep -q "1.8.0"; then
    echo "[+] Đang cài đặt Java JRE 8..."
    JRE_DIR=/usr/local/java/jre8
    mkdir -p $JRE_DIR

    jre8_url="https://javadl.oracle.com/webapps/download/AutoDL?BundleId=247938_0ae14417abb444ebb02b9815e2103550"
    curl -L -o $JRE_DIR/jre8.tar.gz "$jre8_url"
    tar -xzf $JRE_DIR/jre8.tar.gz -C $JRE_DIR
    rm $JRE_DIR/jre8.tar.gz

    update-alternatives --install /usr/bin/java java $JRE_DIR/jre1.8.0_361/bin/java 1
    update-alternatives --install /usr/bin/javac javac $JRE_DIR/jre1.8.0_361/bin/javac 1
    update-alternatives --set java $JRE_DIR/jre1.8.0_361/bin/java
    update-alternatives --set javac $JRE_DIR/jre1.8.0_361/bin/javac

    echo "[✓] Đã cài đặt Java JRE 8."
fi

# Thiết lập thư mục và icon
echo "[*] Thiết lập thư mục và icon Burp Suite..."
mkdir -p /usr/share/burpsuite
cp loader.jar /usr/share/burpsuite/
cp burpsuitepro.png /usr/share/burpsuite/

# Tạo file burpsuite.desktop
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
