#!/bin/bash
set -e
SRV="fake-service-a"
PORT="9091"
SRC_DIR="/tmp/${SRV}"
CERTS_DIR="/tmp/consul-common/certs"

sleep 30s
echo "Installing Fake Service A ..." > ${SRC_DIR}/install-progress.log

# Install unzip
echo "Installing unzip ..." > ${SRC_DIR}/install-progress.log
sudo apt install unzip

CONSUL_VERSION="1.20.2" #"1.18.5"
VERSION="${CONSUL_VERSION:0:4}.x"
case $VERSION in
  1.20.x)
    ENVOY_VERSION="1.31.5"
    ;;
  1.19.x)
    ENVOY_VERSION="1.29.10"
    ;;
  1.18.x)
    ENVOY_VERSION="1.28.7"
    ;;
  1.17.x)
    ENVOY_VERSION="1.27.7"
    ;;
  *)
    ENVOY_VERSION="1.23.1"
    ;;
esac

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
##sudo mv /home/ubuntu/ca-cert.pem /etc/consul.d/certs/.
### Move Server cert to /etc/consul.d/certs
##sudo mv /home/ubuntu/consul-server-cert.pem /etc/consul.d/certs/.
### Move Server key to /etc/consul.d/certs
##sudo mv /home/ubuntu/consul-server-key.pem /etc/consul.d/certs/.
##sudo chown -R consul:consul /etc/consul.d
##sudo chmod -R 775 /etc/consul.d

# Start Consul
echo "Copying consul.service unit file..." >> ${SRC_DIR}/install-progress.log
sudo mv ${SRC_DIR}/consul.service /usr/lib/systemd/system/.

sudo systemctl daemon-reload
echo "enabling and startring Consul Client Service..." >> ${SRC_DIR}/install-progress.log
sudo systemctl enable consul
sudo systemctl start consul

# DONE Installing Consul Client
echo "DONE! Installing Consul Client" >> ${SRC_DIR}/install-progress.log


# Install fake-service
echo "Installing ${SRV}..." >> ${SRC_DIR}/install-progress.log
# Download fake-service binary file
echo "Downloading fake-service binary file..." >> ${SRC_DIR}/install-progress.log
wget https://github.com/nicholasjackson/fake-service/releases/download/v0.26.2/fake_service_linux_amd64.zip -O ${SRC_DIR}/fake-service.zip

# Unzip fake-server to /usr/local/bin
sudo unzip ${SRC_DIR}/fake-service.zip
sudo cp fake-service /usr/local/bin/.
# Change permission on fake-service
sudo chmod +x /usr/local/bin/fake-service

echo "Starting fake services" >> ${SRC_DIR}/install-progress.log
# Start fake-server-a
LISTEN_ADDR=0.0.0.0:${PORT} NAME=${SRV} /usr/local/bin/fake-service > ${SRC_DIR}/${SRV}.log 2>&1 &
echo "Started ${SRV}" >> ${SRC_DIR}/install-progress.log

# Copy fake-service Consul registration config to /etc/consul.d/.
sudo cp ${SRC_DIR}/${SRV}.hcl /etc/consul.d/.

# Reload Consul
consul reload

# Download Envoy
echo "Downloading Envoy ${ENVOY_VERSION} binary" >> ${SRC_DIR}/install-progress.log
curl https://releases.hashicorp.com/envoy/${ENVOY_VERSION}/envoy_${ENVOY_VERSION}_linux_amd64.zip -o envoy.zip
unzip envoy.zip
sudo mv envoy /usr/local/sbin/.

# Starting envoy sidecar for fake-service
echo "Installing envoy sidecar..." >> ${SRC_DIR}/install-progress.log
touch ${SRC_DIR}/envoy-proxy.log
chown -R consul:consul ${SRC_DIR}/envoy-proxy.log
sudo chmod a+rw ${SRC_DIR}/envoy-proxy.log
consul connect envoy -envoy-binary /usr/local/sbin/envoy -sidecar-for ${SRV} >> ${SRC_DIR}/envoy-proxy.log 2>&1 &
echo "DONE! Installing envoy sidecar" >> ${SRC_DIR}/install-progress.log

# DONE
echo "DONE! Installing ${SRV}" >> ${SRC_DIR}/install-progress.log
