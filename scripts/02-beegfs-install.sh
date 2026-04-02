#!/bin/bash

set -e  # Exit on any error

echo "========== BeeGFS Installation & Configuration =========="

# -------------------------------
# 1. Install Prerequisites
# -------------------------------
echo "[INFO] Installing prerequisites..."
sudo apt update -y
sudo apt install -y curl apt-transport-https wget

# -------------------------------
# 2. Add BeeGFS Repository
# -------------------------------
echo "[INFO] Adding BeeGFS repository and GPG key..."

wget -q https://www.beegfs.io/release/beegfs_8.2/gpg/GPG-KEY-beegfs \
-O /etc/apt/trusted.gpg.d/beegfs.asc

wget -q https://www.beegfs.io/release/beegfs_8.2/dists/beegfs-jammy.list \
-O /etc/apt/sources.list.d/beegfs.list

sudo apt update -y

# -------------------------------
# 3. Install BeeGFS Packages
# -------------------------------
echo "[INFO] Installing BeeGFS services..."

sudo apt install -y \
beegfs-mgmtd \
beegfs-meta \
beegfs-storage \
beegfs-client \
beegfs-utils

# -------------------------------
# 4. Configure Authentication
# -------------------------------
echo "[INFO] Configuring authentication..."

sudo dd if=/dev/random of=/etc/beegfs/conn.auth bs=128 count=1
sudo chown root:root /etc/beegfs/conn.auth
sudo chmod 400 /etc/beegfs/conn.auth

# -------------------------------
# 5. Prepare Storage Disk
# -------------------------------
echo "[INFO] Preparing storage..."

# ⚠️ WARNING: This will format disk
sudo mkfs.ext4 /dev/sdb

sudo mkdir -p /data/beegfs
sudo mount /dev/sdb /data/beegfs

sudo mkdir -p \
/data/beegfs/mgmtd \
/data/beegfs/meta \
/data/beegfs/storage

# -------------------------------
# 6. Setup Management Service
# -------------------------------
echo "[INFO] Setting up management service..."

sudo /opt/beegfs/sbin/beegfs-setup-mgmtd \
-p /data/beegfs/mgmtd \
-m 10.0.2.20

sudo systemctl enable beegfs-mgmtd
sudo systemctl start beegfs-mgmtd

# -------------------------------
# 7. Setup Storage Service
# -------------------------------
echo "[INFO] Setting up storage service..."

sudo /opt/beegfs/sbin/beegfs-setup-storage \
-p /data/beegfs/storage \
-m 10.0.2.20

sudo systemctl enable beegfs-storage
sudo systemctl start beegfs-storage

# -------------------------------
# 8. Setup Metadata Service
# -------------------------------
echo "[INFO] Setting up metadata service..."

sudo /opt/beegfs/sbin/beegfs-setup-meta \
-p /data/beegfs/meta \
-m 10.0.2.20

sudo systemctl enable beegfs-meta
sudo systemctl start beegfs-meta

# -------------------------------
# 9. Setup Client
# -------------------------------
echo "[INFO] Setting up client..."

sudo /opt/beegfs/sbin/beegfs-setup-client \
-m 10.0.2.20

echo "[INFO] Configure mount file manually:"
echo "Edit: /etc/beegfs/beegfs-mounts.conf"

sudo systemctl enable beegfs-client
sudo systemctl start beegfs-client

# -------------------------------
# 10. Verification
# -------------------------------
echo "[INFO] Verifying BeeGFS services..."

sudo systemctl status beegfs-mgmtd --no-pager
sudo systemctl status beegfs-meta --no-pager
sudo systemctl status beegfs-storage --no-pager
sudo systemctl status beegfs-client --no-pager

echo "========== BeeGFS Setup Completed =========="
