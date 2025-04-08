#!/bin/bash

# Exit immediately if a command fails (-e),
# if an undefined variable is used (-u),
# or if any command in a pipeline fails (-o pipefail).
set -euo pipefail

# Check for Debian-based system
if ! grep -qi "debian" /etc/os-release; then
  echo
  echo "This script is intended for Debian-based systems only."
  echo "Detected system:"
  grep '^NAME=' /etc/os-release
  echo
  exit 1
fi

# Require root privileges
if [[ "$EUID" -ne 0 ]]; then
  echo
  echo "Since this script installs and manages a systemd service, it must be run with root (sudo) privileges."
  echo
  exit 1
fi

# Intro banner
echo
echo "=============================================="
echo "  Installing OpenTelemetry Collector Contrib  "
echo "=============================================="
echo

# Check if any OpenTelemetry Collector process is already running
if pgrep -af 'otelcol' | grep -v "$0" > /dev/null; then
  echo "An OpenTelemetry Collector process is already running, this is likely unintentional."
  echo "Make sure there won't be any conflicts after installing otelcol-contrib package."
  echo
  echo "Matching processes:"
  pgrep -af 'otelcol' | grep -v "$0"
  echo
  read -p "Do you want to continue anyway? [y/N]: " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo
    echo "Aborting installation."
    echo
    exit 1
  fi

  echo
  echo "Continuing despite running instance..."
fi

# Detect architecture
ARCH=$(dpkg --print-architecture)

# Map Debian arch to release arch
case "$ARCH" in
  amd64|x86_64)
    ARCH=amd64
    ;;
  arm64|aarch64)
    ARCH=arm64
    ;;
  *)
    echo
    echo "Unsupported architecture: $ARCH"
    echo "Only amd64 and arm64 are supported."
    echo
    exit 1
    ;;
esac

# Get the latest version (without the "v" prefix)
OTELCOL_CONTRIB_VERSION=$(curl -s https://api.github.com/repos/open-telemetry/opentelemetry-collector-releases/releases/latest | jq -r '.tag_name' | sed 's/^v//')

# Download to temporary directory
DEB_FILE="otelcol-contrib_${OTELCOL_CONTRIB_VERSION}_linux_${ARCH}.deb"
TMP_PATH="/tmp/${DEB_FILE}"
curl -Lo "${TMP_PATH}" "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTELCOL_CONTRIB_VERSION}/${DEB_FILE}"

# Install the package
dpkg -i "${TMP_PATH}"

# Clean up
rm -f "${TMP_PATH}"

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable otelcol-contrib
systemctl restart otelcol-contrib

# Show service status
systemctl status otelcol-contrib --no-pager

# Uninstall instructions
echo
echo "To uninstall OpenTelemetry Collector Contrib, run:"
echo "  systemctl disable --now otelcol-contrib"
echo "  apt remove otelcol-contrib"

# Systemd control tips
echo
echo "Useful systemctl commands:"
echo "  systemctl status otelcol-contrib   # Show current status"
echo "  systemctl restart otelcol-contrib  # Restart the service"
echo "  systemctl stop otelcol-contrib     # Stop the service"
echo "  systemctl start otelcol-contrib    # Start the service"
echo "  journalctl -u otelcol-contrib -f   # Follow logs"
