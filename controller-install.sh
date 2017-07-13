apt-get update
apt-get install -y unzip

## Setup Consul

mkdir -p /var/lib/consul
wget https://releases.hashicorp.com/consul/0.8.5/consul_0.8.5_linux_amd64.zip
unzip consul_0.8.5_linux_amd64.zip -d /usr/local/bin/
rm consul_0.8.5_linux_amd64.zip

cat > consul.service <<EOF
[Unit]
Description=consul
Documentation=https://consul.io/docs/

[Service]
ExecStart=/usr/local/bin/consul agent \
  -advertise=ADVERTISE_ADDR \
  -bind=0.0.0.0 \
  -bootstrap-expect=3 \
  -client=0.0.0.0 \
  -data-dir=/var/lib/consul \
  -server \
  -ui
  
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

sed -i "s/ADVERTISE_ADDR/${IP_ADDRESS}/" consul.service

mv consul.service /etc/systemd/system/consul.service
systemctl enable consul
systemctl start consul

## Setup Nomad

wget https://releases.hashicorp.com/nomad/0.5.6/nomad_0.5.6_linux_amd64.zip
unzip nomad_0.5.6_linux_amd64.zip -d /usr/local/bin/

mkdir -p /var/lib/nomad
mkdir -p /etc/nomad

rm nomad_0.5.6_linux_amd64.zip

cat > server.hcl <<EOF
addresses {
    rpc  = "ADVERTISE_ADDR"
    serf = "ADVERTISE_ADDR"
}

advertise {
    http = "ADVERTISE_ADDR:4646"
    rpc  = "ADVERTISE_ADDR:4647"
    serf = "ADVERTISE_ADDR:4648"
}

bind_addr = "0.0.0.0"
data_dir  = "/var/lib/nomad"
log_level = "DEBUG"

server {
    enabled = true
    bootstrap_expect = 3
}
EOF

sed -i "s/ADVERTISE_ADDR/${IP_ADDRESS}/" server.hcl
mv server.hcl /etc/nomad/server.hcl

cat > nomad.service <<EOF
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
After=consul.service

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

## Setup dnsmasq
apt-get install -y dnsmasq
mkdir -p /etc/dnsmasq.d
cat > /etc/dnsmasq.d/10-consul <<EOF
server=/consul/127.0.0.1#8600
EOF

systemctl enable dnsmasq
systemctl start dnsmasq