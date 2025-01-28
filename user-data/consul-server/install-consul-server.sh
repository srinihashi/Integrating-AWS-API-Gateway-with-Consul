#!/bin/bash
set -e
SRC_DIR="/tmp/consul-server"
##CERTS_DIR="/tmp/consul-common/certs"
sleep 30s
echo "Installing Consul Server..." > ${SRC_DIR}/install-progress.log

# Install unzip
echo "Installing unzip ..." > ${SRC_DIR}/install-progress.log
sudo apt install unzip

CONSUL_VERSION="1.20.2" #"1.18.5"
# Install Consul Enterprise version
# Consul Enterprise version
#curl https://releases.hashicorp.com/consul/${CONSUL_VERSION}+ent/consul_${CONSUL_VERSION}+ent_linux_amd64.zip -o consul.zip

# Consul OSS version
echo "Downloading Consul ${CONSUL_VERSION} binary" >> ${SRC_DIR}/install-progress.log
curl https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -o ${SRC_DIR}/consul.zip
unzip ${SRC_DIR}/consul.zip

# Delete consul.zip file
rm ${SRC_DIR}/consul.zip

sudo groupadd consul
sudo useradd --system -g consul consul
sudo chown -R consul:consul consul

sudo mv consul /usr/local/sbin/.

sudo mkdir -p /etc/consul.d
sudo mv ${SRC_DIR}/consul.hcl /etc/consul.d/.
sudo chown -R consul:consul /etc/consul.d
sudo chmod -R 775 /etc/consul.d

## Move Consul license file
##sudo mv ${CERTS_DIR}/../license/consul.hclic /etc/consul.d/.
##sudo chown -R consul:consul /etc/consul.d
##sudo chmod -R 775 /etc/consul.d

sudo mkdir -p /opt/consul
sudo chown -R consul:consul /opt/consul
sudo chmod -R 775 /opt/consul
echo "created and configured Consul..." >> ${SRC_DIR}/install-progress.log

# Generate a random Consul mamagement token
##CONSUL_MGMT_TOKEN=$(openssl rand -hex 16 | sed -E 's/(.{8})(.{4})(.{4})(.{4})(.{12})/\1-\2-\3-\4-\5/')
##echo "Consul Management Token: $CONSUL_MGMT_TOKEN" >> /home/ubuntu/install-progress.log

# Create dir "certs" for certs in /etc/consul.d
##sudo mkdir -p /etc/consul.d/certs
### Move CA cert to /etc/consul.d/certs
##echo "Moving certs to /etc/consul.d/certs ..." >> ${SRC_DIR}/install-progress.log
##sudo mv ${CERTS_DIR}/ca-cert.pem /etc/consul.d/certs/.
### Move Server cert to /etc/consul.d/certs
##sudo mv ${CERTS_DIR}/consul-server-cert.pem /etc/consul.d/certs/.
### Move Server key to /etc/consul.d/certs
##sudo mv ${CERTS_DIR}/consul-server-key.pem /etc/consul.d/certs/.
##sudo chown -R consul:consul /etc/consul.d
##sudo chmod -R 775 /etc/consul.d

# Start Consul
echo "Copying consul.service unit file..." >> ${SRC_DIR}/install-progress.log
sudo mv ${SRC_DIR}/consul.service /usr/lib/systemd/system/.
sudo systemctl daemon-reload
echo "enabling and starting Consul Service..." >> ${SRC_DIR}/install-progress.log
sudo systemctl enable consul
sudo systemctl start consul

# DONE
echo "DONE! Installing Consul Server(s)" >> ${SRC_DIR}/install-progress.log
