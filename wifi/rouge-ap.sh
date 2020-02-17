#!/bin/bash

# load scripter shell library
source $scripterlibsh

# check if host has required applications installed
[ ! $(which hostapd) ] \
    && echo "'hostapd' not found in users PATH" && exit 1
[ ! $(which udhcpd) ] \
    && echo "'udhcpd' not found in users PATH" && exit 1
[ ! $(which iptables) ] \
    && echo "'iptables' not found in users PATH" && exit 1

# retrieve argument values
interface=$(get_or_fail "wifi.interface" $@)
[ -z "$interface" ] && echo "option 'wifi.interface' not set" && exit 1
channel=$(get_or_else "wifi.channel" 7 $@)
ssid=$(get_or_else "wifi.ssid" "nethammer" $@)
ssid=$(get_or_fail "wifi.auth.password" $@)

# initialize instance variables
config_dir="/tmp/nethammer-rouge-ap"
hostapd_config="$config_dir/hostapd.config"
udhcpd_config="$config_dir/udhcpd.config"
udhcpd_leases="$config_dir/udhcpd.leases"

mkdir -p $config_dir

# setup script cleanup
egress() {
    # unset interface address
    ip addr del 192.168.69.1/24 dev $interface

    # rollback iptables changes
    sysctl net.ipv4.ip_forward=0
    iptables -D FORWARD -i $interface -o wlp82s0 -j ACCEPT
    iptables -t nat -D POSTROUTING -o wlp82s0 -j MASQUERADE

    # cleanup tmp directories
    rm -r $config_dir

    # kill background processes and self
    trap - SIGTERM
    kill $(jobs -p) $$
}

trap egress SIGTERM EXIT

# start hostapd
echo "interface=$interface
driver=nl80211
ssid=$ssid
hw_mode=g
channel=$channel
macaddr_acl=0
ignore_broadcast_ssid=0" > $hostapd_config

if [ ! -z "$wpa_password" ]; then
    echo "auth_algs=1
wpa=2
wpa_passphrase=$wpa_password
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP" >> $hostapd_config
fi

hostapd $hostapd_config &

# set interface address
ip addr add 192.168.69.1/24 dev $interface

# enable traffic forwarding
sysctl net.ipv4.ip_forward=1

iptables -A FORWARD -i $interface -o wlp82s0 -j ACCEPT
iptables -t nat -A POSTROUTING -o wlp82s0 -j MASQUERADE

# setup dhcp server
echo "start		192.168.69.100
end		    192.168.69.240
interface	$interface
lease_file	$udhcpd_leases
opt         dns     8.8.8.8
option      subnet  255.255.255.0
opt         router  192.168.69.1" > $udhcpd_config

touch $udhcpd_leases

udhcpd -f $udhcpd_config &

# keep script running indefinitely
while true; do sleep 1; done
