#!/bin/bash
#
# {
#   "description" : "use dumpcap to capture WPA handshake packets",
#   "options" : [
#     {
#       "name" : "net.interface",
#       "description" : "network interface identifier",
#       "flag" : "i",
#       "required" : "true"
#     },
#     {
#       "name" : "net.capture.file",
#       "description" : "pcapng output file",
#       "flag" : "w",
#       "required" : "false",
#       "default" : "wpa-handshake-YYYYmmddHHMMSS.pcapng"
#     }
#   ]
# }

usage="usage $(basename $0) -i <interface>"

# parse arguments
filename="$(pwd)/wpa-handshake-$(date +%Y%m%d%H%M%S).pcapng"
while getopts 'hi:s:' opt; do
    case ${opt} in
        h)
            echo "$usage"
            exit 0
            ;;
        i) interface="$OPTARG" ;;
        w) filename="$OPTARG" ;;
        ?)
            echo "$usage"
            exit 1
            ;;
    esac
done

# ensure required arguments are set
[ -z "$interface" ] && echo "$usage" && exit 1

# capture traffic
args="-i:$interface:-w:$filename:-f:wlan[0] == 0x80 || wlan[0] == 0x05 || ether proto 0x888e"

OFS=$IFS; IFS=":"
dumpcap $args
