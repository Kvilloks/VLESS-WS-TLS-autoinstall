### Автоустановка

```bash
curl -fsSL https://raw.githubusercontent.com/Kvilloks/xray-vless-WebSocket-TLS-autoinstall/main/install-xray-ws-tls.sh -o /tmp/install-xray-ws-tls.sh
dos2unix /tmp/install-xray-ws-tls.sh 2>/dev/null || sed -i 's/\r$//' /tmp/install-xray-ws-tls.sh
chmod +x /tmp/install-xray-ws-tls.sh
sudo bash /tmp/install-xray-ws-tls.sh
```

### Пример VLESS-ссылки

```
vless://<UUID>@<IP>:443?encryption=none&security=tls&type=ws&host=<IP>&path=%2Fws&allowInsecure=1#VLESS-WS-TLS
```
