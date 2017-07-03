# nomad-consul-fabio-dnsmasq-gcp-demo

## Prerequisites

## Setup

1. Create a new project in Google Compute Engine and call it : ``nomad-consul-fabio-dnsmasq``. When the project is ready, open the *Cloud Shell*.

2. Create three Compute Engine instances named respectively `c1`, `c2` and `c3`. The startup script server-install.sh will install and configure **Nomad** and **Consul**.

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