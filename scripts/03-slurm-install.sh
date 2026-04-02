#!/bin/bash

set -e  # Exit on error

echo "========== SLURM Installation & Configuration =========="

# =========================================================
# 1. Install Prerequisites (ALL NODES)
# =========================================================
echo "[INFO] Installing prerequisites..."

sudo apt update -y
sudo apt install -y \
openssh-server \
build-essential \
munge \
libmunge-dev \
libmunge2 \
libmysqlclient-dev \
libssl-dev \
libpam0g-dev \
libnuma-dev \
perl \
wget

# Disable firewall (ONLY for internal lab/testing)
echo "[INFO] Disabling firewall (for lab use only)..."
sudo iptables -F || true
sudo systemctl stop ufw || true

# =========================================================
# 2. Download & Build SLURM
# =========================================================
echo "[INFO] Downloading SLURM..."

sudo mkdir -p /slurm-dir
cd /slurm-dir

sudo wget -q https://download.schedmd.com/slurm/slurm-20.11.9.tar.bz2
sudo tar -xjf slurm-20.11.9.tar.bz2

cd slurm-20.11.9

echo "[INFO] Building SLURM from source..."
sudo ./configure --prefix=/slurm-dir/slurm-20.11.9
sudo make -j$(nproc)
sudo make install

# =========================================================
# 3. MUNGE AUTHENTICATION (CONTROLLER NODE)
# =========================================================
echo "[INFO] Configuring MUNGE (Controller)..."

sudo chown munge: /etc/munge/munge.key
sudo chmod 400 /etc/munge/munge.key

echo "[INFO] Copy munge.key to compute node manually:"
echo "scp /etc/munge/munge.key user@compute-node:/tmp"

sudo chown -R munge: /etc/munge /var/log/munge
sudo chmod 0700 /etc/munge /var/log/munge

sudo systemctl enable munge
sudo systemctl start munge

# =========================================================
# 4. SLURM CONFIGURATION (CONTROLLER)
# =========================================================
echo "[INFO] Configuring SLURM (Controller)..."

cd /slurm-dir/slurm-20.11.9/etc

cp slurm.conf.example slurm.conf

echo "⚠️ Edit slurm.conf manually:"
echo "Define controller, compute nodes, partitions"

# Create required directories
sudo mkdir -p /var/spool/slurm/ctld

# Link systemd services
sudo ln -sf /slurm-dir/slurm-20.11.9/etc/slurmctld.service /etc/systemd/system/
sudo ln -sf /slurm-dir/slurm-20.11.9/etc/slurmd.service /etc/systemd/system/

# Start controller daemon
sudo systemctl daemon-reexec
sudo systemctl enable slurmctld
sudo systemctl start slurmctld

sudo systemctl status slurmctld --no-pager

# =========================================================
# 5. ENVIRONMENT VARIABLES
# =========================================================
echo "[INFO] Setting environment variables..."

echo 'export PATH=/slurm-dir/slurm-20.11.9/bin:$PATH' >> ~/.bashrc
echo 'export PATH=/slurm-dir/slurm-20.11.9/sbin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/slurm-dir/slurm-20.11.9/lib:$LD_LIBRARY_PATH' >> ~/.bashrc

source ~/.bashrc

# =========================================================
# 6. OPTIONAL: SLURM DATABASE (Controller)
# =========================================================
echo "[INFO] Setting up SLURM database (optional)..."

sudo apt install -y mariadb-server

cp slurmdbd.conf.example slurmdbd.conf

sudo chmod 600 /slurm-dir/slurm-20.11.9/etc/slurmdbd.conf

sudo ln -sf /slurm-dir/slurm-20.11.9/etc/slurmdbd.service /etc/systemd/system/

echo "⚠️ Edit slurmdbd.conf before starting service"

sudo systemctl enable slurmdbd
sudo systemctl start slurmdbd

sudo systemctl status slurmdbd --no-pager

# =========================================================
# 7. COMPUTE NODE INSTRUCTIONS
# =========================================================
echo "[INFO] Compute node setup steps:"

echo "1. Copy munge.key:"
echo "   sudo cp /tmp/munge.key /etc/munge/"

echo "2. Start munge:"
echo "   sudo systemctl enable munge && sudo systemctl start munge"

echo "3. Copy slurm.conf:"
echo "   scp controller:/slurm-dir/slurm-20.11.9/etc/slurm.conf /tmp"

echo "4. Move config:"
echo "   sudo cp /tmp/slurm.conf /slurm-dir/slurm-20.11.9/etc/"

echo "5. Create spool dir:"
echo "   sudo mkdir -p /var/spool/slurm/d"

echo "6. Start slurmd:"
echo "   sudo systemctl enable slurmd && sudo systemctl start slurmd"

# =========================================================
# 8. VERIFY CLUSTER
# =========================================================
echo "[INFO] Checking cluster status..."

sinfo || echo "SLURM not fully configured yet"

echo "========== SLURM Setup Completed =========="
