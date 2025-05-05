#!/bin/bash

# Kiểm tra nếu không phải đang trong môi trường root shell (sudo su)
if [[ $(id -un) != "root" || -n "$SUDO_USER" ]]; then
    echo "[!] Vui lòng chạy script từ môi trường root shell (dùng 'sudo su' rồi chạy script)"
    exit 1
fi

echo "[*] Bạn đang trong root shell. Tiếp tục chạy script..."
