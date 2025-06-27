#!/bin/bash

set -e

# Параметры
XRAY_PATH="/usr/local/bin/xray"
XRAY_CONFIG="/etc/xray/config.json"
XRAY_SERVICE="/etc/systemd/system/xray.service"
PORT=443
UUID=$(cat /proc/sys/kernel/random/uuid)
CERT_DIR="/etc/xray/cert"
CERT_KEY="$CERT_DIR/xray.key"
CERT_CRT="$CERT_DIR/xray.crt"
WS_PATH="/ws"

# Получение публичного IP-адреса сервера
get_public_ip() {
    curl -s https://ifconfig.me
}

# Установка необходимых зависимостей
install_dependencies() {
    apt update
    apt install -y curl wget jq socat unzip
    apt install -y qrencode || true
    apt install -y openssl
}

# Установка Xray-core, если он ещё не установлен
install_xray() {
    if [ ! -f "$XRAY_PATH" ]; then
        wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
        unzip /tmp/xray.zip -d /tmp/xray
        install -m 755 /tmp/xray/xray "$XRAY_PATH"
        mkdir -p /etc/xray
        rm -rf /tmp/xray /tmp/xray.zip
    fi
}

# Генерация самоподписанного сертификата
generate_selfsigned_cert() {
    mkdir -p "$CERT_DIR"
    if [ ! -f "$CERT_KEY" ] || [ ! -f "$CERT_CRT" ]; then
        openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -keyout "$CERT_KEY" \
            -out "$CERT_CRT" \
            -subj "/C=RU/ST=None/L=None/O=None/CN=$(get_public_ip)"
    fi
}

# Создание конфига Xray для VLESS+WebSocket+TLS
create_config() {
    NEW_UUID="$1"
    # Если файла нет, создаём новый базовый конфиг с этим UUID
    if [ ! -f "$XRAY_CONFIG" ]; then
        cat > "$XRAY_CONFIG" <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [{
    "port": $PORT,
    "protocol": "vless",
    "settings": {
      "clients": [
        {
          "id": "$NEW_UUID",
          "level": 0,
          "email": "user@xray"
        }
      ],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "ws",
      "security": "tls",
      "tlsSettings": {
        "certificates": [
          {
            "certificateFile": "$CERT_CRT",
            "keyFile": "$CERT_KEY"
          }
        ]
      },
      "wsSettings": {
        "path": "$WS_PATH"
      }
    }
  }],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF
    else
        # Если файл есть, добавляем новый UUID только если его ещё нет
        TMP_CONFIG=$(mktemp)
        jq --arg uuid "$NEW_UUID" '
        .inbounds[0].settings.clients +=
        (if [.inbounds[0].settings.clients[].id | select(. == $uuid)] | length == 0
         then [{"id": $uuid, "level": 0, "email": ($uuid + "@xray")}]
         else []
         end)
        ' "$XRAY_CONFIG" > "$TMP_CONFIG" && mv "$TMP_CONFIG" "$XRAY_CONFIG"
    fi
}

# Создание systemd-сервиса для автозапуска Xray при загрузке сервера
setup_service() {
    if [ ! -f "$XRAY_SERVICE" ]; then
        cat > "$XRAY_SERVICE" <<EOF
[Unit]
Description=Xray Service
After=network.target nss-lookup.target

[Service]
User=root
ExecStart=$XRAY_PATH run -c $XRAY_CONFIG
Restart=on-failure
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
        systemctl enable xray
    fi
}

# Перезапуск службы Xray
restart_xray() {
    systemctl daemon-reload
    if systemctl restart xray; then
        echo "Xray успешно перезапущен."
    else
        echo "Ошибка: не удалось перезапустить Xray!"
        systemctl status xray --no-pager
        exit 1
    fi
}

# Генерация VLESS ссылки для клиента — с allowInsecure=1
generate_vless_link() {
    SERVER_IP=$(get_public_ip)
    echo "vless://$UUID@$SERVER_IP:$PORT?encryption=none&security=tls&type=ws&host=$SERVER_IP&path=%2Fws&allowInsecure=1#VLESS-WS-TLS"
}

# QR-код
generate_qr() {
    VLESS_LINK=$(generate_vless_link)
    if command -v qrencode > /dev/null; then
        echo "$VLESS_LINK" | qrencode -t ANSIUTF8
    fi
    echo "VLESS ссылка:"
    echo "$VLESS_LINK"
    echo "ВНИМАНИЕ: TLS сертификат самоподписанный! В клиенте нужно отключить проверку сертификата (allowInsecure = 1)"
}

# --- MTU AUTO-CONFIGURATION BLOCK ---
set_mtu_1400() {
    # Проверка альтернативных систем конфигурации сети
    if [ -d /etc/netplan ] && ls /etc/netplan/*.yaml >/dev/null 2>&1; then
        echo "[!] Netplan обнаружен в системе (/etc/netplan) — автоматическая настройка MTU не выполнена."
        echo "    Измените MTU вручную в yaml-файле Netplan."
        return
    fi
    if [ -d /etc/systemd/network ] && ls /etc/systemd/network/*.network >/dev/null 2>&1; then
        echo "[!] systemd-networkd обнаружен (/etc/systemd/network) — автоматическая настройка MTU не выполнена."
        echo "    Измените MTU вручную в соответствующем .network-файле."
        return
    fi
    if pgrep -x NetworkManager >/dev/null 2>&1; then
        echo "[!] NetworkManager активен — автоматическая настройка MTU не выполнена."
        echo "    Используйте nmcli или nmtui для изменения MTU."
        return
    fi
    if ls /etc/cloud/cloud.cfg* >/dev/null 2>&1; then
        echo "[!] Обнаружен cloud-init. Cloud-init может перезаписать сетевые настройки после перезагрузки!"
        echo "    Рекомендуется изменить MTU через cloud-init или отключить его управление сетью."
    fi
    # Проверка на явную запись в /etc/network/interfaces
    if grep -E "iface .+ inet" /etc/network/interfaces | grep -v "source" >/dev/null 2>&1; then
        echo "[!] В /etc/network/interfaces есть ручная настройка интерфейса!"
        echo "    Проверьте этот файл вручную, автоматическая настройка MTU не выполнена."
        return
    fi

    # Определение основного интерфейса
    IFACE=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="dev") print $(i+1); exit}')
    if [ -z "$IFACE" ]; then
        echo "[!] Не удалось определить основной сетевой интерфейс для MTU."
        return
    fi

    echo "[+] Обнаружен основной интерфейс: $IFACE"
    # Применить MTU немедленно
    ip link set dev $IFACE mtu 1400 || echo "[!] Не удалось установить MTU 1400 через ip link set."

    # Записать в /etc/network/interfaces.d/ только если ещё не прописан mtu 1400
    IF_CFG="/etc/network/interfaces.d/$IFACE"
    if grep -q "mtu 1400" "$IF_CFG" 2>/dev/null; then
        echo "[=] MTU 1400 уже прописан в $IF_CFG, ничего менять не нужно."
    else
        if [ -w /etc/network/interfaces.d ]; then
            cat <<EOF > "$IF_CFG"
auto $IFACE
iface $IFACE inet dhcp
    mtu 1400
EOF
            echo "[+] MTU 1400 прописан в $IF_CFG"
        else
            echo "[!] Нет прав на запись в /etc/network/interfaces.d, пропишите вручную:"
            echo "auto $IFACE"
            echo "iface $IFACE inet dhcp"
            echo "    mtu 1400"
        fi
    fi

    ip link show $IFACE | grep mtu
}
# --- END MTU AUTO-CONFIGURATION BLOCK ---

main() {
    install_dependencies
    install_xray
    generate_selfsigned_cert
    setup_service
    set_mtu_1400
    create_config "$UUID"
    mkdir -p /var/log/xray
    restart_xray
    generate_qr
}

main
