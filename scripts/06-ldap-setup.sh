#!/bin/bash

set -e  # Exit on error

echo "========== LDAP Server Setup (OpenLDAP) =========="

# =========================================================
# 1. INSTALL LDAP PACKAGES
# =========================================================
echo "[INFO] Installing OpenLDAP..."

sudo apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt install -y slapd ldap-utils

# =========================================================
# 2. START & ENABLE SERVICE
# =========================================================
echo "[INFO] Starting LDAP service..."

sudo systemctl enable slapd
sudo systemctl start slapd

sudo systemctl status slapd --no-pager

# =========================================================
# 3. VERIFY LDAP
# =========================================================
echo "[INFO] Verifying LDAP..."

ldapsearch -x -LLL -H ldap://localhost -b dc=hpc,dc=local || echo "[WARNING] LDAP not fully configured"

# =========================================================
# 4. CREATE BASE STRUCTURE
# =========================================================
echo "[INFO] Creating base LDAP structure..."

cat <<EOF > base.ldif
dn: dc=hpc,dc=local
objectClass: top
objectClass: dcObject
objectClass: organization
o: HPC Cluster
dc: hpc

dn: ou=users,dc=hpc,dc=local
objectClass: organizationalUnit
ou: users

dn: ou=groups,dc=hpc,dc=local
objectClass: organizationalUnit
ou: groups
EOF

echo "[INFO] Adding base structure (enter admin password when prompted)..."

ldapadd -x -D "cn=admin,dc=hpc,dc=local" -W -f base.ldif

# =========================================================
# 5. ADD SAMPLE USER
# =========================================================
echo "[INFO] Adding sample user..."

cat <<EOF > user.ldif
dn: uid=user1,ou=users,dc=hpc,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: user1
sn: user1
uid: user1
uidNumber: 10001
gidNumber: 10001
homeDirectory: /home/user1
loginShell: /bin/bash
userPassword: password
EOF

ldapadd -x -D "cn=admin,dc=hpc,dc=local" -W -f user.ldif

# =========================================================
# 6. NETWORK (LDAP PORT)
# =========================================================
echo "[INFO] Opening LDAP port..."

sudo ufw allow 389 || true

# =========================================================
# COMPLETION
# =========================================================
echo "========== LDAP Setup Completed =========="
echo "[INFO] Base DN: dc=hpc,dc=local"
echo "[INFO] Admin DN: cn=admin,dc=hpc,dc=local"
