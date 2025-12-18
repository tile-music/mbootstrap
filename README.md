# MusicBrainz Self-Hosted Server

This repository documents a reproducible setup for running a self-hosted MusicBrainz instance on an Ubuntu server using Docker and Docker Compose. It is aimed at creating an instance capable of basic object querying as well as release indexing for use with [munite](https://github.com/tile-music/munite).

---

## Overview

This setup:

* Runs MusicBrainz via the official `musicbrainz-docker` project
* Configures MusicBrainz to automatically starts on boot
* Sets up daily database replication and release index rebuilding
* Exposes minimal network surface area

---

## Requirements

* Ubuntu Server (22.04 LTS recommended)
    * Minimum 8GB RAM (16GB+ recommended for indexing)
    * Minimum 256GB disk space (SSD recommended)
* Internet access (initial DB download is large)
* Root or sudo access

---

## Quick Start (Fresh Ubuntu Install)

```bash
# clone this repo
cd ~
git clone https://github.com/tile-music/mbootstrap.git
cd mbootstrap

# run bootstrap
chmod +x bootstrap.sh
./bootstrap.sh
```

After this completes, MusicBrainz should be running via Docker.

---

## Manual Steps (Required)

These steps **cannot be fully automated**:

### 1. Replication Token

You must request a replication token from MusicBrainz:

```
https://metabrainz.org/profile
```

Then configure it inside the container:

```bash
admin/set-replication-token
admin/configure add replication-token
docker compose up -d
```

### 2. Verify Replication

```bash
docker compose exec musicbrainz replication.sh &
docker compose exec musicbrainz tail -f mirror.log
```

---

## Scheduled Jobs

### Release Index Rebuild (4:00 AM)

A cron job runs daily:

```bash
docker compose exec indexer \
  python -m sir reindex --entity-type release
```

Cron definition lives in:

```
/etc/cron.d/musicbrainz-indexes
```

### Database Replication (3:00 AM)

Configured using:

```bash
admin/configure add replication-cron
docker compose up -d
```

---

## Startup Behavior

MusicBrainz starts automatically on boot via a systemd service:

```
/etc/systemd/system/musicbrainz.service
```

Commands:

```bash
systemctl status musicbrainz
systemctl restart musicbrainz
```
