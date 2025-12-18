#!/usr/bin/env bash
set -e

# store the directory where this script is located
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

# run initial index
sudo touch /var/log/musicbrainz-index.log
sudo chown "$USER":"$USER" /var/log/musicbrainz-index.log
cd /opt/musicbrainz-docker && \
  sudo docker compose exec -T indexer \
  python -m sir reindex --entity-type release >> /var/log/musicbrainz-index.log 2>&1
