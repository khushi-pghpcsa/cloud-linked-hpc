#!/bin/bash

set -e  # Exit on error

echo "========== HPC HA Cluster Setup: PCS + Corosync + Pacemaker =========="

# -------------------------------
# System Preparation
# -------------------------------
echo "[INFO] Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

echo "[INFO] Installing required packages..."
sudo apt install -y pacemaker corosync pcs

# -------------------------------
# Version Verification
# -------------------------------
echo "[INFO] Verifying installations..."
pcs --version
corosync -v
pacemakerd --version

echo "[INFO] Checking services..."
systemctl list-unit-files | grep -E "corosync|pacemaker|pcsd"

# -------------------------------
# Configure hacluster User
# -------------------------------
echo "[INFO] Setting password for hacluster user..."
echo "⚠️ Set same password on all nodes manually"
sudo passwd hacluster

# -------------------------------
# Enable PCS Daemon
# -------------------------------
echo "[INFO] Starting PCS daemon..."
sudo systemctl enable pcsd
sudo systemctl start pcsd

# -------------------------------
# Cluster Authentication
# -------------------------------
echo "[INFO] Authenticating nodes..."
sudo pcs host auth controller-1 controller-2 -u hacluster -p YOUR_PASSWORD

# -------------------------------
# Cluster Setup
# -------------------------------
echo "[INFO] Setting up cluster..."
sudo pcs cluster setup cloudcluster controller-1 controller-2 --force

# -------------------------------
# Corosync Config Check
# -------------------------------
echo "[INFO] Corosync configuration:"
sudo cat /etc/corosync/corosync.conf

# -------------------------------
# Quorum Policy
# -------------------------------
echo "[INFO] Setting quorum policy..."
sudo pcs property set no-quorum-policy=ignore

# -------------------------------
# Start & Enable Cluster
# -------------------------------
echo "[INFO] Starting cluster..."
sudo pcs cluster start --all

echo "[INFO] Enabling cluster on boot..."
sudo pcs cluster enable --all

echo "[INFO] Cluster Status:"
sudo pcs cluster status
sudo pcs status

# -------------------------------
# Create Virtual IP (AWS)
# -------------------------------
echo "[INFO] Creating Virtual IP resource..."

sudo pcs resource create cluster_vip ocf:heartbeat:aws-vpc-move-ip \
ip=192.168.2.50 \
interface=eth0 \
region=us-east-1 \
awscli=/usr/bin/aws \
op monitor interval=30s --force

echo "========== Cluster Setup Completed =========="
