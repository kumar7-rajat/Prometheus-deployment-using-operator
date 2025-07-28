#!/bin/bash

# Set version
NODE_EXPORTER_VERSION="1.8.0"

# Download
curl -Lo /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Extract
tar xvf /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Move binary to /usr/local/bin
sudo mv /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/node_exporter
sudo chmod 555 /usr/local/bin/node_exporter

sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nobody
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter


sudo systemctl status node_exporter


