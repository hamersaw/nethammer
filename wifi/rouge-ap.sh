#!/bin/bash
#
# {
#   "description" : "start a rouge AP with the specified attributes",
#   "options" : [
#     {
#       "name" : "wifi.channel",
#       "description" : "channel for AP",
#       "flag" : "c",
#       "required" : "false",
#       "default" : 7
#     },
#     {
#       "name" : "wifi.interface",
#       "description" : "network interface identifier",
#       "flag" : "i",
#       "required" : "true"
#     },
#     {
#       "name" : "wifi.auth.password",
#       "description" : "wpa password for wifi AP",
#       "flag" : "p",
#       "required" : "false"
#     },
#     {
#       "name" : "wifi.ssid",
#       "description" : "SSID for AP",
#       "flag" : "s",
#       "required" : "true"
#     }
#   ]
# }

usage="usage $(basename $0) [-c <channel>] -i <interface> \
[-p <password>] -s <ssid>"

# parse arguments
channel=7
while getopts 'c:hi:p:s:' opt; do
    case ${opt} in
        c) channel="$OPTARG" ;;
        h)
            echo "$usage"
            exit 0
            ;;
        i) interface="$OPTARG" ;;
        p) password="$OPTARG" ;;
        s) ssid="$OPTARG" ;;
        ?)
            echo "$usage"
            exit 1
            ;;
    esac
done

# ensure required arguments are set
[ -z "$interface" ] && echo "$usage" && exit 1
[ -z "$ssid" ] && echo "$usage" && exit 1

# check if host has required applications installed
[ ! $(which hostapd) ] \
    && echo "'hostapd' not found in users PATH" && exit 1
[ ! $(which ip) ] && echo "'ip' not found in users PATH" && exit 1
[ ! $(which udhcpd) ] \
    && echo "'udhcpd' not found in users PATH" && exit 1
[ ! $(which iptables) ] \
    && echo "'iptables' not found in users PATH" && exit 1

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

if [ ! -z "$password" ]; then
    echo "auth_algs=1
wpa=2
wpa_passphrase=$password
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
