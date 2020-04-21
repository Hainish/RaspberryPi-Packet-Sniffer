#!/bin/bash
# This is a script you can run on Raspbian to set up mitmproxy on a Raspberry Pi.  This uses the wireless interface to set up an access point.  The wired interface is used to connect to the upstream network.
# Tested on Raspbian release 2019-09-26 with a Raspberry Pi 3 Model B V1.2

# Ensure we exit on error
set -e

# Install dnsmasq, hostapd for IP assignment and an access point
sudo apt-get update
sudo apt-get install -y dnsmasq hostapd python3-pip

# Remove wpasupplicant so it doesn't interfere with our hostapd
sudo apt-get remove --purge -y wpasupplicant

# Assign a static ip to the wlan0 interface
sudo bash -c "echo 'interface wlan0' >> /etc/dhcpcd.conf"
sudo bash -c "echo 'static ip_address=172.24.1.1/24' >> /etc/dhcpcd.conf"

# Download the hostapd config, enable the service
sudo wget -O /etc/hostapd/hostapd.conf https://raw.githubusercontent.com/Hainish/RaspberryPi-Packet-Sniffer/master/hostapd.conf
sudo bash -c "echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' > /etc/default/hostapd"
sudo systemctl unmask hostapd.service
sudo systemctl enable hostapd

# Download the dnsmasq config, enable the service
sudo wget -O /etc/dnsmasq.conf https://raw.githubusercontent.com/Hainish/RaspberryPi-Packet-Sniffer/master/dnsmasq.conf
sudo systemctl enable dnsmasq

# Install the latest mitmproxy and download a script which forwards http & https requests through it
sudo pip3 install mitmproxy
wget https://raw.githubusercontent.com/Hainish/RaspberryPi-Packet-Sniffer/master/mitm.sh
chmod +x mitm.sh

# Reboot to start dnsmasq, hostapd and apply ip forwarding.
# mitm.sh has to be run manually to start MITMing traffic
sudo reboot
