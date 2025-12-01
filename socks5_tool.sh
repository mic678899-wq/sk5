#!/bin/bash

# ==========================================
#   SOCKS5 Toolbox by mic678899-wq
# ==========================================

INSTALL_URL="https://raw.githubusercontent.com/mic678899-wq/sk5/main/install_socks5.sh"
UNINSTALL_URL="https://raw.githubusercontent.com/mic678899-wq/sk5/main/d_socks5.sh"
CONFIG_FILE="/etc/sing-box/config.json"

menu() {
    clear
    echo "======================================="
    echo "           SOCKS5 工具箱"
    echo "======================================="
    echo " 1. 安装 SOCKS5"
    echo " 2. 卸载 SOCKS5"
    echo " 3. 查看服务状态"
    echo " 4. 重启 SOCKS5"
    echo " 5. 修改端口或用户名/密码"
    echo " 6. 退出"
    echo "======================================="
    read -p "请输入选项 [1-6]: " choice

    case $choice in
        1) install_socks5 ;;
        2) uninstall_socks5 ;;
        3) status_socks5 ;;
        4) restart_socks5 ;;
        5) modify_socks5 ;;
        6) exit 0 ;;
        *) echo "输入错误，请重新选择"; sleep 1; menu ;;
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
    systemctl status sing-box.service
    echo
    read -p "按回车键继续..." enter
    menu
}

restart_socks5() {
    echo "重启 SOCKS5 服务..."
    systemctl restart sing-box.service
    echo "已重启"
    sleep 1
    menu
}

modify_socks5() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "未找到 $CONFIG_FILE，请先安装 SOCKS5"
        sleep 2
        menu
        return
    fi

    echo "========== 修改 SOCKS5 配置 =========="
    read -p "输入新端口（留空保持不变）: " NEW_PORT
    read -p "输入新用户名（留空保持不变）: " NEW_USER
    read -p "输入新密码（留空保持不变）: " NEW_PASS

    # 修改端口
    if [ ! -z "$NEW_PORT" ]; then
        sed -i "s/\"listen_port\": [0-9]\+/\\"listen_port\\": $NEW_PORT/" $CONFIG_FILE
    fi

    # 修改用户名
    if [ ! -z "$NEW_USER" ]; then
        sed -i "s/\"username\": \".*\"/\"username\": \"$NEW_USER\"/" $CONFIG_FILE
    fi

    # 修改密码
    if [ ! -z "$NEW_PASS" ]; then
        sed -i "s/\"password\": \".*\"/\"password\": \"$NEW_PASS\"/" $CONFIG_FILE
    fi

    # 重启服务
    systemctl restart sing-box.service
    echo "修改完成，sing-box 已重启！"
    sleep 2
    menu
}

menu
