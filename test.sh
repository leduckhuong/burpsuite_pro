#!/bin/bash

# Kiểm tra có phải root không và không phải đang dùng sudo
if [[ $(id -un) != "root" || -n "$SUDO_USER" ]]; then
    echo "[!] Vui lòng chạy script từ môi trường root shell (dùng 'sudo su' rồi chạy script)"
    exit 1
fi

echo "[*] Bạn đang ở root shell, tiếp tục chạy script..."
