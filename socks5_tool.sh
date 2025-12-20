#!/bin/bash

# ==========================================
#   SOCKS5 Toolbox by mic678899-wq
# ==========================================

INSTALL_URL="https://raw.githubusercontent.com/mic678899-wq/sk5/main/install_socks5.sh"
UNINSTALL_URL="https://raw.githubusercontent.com/mic678899-wq/sk5/main/d_socks5.sh"
CONFIG_FILE="/etc/sing-box/config.json"

get_ipv4() {
    curl -s ipv4.ip.sb || curl -s ifconfig.me
}

get_ipv6() {
    curl -6 -s ipv6.ip.sb 2>/dev/null
}

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
    echo " 8. 切换监听模式（IPv4 / IPv6）"
    echo " 0. 退出"
    echo "======================================="
    read -p "请输入选项 [0-8]: " choice

    case $choice in
        1) install_socks5 ;;
        2) uninstall_socks5 ;;
        3) status_socks5 ;;
        4) restart_socks5 ;;
        5) modify_socks5 ;;
        6) show_socks5 ;;
        7) random_reset ;;
        8) switch_ip ;;
        0) exit 0 ;;
        *) echo "输入错误"; sleep 1; menu ;;
    esac
}

install_socks5() {
    bash <(curl -fsSL $INSTALL_URL)
    read -p "回车继续..." _
    menu
}

uninstall_socks5() {
    bash <(curl -fsSL $UNINSTALL_URL)
    read -p "回车继续..." _
    menu
}

status_socks5() {
    systemctl status sing-box.service
    read -p "回车继续..." _
    menu
}

restart_socks5() {
    systemctl restart sing-box.service
    echo "✔ 已重启"
    sleep 1
    menu
}

modify_socks5() {
    [ ! -f "$CONFIG_FILE" ] && echo "未安装 SOCKS5" && sleep 2 && menu

    read -p "新端口（回车跳过）: " P
    read -p "新用户名（回车跳过）: " U
    read -p "新密码（回车跳过）: " PW

    [ -n "$P" ] && sed -i "s/\"listen_port\": [0-9]\+/\\"listen_port\\": $P/" $CONFIG_FILE
    [ -n "$U" ] && sed -i "s/\"username\": \".*\"/\"username\": \"$U\"/" $CONFIG_FILE
    [ -n "$PW" ] && sed -i "s/\"password\": \".*\"/\"password\": \"$PW\"/" $CONFIG_FILE

    systemctl restart sing-box.service
    echo "✔ 修改完成"
    sleep 1
    menu
}

show_socks5() {
    [ ! -f "$CONFIG_FILE" ] && echo "未安装 SOCKS5" && sleep 2 && menu

    PORT=$(grep -oP '"listen_port":\s*\K\d+' $CONFIG_FILE)
    USER=$(grep -oP '"username":\s*"\K[^"]+' $CONFIG_FILE)
    PASS=$(grep -oP '"password":\s*"\K[^"]+' $CONFIG_FILE)

    IPV4=$(get_ipv4)
    IPV6=$(get_ipv6)

    echo "======================================="
    echo " SOCKS5 信息"
    echo "======================================="
    [ -n "$IPV4" ] && echo " IPv4 : $IPV4:$PORT"
    [ -n "$IPV6" ] && echo " IPv6 : [$IPV6]:$PORT"
    echo " 用户名 : $USER"
    echo " 密码   : $PASS"
    echo "======================================="
    read -p "回车继续..." _
    menu
}

random_reset() {
    [ ! -f "$CONFIG_FILE" ] && echo "未安装 SOCKS5" && sleep 2 && menu

    P=$(shuf -i 10000-60000 -n 1)
    U=$(tr -dc a-z0-9 </dev/urandom | head -c 8)
    PW=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)

    sed -i "s/\"listen_port\": [0-9]\+/\\"listen_port\\": $P/" $CONFIG_FILE
    sed -i "s/\"username\": \".*\"/\"username\": \"$U\"/" $CONFIG_FILE
    sed -i "s/\"password\": \".*\"/\"password\": \"$PW\"/" $CONFIG_FILE

    systemctl restart sing-box.service

    echo "✔ 已随机重置"
    echo " 端口: $P"
    echo " 用户: $U"
    echo " 密码: $PW"
    sleep 2
    menu
}

switch_ip() {
    [ ! -f "$CONFIG_FILE" ] && echo "未安装 SOCKS5" && sleep 2 && menu

    if ip -6 addr | grep -q inet6; then
        read -p "切换到 IPv6 双栈监听？(y/n): " yn
        if [[ $yn == "y" ]]; then
            sed -i 's/"listen": "0.0.0.0"/"listen": "::"/' $CONFIG_FILE
            systemctl restart sing-box.service
            echo "✔ 已切换为 IPv6 + IPv4 双栈"
        fi
    else
        echo "❌ 当前服务器没有 IPv6"
    fi
    sleep 2
    menu
}

menu
