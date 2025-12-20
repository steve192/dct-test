#!/usr/bin/env bash
set -euo pipefail

APP_NAME="dashcam-transporter"
REPO="steve192/dashcam-transporter"
ARCH="$(dpkg --print-architecture)"
BASE_URL="https://github.com/${REPO}/releases/latest/download"

case "$ARCH" in
  armhf|arm64|amd64) ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
 esac

asset="${APP_NAME}_${ARCH}.deb"
url="${BASE_URL}/${asset}"

tmp="$(mktemp -t ${APP_NAME}.XXXXXX.deb)"
apt_updated=0
cleanup() {
  rm -f "$tmp"
}
trap cleanup EXIT

if ! command -v curl >/dev/null 2>&1; then
  sudo apt-get update
  apt_updated=1
  sudo apt-get install -y curl
fi

echo "Downloading $url"
curl -fsSL "$url" -o "$tmp"

echo "Installing $asset"
if [ "$apt_updated" -eq 0 ]; then
  sudo apt-get update
fi
sudo apt-get install -y "$tmp"

echo "Edit config: sudo nano /etc/dashcam-transporter/settings.ini"
echo "Check status: sudo dashcam-transporter status"
