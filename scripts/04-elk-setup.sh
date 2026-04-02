#!/bin/bash

set -e  # Exit on error

echo "========== ELK Stack Setup (Elasticsearch + Logstash + Kibana + Filebeat) =========="

# =========================================================
# 1. SYSTEM PREPARATION
# =========================================================
echo "[INFO] Updating system..."

sudo apt update -y && sudo apt upgrade -y

echo "[INFO] Ensure hostname mapping manually in /etc/hosts"
echo "Example: monitor1 -> <your-ip>"

# =========================================================
# 2. INSTALL JAVA (REQUIRED)
# =========================================================
echo "[INFO] Installing OpenJDK 17..."

sudo apt install -y openjdk-17-jdk

java -version

# =========================================================
# 3. ADD ELASTIC REPOSITORY
# =========================================================
echo "[INFO] Adding Elastic GPG key and repository..."

curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch \
| sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg

echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" \
| sudo tee /etc/apt/sources.list.d/elastic-8.x.list

sudo apt update -y

# =========================================================
# 4. ELASTICSEARCH SETUP
# =========================================================
echo "[INFO] Installing Elasticsearch..."

sudo apt install -y elasticsearch

echo "[INFO] Configure Elasticsearch manually:"
echo "Edit: /etc/elasticsearch/elasticsearch.yml"

cat <<EOF

cluster.name: elk-cluster
node.name: monitor1
network.host: 0.0.0.0
http.port: 9200
discovery.type: single-node

EOF

sudo systemctl daemon-reexec
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

echo "[INFO] Verifying Elasticsearch..."
curl -s http://localhost:9200 || echo "[WARNING] Elasticsearch not ready"

# =========================================================
# 5. LOGSTASH SETUP
# =========================================================
echo "[INFO] Installing Logstash..."

sudo apt install -y logstash

echo "[INFO] Create pipeline config:"
echo "File: /etc/logstash/conf.d/elk.conf"

cat <<EOF

input {
  beats {
    port => 5044
  }
}

filter {
  if [fileset][module] == "system" {
    grok {
      match => { "message" => "%{SYSLOGBASE} %{GREEDYDATA:msg}" }
    }
  }
}

output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
  }
}

EOF

sudo systemctl enable logstash
sudo systemctl start logstash

sudo systemctl status logstash --no-pager

# =========================================================
# 6. KIBANA SETUP
# =========================================================
echo "[INFO] Installing Kibana..."

sudo apt install -y kibana

echo "[INFO] Configure Kibana manually:"
echo "Edit: /etc/kibana/kibana.yml"

cat <<EOF

server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]

EOF

sudo systemctl enable kibana
sudo systemctl start kibana

echo "[INFO] Access Kibana dashboard:"
echo "http://<your-server-ip>:5601"

# =========================================================
# 7. FILEBEAT SETUP (RUN ON ALL NODES)
# =========================================================
echo "[INFO] Installing Filebeat..."

sudo apt install -y filebeat

echo "[INFO] Configure Filebeat output:"
echo "Edit: /etc/filebeat/filebeat.yml"

cat <<EOF

output.logstash:
  hosts: ["monitor1:5044"]

EOF

sudo filebeat modules enable system

sudo systemctl enable filebeat
sudo systemctl start filebeat

sudo systemctl status filebeat --no-pager

# =========================================================
# COMPLETION
# =========================================================
echo "========== ELK Stack Setup Completed =========="
