#!/bin/bash

# ==========================================
#   SOCKS5 Toolbox by mic678899-wq
# ==========================================

INSTALL_URL="https://raw.githubusercontent.com/mic678899-wq/sk5/main/install_socks5.sh"
UNINSTALL_URL="https://raw.githubusercontent.com/mic678899-wq/sk5/main/d_socks5.sh"

menu() {
    clear
    echo "======================================="
    echo "           SOCKS5 工具箱"
    echo "======================================="
    echo " 1. 安装 SOCKS5"
    echo " 2. 卸载 SOCKS5"
    echo " 3. 查看服务状态"
    echo " 4. 重启 SOCKS5"
    echo " 5. 退出"
    echo "======================================="
    read -p "请输入选项 [1-5]: " choice

    case $choice in
        1)
            install_socks5
            ;;
        2)
            uninstall_socks5
            ;;
        3)
            status_socks5
            ;;
        4)
            restart_socks5
            ;;
        5)
            exit 0
            ;;
        *)
            echo "输入错误，请重新选择"
            sleep 1
            menu
            ;;
    esac
}

install_socks5() {
    echo "正在下载安装脚本..."
    bash <(curl -fsSL $INSTALL_URL)
    echo
    read -p "按回车键继续..." enter
    menu
}

uninstall_socks5() {
    echo "正在卸载 SOCKS5..."
    bash <(curl -fsSL $UNINSTALL_URL)
    echo
    read -p "按回车键继续..." enter
    menu
}

status_socks5() {
    echo "正在查看状态..."
    systemctl status socks5
    echo
    read -p "按回车键继续..." enter
    menu
}

restart_socks5() {
    echo "重启 SOCKS5 服务..."
    systemctl restart socks5
    echo "已重启"
    sleep 1
    menu
}

menu
