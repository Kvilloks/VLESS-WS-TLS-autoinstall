# Xray VLESS WS+TLS Автоустановка (Multi-Client)

Автоматический Bash-скрипт для установки, настройки и управления сервером Xray с поддержкой VLESS + WebSocket + TLS и мультиклиентом на Linux.

## Особенности

- Автоматическая установка Xray-core и всех зависимостей
- Генерация самоподписанного TLS-сертификата
- Мгновенное добавление новых клиентов (UUID) без удаления старых
- Генерация VLESS-ссылок и QR-кодов для подключения
- Одновременная работа любого количества клиентов (multi-user)
- Автоматическая настройка systemd-сервиса для автозапуска

## Быстрый старт

1. Скопируйте и выполните эти команды на сервере Linux:
    ```bash
    curl -fsSL https://raw.githubusercontent.com/Kvilloks/xray-vless-WebSocket-TLS-autoinstall/main/install-xray-ws-tls.sh -o /tmp/install-xray-ws-tls.sh
    dos2unix /tmp/install-xray-ws-tls.sh 2>/dev/null || sed -i 's/\r$//' /tmp/install-xray-ws-tls.sh
    chmod +x /tmp/install-xray-ws-tls.sh
    bash /tmp/install-xray-ws-tls.sh
    ```

2. После каждого запуска скрипта будет сгенерирован новый VLESS UUID и ссылка для подключения, все ранее добавленные клиенты останутся рабочими.


## VLESS Ссылка

В конце работы скрипта вы получите готовую ссылку для клиента формата:

```
vless://UUID@SERVER_IP:443?encryption=none&security=tls&type=ws&host=SERVER_IP&path=%2Fws&allowInsecure=1#VLESS-WS-TLS
```

## Примечания

- Для удаления клиента удалите его UUID вручную из `/etc/xray/config.json` и перезапустите службу Xray.
- Для использования собственного сертификата замените файлы в `/etc/xray/cert/`.
- Поддерживаются Ubuntu, Debian и другие Linux-системы.
