#!/bin/bash

# TODO - check if host has programs: hostapd, udhcpd, iptables

# parse incoming arguments
declare -A args
for ARG in $@; do
    IFS='=' read -ra ARRAY <<< "$ARG"
    args["${ARRAY[0]}"]="${ARRAY[1]}"
done

# retrieve argument values
interface="${args[wifi.interface]}"
channel="${args[wifi.channel]}"
ssid="${args[wifi.ssid]}"

# start hostapd
hostapd_config="/tmp/nethammer/hostapd.conf"
mkdir -p $(dirname $hostapd_config)

# TODO - WPA - https://www.pi-point.co.uk/configs-hostapd/wpa-config/
echo "interface=$interface
driver=nl80211
ssid=$ssid
channel=$channel" > $hostapd_config

hostapd $hostapd_config &
hostapd_pid="$!"

# TODO - enable traffic forwarding
## ENABLE PACKET FORWARDING
#sysctl net.ipv4.ip_forward=1

## ENABLE NAT
#systemctl start iptables
#iptables -t nat -A POSTROUTING -o wlp2s0 -j MASQUERADE
#iptables -A FORWARD -i wlp0s20u1 -o wlp2s0 -j ACCEPT

#iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
#iptables --append FORWARD --in-interface wlan1mon -j ACCEPT
#echo 1 > /proc/sys/net/ipv4/ip_forward

# set interface address
ip addr add 192.168.69.1/24 dev $interface >/dev/null 2>&1

# setup dhcp server
udhcpd_config="/tmp/nethammer/udhcpd.conf"
mkdir -p $(dirname $udhcpd_config)

udhcpd_leases="/tmp/nethammer/udhcpd.leases"
touch $udhcpd_leases

echo "start		192.168.69.100
end		    192.168.69.240
interface	$interface
lease_file	$udhcpd_leases" > $udhcpd_config

udhcpd -f $udhcpd_config &
udhcpd_pid="$!"

# kill children processes when this script closes
trap "trap - SIGTERM && kill $hostapd_pid $udhcpd_pid $$" SIGINT SIGTERM EXIT

# keep script running indefinitely
while true; do sleep 1; done
