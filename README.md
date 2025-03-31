# OpenTelemetry Collector Contrib Installer for Debian

This script installs the latest **OpenTelemetry Collector Contrib** on Debian-based systems using the official `.deb` package.

## ✅ Features

- Automatically detects architecture (`amd64` / `arm64`)
- Ensures it's running on a Debian-based system
- Detects and aborts if any `otelcol` process is already running
- Downloads the latest release from GitHub
- Installs and starts the `otelcol-contrib` systemd service
- Cleans up temporary files
- Provides helpful `systemctl` and uninstall instructions

## 📦 Requirements

- Debian-based system (Debian, Ubuntu, etc.)
- `curl`, `jq`, `dpkg`, `systemctl`
- Sudo/root privileges

## 🚀 Usage

You can either **download and run the script**, or **run it directly from URL**:

### Option 1: Download and run

```bash
wget https://raw.githubusercontent.com/zdeneksvarc/install-otelcol-contrib-debian/main/install-otelcol-contrib-debian.sh
chmod +x install-otelcol-contrib-debian.sh
./install-otelcol-contrib-debian.sh
```

### Option 2: Run directly from URL

```bash
bash <(curl -sSL https://raw.githubusercontent.com/zdeneksvarc/install-otelcol-contrib-debian/main/install-otelcol-contrib-debian.sh)
```

> ⚠️ Always review scripts before executing them directly from the internet.