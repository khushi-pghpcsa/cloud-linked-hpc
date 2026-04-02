#!/bin/bash

set -e  # Exit on error

echo "========== Zabbix 6.0 LTS Installation =========="

# =========================================================
# 1. ADD ZABBIX REPOSITORY
# =========================================================
echo "[INFO] Installing Zabbix repository..."

wget -q https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb

sudo dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb
sudo apt update -y

# =========================================================
# 2. INSTALL ZABBIX PACKAGES
# =========================================================
echo "[INFO] Installing Zabbix server, frontend, and agent..."

sudo apt install -y \
zabbix-server-mysql \
zabbix-frontend-php \
zabbix-apache-conf \
zabbix-sql-scripts \
zabbix-agent

# =========================================================
# 3. INSTALL & START DATABASE (MariaDB)
# =========================================================
echo "[INFO] Installing MariaDB..."

sudo apt install -y mariadb-server

sudo systemctl enable mariadb
sudo systemctl start mariadb

# =========================================================
# 4. DATABASE CONFIGURATION
# =========================================================
echo "[INFO] Configuring database..."

DB_NAME="zabbix"
DB_USER="zabbix"
DB_PASS="StrongPassword123"   # 🔴 Change this

sudo mysql -uroot <<EOF
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
FLUSH PRIVILEGES;
EOF

# =========================================================
# 5. IMPORT ZABBIX SCHEMA
# =========================================================
echo "[INFO] Importing database schema..."

zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz \
| mysql --default-character-set=utf8mb4 -u${DB_USER} -p${DB_PASS} ${DB_NAME}

# Disable temporary DB setting
sudo mysql -uroot -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# =========================================================
# 6. CONFIGURE ZABBIX SERVER
# =========================================================
echo "[INFO] Updating Zabbix configuration..."

sudo sed -i "s/# DBPassword=/DBPassword=${DB_PASS}/" /etc/zabbix/zabbix_server.conf

# =========================================================
# 7. START SERVICES
# =========================================================
echo "[INFO] Starting Zabbix services..."

sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2

# =========================================================
# 8. VERIFICATION
# =========================================================
echo "[INFO] Checking service status..."

sudo systemctl status zabbix-server --no-pager
sudo systemctl status apache2 --no-pager

# =========================================================
# COMPLETION
# =========================================================
echo "========== Zabbix Installation Completed =========="
echo "[INFO] Access frontend at: http://<your-monitor-ip>/zabbix"
