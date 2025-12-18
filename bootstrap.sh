#!/usr/bin/env bash
set -e

# Store the directory where this script is located
BOOTSTRAP_DIR="$(cd "$(dirname "$0")" && pwd)"

# install deps
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2 git ufw
sudo systemctl enable --now docker

# clone repo
sudo mkdir -p /opt
sudo chown "$USER":"$USER" /opt
cd /opt
git clone https://github.com/metabrainz/musicbrainz-docker.git
cd musicbrainz-docker

# build + initial DB
docker compose build
docker compose run --rm musicbrainz createdb.sh -fetch

# install cron + systemd
sudo cp "$BOOTSTRAP_DIR/cron/musicbrainz-indexes" /etc/cron.d/
sudo cp "$BOOTSTRAP_DIR/systemd/musicbrainz.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable musicbrainz.service

# start
docker compose up -d
