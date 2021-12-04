#!/bin/bash

sudo apt install -y dnsmasq hostapd iptables iptables-persistent

sudo tee /etc/hostapd/hostapd.conf > /dev/null <<EOF
interface=wlan0
driver=nl80211
hw_mode=g
channel=7
ieee80211n=1
wmm_enabled=0
macaddr_acl=0
ignore_broadcast_ssid=0
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ssid=$WIFI_SSID
wpa_passphrase=$WIFI_PASS

EOF

sudo tee /etc/dnsmasq.conf > /dev/null <<EOF
interface=wlan0
  dhcp-range=192.168.0.11,192.168.0.30,255.255.255.0,24h

EOF

sudo tee /etc/default/hostapd > /dev/null <<EOF
DAEMON_CONF="/etc/hostapd/hostapd.conf"

EOF

sudo tee /etc/sysctl.conf > /dev/null <<EOF
net.ipv4.ip_forward=1

EOF


sudo systemctl unmask hostapd
sudo systemctl enable hostapd dnsmasq


sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
nordvpn login --username $NORD_USERNAME --password $NORD_PASSWORD
nordvpn whitelist add port 22
nordvpn set firewall off
nordvpn set autoconnect on
sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
sudo iptables -A FORWARD -i tun0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o tun0 -j ACCEPT
sudo reboot
