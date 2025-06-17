# VLESS-WS-TLS-autoinstall

<details>
<summary>🌍 Switch language / Переключить язык</summary>

- [English](#english)
- [Русский](#русский)

</details>

---

## English

This repository provides an automated installation script for the VLESS protocol using WebSocket (WS) and TLS encryption.

### Features

- Fully automated, interactive installation
- Compatible with most Linux distributions (Debian, Ubuntu, CentOS, etc.)
- Installs and configures Xray-core with VLESS over WS+TLS
- Automatically sets up firewall rules and required dependencies
- Generates client configuration for instant use

### Quick Installation

Run this command as root (or with sudo):

```bash
curl -fsSL https://raw.githubusercontent.com/Kvilloks/xray-vless-WebSocket-TLS-autoinstall/main/install-xray-ws-tls.sh -o /tmp/install-xray-ws-tls.sh && dos2unix /tmp/install-xray-ws-tls.sh 2>/dev/null || sed -i 's/\r$//' /tmp/install-xray-ws-tls.sh && chmod +x /tmp/install-xray-ws-tls.sh && bash /tmp/install-xray-ws-tls.sh
```

### Manual Usage

1. Clone or download the script from this repository.
2. Give execution permission:
   ```bash
   chmod +x autoinstall.sh
   ```
3. Run as root:
   ```bash
   sudo ./autoinstall.sh
   ```
4. Follow the on-screen instructions.

### Requirements

- A clean installation of Linux (recommended: Debian/Ubuntu)
- Root privileges
- Open required ports (default: 443 for TLS)

### Disclaimer

Use this script at your own risk. Make sure to comply with your local laws and regulations.

---

## Русский

Данный репозиторий содержит автоматизированный скрипт для установки протокола VLESS с использованием WebSocket (WS) и шифрования TLS.

### Возможности

- Полностью автоматизированная установка с интерактивным процессом
- Совместимость с большинством дистрибутивов Linux (Debian, Ubuntu, CentOS и др.)
- Установка и настройка Xray-core с VLESS через WS+TLS
- Автоматическая настройка firewall и всех необходимых зависимостей
- Генерация клиентской конфигурации для мгновенного использования

### Быстрая установка

Запустите эту команду от root (или через sudo):

```bash
curl -fsSL https://raw.githubusercontent.com/Kvilloks/xray-vless-WebSocket-TLS-autoinstall/main/install-xray-ws-tls.sh -o /tmp/install-xray-ws-tls.sh && dos2unix /tmp/install-xray-ws-tls.sh 2>/dev/null || sed -i 's/\r$//' /tmp/install-xray-ws-tls.sh && chmod +x /tmp/install-xray-ws-tls.sh && bash /tmp/install-xray-ws-tls.sh
```

### Ручное использование

1. Клонируйте или скачайте скрипт из этого репозитория.
2. Дайте права на выполнение:
   ```bash
   chmod +x autoinstall.sh
   ```
3. Запустите от имени root:
   ```bash
   sudo ./autoinstall.sh
   ```
4. Следуйте инструкциям на экране.

### Требования

- Чистая установка Linux (рекомендуется: Debian/Ubuntu)
- Root-права
- Открытые необходимые порты (по умолчанию: 443 для TLS)


