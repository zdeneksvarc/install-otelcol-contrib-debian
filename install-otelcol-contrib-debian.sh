#!/bin/bash

# Exit immediately if a command fails (-e),
# if an undefined variable is used (-u),
# or if any command in a pipeline fails (-o pipefail).
set -euo pipefail

# Check if any OpenTelemetry Collector process is already running
if pgrep -af 'otelcol-contrib' | grep -v "$0" > /dev/null; then
  echo "An OpenTelemetry Collector process is already running."
  echo "Please stop it before running this installation script."
  echo
  echo "Matching processes:"
  pgrep -a -f 'otelcol'
  exit 1
fi

# Check for Debian-based system
if ! grep -qi "debian" /etc/os-release; then
  echo "This script is intended for Debian-based systems only."
  echo "Detected system:"
  grep '^NAME=' /etc/os-release
  exit 1
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
    echo "Unsupported architecture: $ARCH"
    echo "Only amd64 and arm64 are supported."
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
sudo dpkg -i "${TMP_PATH}"

# Clean up
rm -f "${TMP_PATH}"

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable otelcol-contrib
sudo systemctl restart otelcol-contrib

# Show service status
sudo systemctl status otelcol-contrib --no-pager

# Uninstall instructions
echo
echo "To uninstall OpenTelemetry Collector Contrib, run:"
echo "  sudo systemctl disable --now otelcol-contrib"
echo "  sudo apt remove otelcol-contrib"

# Systemd control tips
echo
echo "Useful systemctl commands:"
echo "  sudo systemctl status otelcol-contrib   # Show current status"
echo "  sudo systemctl restart otelcol-contrib  # Restart the service"
echo "  sudo systemctl stop otelcol-contrib     # Stop the service"
echo "  sudo systemctl start otelcol-contrib    # Start the service"
echo "  sudo journalctl -u otelcol-contrib -f   # Follow logs"