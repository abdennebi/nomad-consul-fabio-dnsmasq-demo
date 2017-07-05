# nomad-consul-fabio-dnsmasq-gcp-demo

## Prerequisites

## Setup

1. Create a new project in Google Compute Engine and call it : ``nomad-consul-fabio-dnsmasq``. When the project is ready, open the *Cloud Shell*.

2. Clone this repository :
```
cd ~
git clone https://github.com/HashiStack/nomad-consul-fabio-dnsmasq-gcp-demo.git
cd nomad-consul-fabio-dnsmasq-gcp-demo
```

3. Create three Compute Engine instances named respectively `c1`, `c2` and `c3`. The startup script `server-install.sh` will install and configure **Nomad** and **Consul**.

```
gcloud compute instances create c1 c2 c3 \
  --image-project ubuntu-os-cloud \
  --image-family ubuntu-1604-lts \
  --zone=us-west1-a \
  --boot-disk-size 10GB \
  --machine-type n1-standard-1 \
  --can-ip-forward \
  --metadata-from-file startup-script=server-install.sh
```

Output :

```
Created [https://www.googleapis.com/compute/v1/projects/nomad-consul-fabio-dnsmasq/zones/us-west1-a/instances/c1].
Created [https://www.googleapis.com/compute/v1/projects/nomad-consul-fabio-dnsmasq/zones/us-west1-a/instances/c2].
Created [https://www.googleapis.com/compute/v1/projects/nomad-consul-fabio-dnsmasq/zones/us-west1-a/instances/c3].

NAME  ZONE        MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
c1    us-west1-a  n1-standard-1               10.138.0.4   35.197.35.11   RUNNING
c2    us-west1-a  n1-standard-1               10.138.0.5   35.197.33.196  RUNNING
c3    us-west1-a  n1-standard-1               10.138.0.3   35.197.45.197  RUNNING
```

## Verify

Ssh to `c1` :

```
gcloud compute ssh c1
```
Let `c1` join `c2` and `c3`. Once joined, the *gossip layer* will handle discovery between `c2` and `c3`.

```
nomad server-join c2 c3
```

Output :

```
Joined 2 servers successfully
```

### Complete the setup of the consul cluster

```
consul join c2 c3
```
Output :

```
Successfully joined cluster by contacting 2 nodes.
```
Verify :

```
consul members
```

```
Node  Address          Status  Type    Build  Protocol  DC
c1    10.138.0.4:8301  alive   server  0.8.5  2         dc1
c2    10.138.0.5:8301  alive   server  0.8.5  2         dc1
c3    10.138.0.3:8301  alive   server  0.8.5  2         dc1
```

## Bootstrap Worker Nodes

```
gcloud compute instances create w1 w2 w3 w4 w5 \
  --image-project ubuntu-os-cloud \
  --image-family ubuntu-1604-lts \
  --zone=us-west1-a \
  --boot-disk-size 10GB \
  --machine-type n1-standard-1 \
  --metadata-from-file startup-script=client-install.sh
```