#!/bin/bash

apt-get update
apt-get install -y unzip dnsmasq

# Setup Nomad

wget https://releases.hashicorp.com/nomad/0.5.6/nomad_0.5.6_linux_amd64.zip
unzip nomad_0.5.6_linux_amd64.zip -d /usr/local/bin/

mkdir -p /var/lib/nomad
mkdir -p /etc/nomad

rm nomad_0.5.6_linux_amd64.zip

cat > client.hcl <<EOF
addresses {
    rpc  = "ADVERTISE_ADDR"
    http = "ADVERTISE_ADDR"
}

advertise {
    http = "ADVERTISE_ADDR:4646"
    rpc  = "ADVERTISE_ADDR:4647"
}

bind_addr = "ADVERTISE_ADDR"
data_dir  = "/var/lib/nomad"
log_level = "DEBUG"

client {
    enabled = true
    servers = [
      "c1", "c2", "c3"
    ]
    options {
        "driver.raw_exec.enable" = "1"
    }
}
EOF

sed -i "s/ADVERTISE_ADDR/${IP_ADDRESS}/" client.hcl
mv client.hcl /etc/nomad/client.hcl

cat > nomad.service <<'EOF'
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/

[Service]
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

mv nomad.service /etc/systemd/system/nomad.service

systemctl enable nomad
systemctl start nomad

## Setup Consul

mkdir -p /var/lib/consul
wget https://releases.hashicorp.com/consul/0.8.5/consul_0.8.5_linux_amd64.zip
unzip consul_0.8.5_linux_amd64.zip -d /usr/local/bin/
rm consul_0.8.5_linux_amd64.zip

cat > consul.service <<EOF
[Unit]
Description=consul

[Service]
ExecStart=/usr/local/bin/consul agent -data-dir=/etc/consul.d -retry-join c1 -retry-join c2 -retry-join c3 -advertise=ADVERTISE_ADDR -ui

[Install]
WantedBy=multi-user.target
EOF

sed -i "s/ADVERTISE_ADDR/${IP_ADDRESS}/" consul.service

mv consul.service /etc/systemd/system/consul.service
systemctl enable consul
systemctl start consul

## Setup dnsmasq

mkdir -p /etc/dnsmasq.d
cat > /etc/dnsmasq.d/10-consul <<'EOF'
server=/consul/127.0.0.1#8600
EOF

cat > /etc/dnsmasq.d/20-fabio <<'EOF'
address=/.service/127.0.0.1
EOF

systemctl enable dnsmasq
systemctl start dnsmasq

## Install Docker

wget -q https://get.docker.com/builds/Linux/x86_64/docker-1.13.1.tgz
tar -xvf docker-1.13.1.tgz
cp docker/docker* /usr/bin/

cat > docker.service <<'EOF'
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io

[Service]
ExecStart=/usr/bin/docker daemon \
  --iptables=false \
  --ip-masq=false \
  --host=unix:///var/run/docker.sock \
  --log-level=error \
  --bridge=none \
  --storage-driver=overlay
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

mv docker.service /etc/systemd/system/docker.service

systemctl enable docker
systemctl start docker