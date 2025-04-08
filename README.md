# OpenTelemetry Collector Contrib Installer for Debian

This script installs the latest **OpenTelemetry Collector Contrib** on Debian-based systems using the official `.deb` package.

## ✅ Features

- Automatically detects architecture (`amd64` / `arm64`)
- Ensures it's running on a Debian-based system
- Detects any `otelcol` process if already running
- Downloads the [latest otelcol-contrib release from GitHub](https://github.com/open-telemetry/opentelemetry-collector-releases/releases)
- Installs and starts the `otelcol-contrib` systemd service
- Cleans up temporary files
- Provides helpful `systemctl` and uninstall instructions

## ⚙️ Requirements

- Debian-based system
- `curl`, `jq`, `dpkg`, `systemctl`
- sudo privileges

## 🧹 Uninstallation

To remove the OpenTelemetry Collector Contrib package from your system, run:

```bash
sudo systemctl disable --now otelcol-contrib
sudo apt remove otelcol-contrib