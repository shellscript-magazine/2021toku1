#!/bin/sh

##固定IPアドレス
IP_ADDRESS="192.168.10.100"
GATEWAY_IPV4="192.168.10.1"

##旧設定バックアップ
mkdir -p ~/old_settings
sudo mv /etc/netplan/50-cloud-init.yaml ~/old_settings/.

##新ネットワーク設定作成
cat << EOF | sudo tee /etc/netplan/50-cloud-init.yaml > /dev/null
network:
  ethernets:
    eth0:
      dhcp4: false
      addresses: [ip_address/24]
      gateway4: gateway_ipv4
      nameservers:
        addresses: [8.8.8.8]
  version: 2
EOF
sudo sed -i -e "s%ip_address%$IP_ADDRESS%" /etc/netplan/50-cloud-init.yaml
sudo sed -i -e "s%gateway_ipv4%$GATEWAY_IPV4%" /etc/netplan/50-cloud-init.yaml

##ネットワーク設定反映
sudo netplan apply
