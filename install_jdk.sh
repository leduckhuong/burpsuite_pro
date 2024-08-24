#!/bin/bash

# Đường dẫn tải xuống JDK
JDK_URL="https://download.oracle.com/java/22/latest/jdk-22_linux-x64_bin.deb"

# Tên file .deb sau khi tải về
JDK_FILE="jdk-22_linux-x64_bin.deb"

# Thư mục tải xuống
DOWNLOAD_DIR="$HOME/Downloads"

# Tạo thư mục tải xuống nếu chưa tồn tại
mkdir -p $DOWNLOAD_DIR

# Di chuyển đến thư mục tải xuống
cd $DOWNLOAD_DIR

# Tải xuống JDK
echo "Đang tải JDK từ $JDK_URL ..."
wget -O $JDK_FILE $JDK_URL

# Kiểm tra nếu việc tải xuống thành công
if [ $? -eq 0 ]; then
    echo "Tải xuống thành công: $JDK_FILE"
else
    echo "Tải xuống thất bại!"
    exit 1
fi

# Cài đặt JDK
echo "Đang cài đặt JDK ..."
sudo dpkg -i $JDK_FILE

# Kiểm tra nếu việc cài đặt thành công
if [ $? -eq 0 ]; then
    echo "Cài đặt thành công JDK!"
else
    echo "Cài đặt thất bại!"
    exit 1
fi

# Xóa file .deb sau khi cài đặt
echo "Xóa file cài đặt..."
rm $JDK_FILE

echo "Hoàn tất!"

