# 🛡️ Telegram MTProto Proxy Docker<br>Anti-Censorship & Pro Privacy

[![Docker Pulls](https://img.shields.io/docker/pulls/arm64builds/mtproxy)](https://hub.docker.com/r/arm64builds/mtproxy)
[![Image Size](https://img.shields.io/docker/image-size/arm64builds/mtproxy)](https://hub.docker.com/r/arm64builds/mtproxy)

**Unblock Telegram** instantly with this ultra-lightweight, multi-architecture MTProto Proxy. Designed for **privacy**, **security**, and bypassing **censorship (DPI)** with FakeTLS.

🚀 **Fix Telegram Lag & Throttling**: Perfect for regions where Telegram is slowed down. experience **instant message sending** and **fast video downloads** without buffering.

Ideal for **Raspberry Pi**, low-end VPS, and any server with limited resources.

### 🏆 Why use this over the official image?
The official `telegrammessenger/proxy` Docker image hasn't been updated since **2018**. It is outdated, heavy, and lacks support for modern ARM secure protocols.

**This image is superior because:**
- **🚀 Modern & Maintained**: Built on the latest, actively maintained Go library.
- **🛡️ Secure**: Supports modern FakeTLS and anti-replay protections that didn't exist in 2018.
- **📉 95% Smaller**: The official image is ~200MB+. This image is **~10MB**.
- **🌐 Universal**: Runs natively on ARM64 (Raspberry Pi/Ampere), AMD64, and more.

## 📋 Table of Contents
- [✨ Key Features](#-key-features)
- [🚀 Quick Start](#-quick-start)
- [🐳 Docker Compose](#-docker-compose)
- [⚙️ Configuration](#-configuration)
- [💾 Persistence](#-persistence)
- [🔧 Troubleshooting](#-troubleshooting)
- [🤝 Credits](#-credits)

## ✨ Key Features

- **🌐 Multi-Architecture Support**: Runs on everything!
    - **Platforms**: `linux/amd64`, `linux/arm64`, `linux/arm/v7`, `linux/riscv64`, `linux/s390x`, `linux/ppc64le`, `linux/386`.
    - Perfect for cheap ARM servers, Raspberry Pis, and old hardware. Perfect for **any platform**: ARM, RISC-V, Intel/AMD, PowerPC, and more.
- **⚡ High Speed & Anti-Throttling**: Overcome ISP throttling. Watch videos and download files at full speed, even if your encrypted traffic is usually slowed down.
- **⚡ Ultra Lightweight**: Based on **Alpine Linux**. The compressed image is **only ~10-15MB**!
- **🔒 FakeTLS**: Disguises your traffic as standard HTTPS (default: `cdnjs.cloudflare.com`) to bypass Deep Packet Inspection (DPI) and firewalls in restrictive regions.
- **🛡️ Anti-Replay**: Prevents active probing attacks. The proxy cannot be detected or blocked by replaying captured packets.
- **👁️ Privacy First**: This project is built with good intentions. It **completely ignores** user data. It effectively acts as a blind tunnel—it does not (and cannot) eavesdrop, store, or inspect your private Telegram messages.
- **🔑 Secure**: Automatically generates strong, random secrets if none are provided.

---

## 🚀 Quick Start

Get your proxy running in seconds. A secret will be auto-generated for you.

```bash
docker run -d \
  --name mtproxy \
  --restart always \
  -p 8443:8888 \
  arm64builds/mtproxy:latest
```

**View your connection links:**
```bash
docker logs mtproxy
```

---

## 🐳 Docker Compose

For the best experience, use Docker Compose. This method ensures your configuration is clean and reproducible.

### 1. 📥 Download & Setup
Create a directory to keep things organized:

```bash
mkdir -p ~/mtproxy && cd ~/mtproxy
```

Download the officially recommended compose file and set your desired port (e.g., `443` for maximum stealth):

```bash
curl -O https://raw.githubusercontent.com/cleanerspam/MTProxy/main/docker-compose.yml
echo "HOST_PORT=443" > .env
```

### 2. ▶️ Start the Proxy

```bash
docker compose up -d
```

### 3. 📝 View Connection Links & Secret

Once started, the container will print your connection links (tg:// and https://) and the generated secret to the logs.

```bash
docker compose logs -f mtproxy
```

*Press `Ctrl+C` to exit logs.*

---

## ⚙️ Configuration

You can customize the proxy using environment variables in your `.env` file or `docker run` command.

| Variable | Description | Default |
|----------|-------------|---------|
| `SECRET` | A 32-character hex secret. If not provided, one is generated automatically. | *(Randomly Generated)* |
| `DOMAIN` | The FakeTLS domain to disguise traffic as. | `cdnjs.cloudflare.com` |
| `HOST_PORT`| The public port on your server. Important for generating correct links. | `8443` |
| `PUBLIC_IP`| Your server's public IP address. | *(Auto-detected via ifconfig.me)* |

---

## 💾 Persistence

The container is stateless by default, but it can persist your generated secret so it doesn't change on restarts.

To enable this, simply mount a file to `/data/.env`. The container will save the generated secret there.

```bash
touch .env
docker run -d \
  -p 8443:8888 \
  -v $(pwd)/.env:/data/.env \
  arm64builds/mtproxy:latest
```

---

## 🔧 Troubleshooting

### 🔍 Check Logs
If you can't connect, check the logs first. It will show you the generated secret and connection links (tg:// and https://).
```bash
docker logs mtproxy
```

### 🚪 Firewall & Security Groups
The most common issue is a blocked port. Ensure traffic is allowed on your chosen port (e.g., `443` or `8443`).

**VPS Firewalls:**
- **Ubuntu/Debian (ufw):** `sudo ufw allow 443/tcp`
- **CentOS/RHEL (iptables):** `sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT`

**Cloud Provider Security Groups:**
If you use **AWS**, **Google Cloud**, **Oracle Cloud**, or **Alibaba Cloud**, you **MUST** go to your cloud console and add an "Ingress Rule" (Inbound Rule) to allow TCP traffic on your port (0.0.0.0/0).

---

## 🤝 Credits

This project stands on the shoulders of giants:

- **Core Library**: Built using the high-performance [9seconds/mtg](https://github.com/9seconds/mtg) Go library.
- **Protocol**: MTProto Proxy protocol designed by [Telegram](https://telegram.org).

---

> "Arguing that you don't care about the right to privacy because you have nothing to hide is no different than saying you don't care about free speech because you have nothing to say."
> — *Edward Snowden*
