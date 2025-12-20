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
    echo " 6. 查看端口 / 用户名 / 密码"
    echo " 7. 随机重置端口 + 账号密码"
    echo " 0. 退出"
    echo "======================================="
    read -p "请输入选项 [0-7]: " choice

    case $choice in
        1) install_socks5 ;;
        2) uninstall_socks5 ;;
        3) status_socks5 ;;
        4) restart_socks5 ;;
        5) modify_socks5 ;;
        6) show_socks5 ;;
        7) random_reset ;;
        0) exit 0 ;;
        *) echo "输入错误，请重新选择"; sleep 1; menu ;;
    esac
}

install_socks5() {
    bash <(curl -fsSL $INSTALL_URL)
    read -p "按回车键继续..." enter
    menu
}

uninstall_socks5() {
    bash <(curl -fsSL $UNINSTALL_URL)
    read -p "按回车键继续..." enter
    menu
}

status_socks5() {
    systemctl status sing-box.service
    read -p "按回车键继续..." enter
    menu
}

restart_socks5() {
    systemctl restart sing-box.service
    echo "✔ 已重启 sing-box"
    sleep 1
    menu
}

modify_socks5() {
    [ ! -f "$CONFIG_FILE" ] && echo "未安装 SOCKS5" && sleep 2 && menu

    echo "====== 手动修改配置 ======"
    read -p "新端口（回车跳过）: " NEW_PORT
    read -p "新用户名（回车跳过）: " NEW_USER
    read -p "新密码（回车跳过）: " NEW_PASS

    [ -n "$NEW_PORT" ] && sed -i "s/\"listen_port\": [0-9]\+/\\"listen_port\\": $NEW_PORT/" $CONFIG_FILE
    [ -n "$NEW_USER" ] && sed -i "s/\"username\": \".*\"/\"username\": \"$NEW_USER\"/" $CONFIG_FILE
    [ -n "$NEW_PASS" ] && sed -i "s/\"password\": \".*\"/\"password\": \"$NEW_PASS\"/" $CONFIG_FILE

    systemctl restart sing-box.service
    echo "✔ 修改完成并已重启"
    sleep 2
    menu
}

show_socks5() {
    [ ! -f "$CONFIG_FILE" ] && echo "未安装 SOCKS5" && sleep 2 && menu

    PORT=$(grep -oP '"listen_port":\s*\K\d+' $CONFIG_FILE)
    USER=$(grep -oP '"username":\s*"\K[^"]+' $CONFIG_FILE)
    PASS=$(grep -oP '"password":\s*"\K[^"]+' $CONFIG_FILE)
    IP=$(curl -s ipv4.ip.sb || curl -s ifconfig.me)

    echo "======================================="
    echo " SOCKS5 当前信息"
    echo "======================================="
    echo " IP       : $IP"
    echo " 端口     : $PORT"
    echo " 用户名   : $USER"
    echo " 密码     : $PASS"
    echo " 地址     : $IP:$PORT"
    echo "======================================="
    read -p "按回车键继续..." enter
    menu
}

random_reset() {
    [ ! -f "$CONFIG_FILE" ] && echo "未安装 SOCKS5" && sleep 2 && menu

    NEW_PORT=$(shuf -i 10000-60000 -n 1)
    NEW_USER=$(tr -dc 'a-z0-9' </dev/urandom | head -c 8)
    NEW_PASS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16)

    sed -i "s/\"listen_port\": [0-9]\+/\\"listen_port\\": $NEW_PORT/" $CONFIG_FILE
    sed -i "s/\"username\": \".*\"/\"username\": \"$NEW_USER\"/" $CONFIG_FILE
    sed -i "s/\"password\": \".*\"/\"password\": \"$NEW_PASS\"/" $CONFIG_FILE

    systemctl restart sing-box.service

    IP=$(curl -s ipv4.ip.sb || curl -s ifconfig.me)

    echo "======================================="
    echo " 随机重置完成"
    echo "======================================="
    echo " IP       : $IP"
    echo " 端口     : $NEW_PORT"
    echo " 用户名   : $NEW_USER"
    echo " 密码     : $NEW_PASS"
    echo " 地址     : $IP:$NEW_PORT"
    echo "======================================="
    read -p "按回车键继续..." enter
    menu
}

menu
