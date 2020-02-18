#!/bin/bash
#
# {
#   "description" : "switch NIC to managed mode",
#   "options" : [
#     {
#       "name" : "wifi.interface",
#       "description" : "network interface identifier",
#       "flag" : "i",
#       "required" : "true"
#     }
#   ]
# }

usage="usage $(basename $0) -i <interface>"

# parse arguments
while getopts 'hi:' opt; do
    case ${opt} in
        h)
            echo "$usage"
            exit 0
            ;;
        i) interface="$OPTARG" ;;
        ?)
            echo "$usage"
            exit 1
            ;;
    esac
done

# ensure required arguments are set
[ -z "$interface" ] && echo "$usage" && exit 1

# update nic type to managed
ip link set $interface down
iw dev $interface set type managed
ip link set $interface up
