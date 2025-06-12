## VLESS WebSocket+TLS (без домена, самоподписанный сертификат)

### Автоустановка

```bash
wget https://github.com/Kvilloks/xray-vless-WebSocket-TLS-autoinstall/raw/main/install-xray-ws-tls.sh
chmod +x install-xray-ws-tls.sh
sudo ./install-xray-ws-tls.sh
```

### Краткая информация

- **VLESS WebSocket+TLS**
- **Без домена (по IP)**
- **Самоподписанный сертификат**
- **allowInsecure=1 автоматически в ссылке**
- **WebSocket Path:** `/ws`
- **Порт:** `443` (по умолчанию)

### Пример VLESS-ссылки

```
vless://<UUID>@<IP>:443?encryption=none&security=tls&type=ws&host=<IP>&path=%2Fws&allowInsecure=1#VLESS-WS-TLS
```
