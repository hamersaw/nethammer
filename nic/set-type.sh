#!/bin/bash
#
# {
#   "description" : "set network interface type",
#   "options" : [
#     {
#       "name" : "net.interface",
#       "description" : "network interface identifier",
#       "flag" : "i",
#       "required" : "true"
#     },
#     {
#       "name" : "net.interface.type",
#       "description" : "NIC type ['managed', 'monitor']",
#       "flag" : "t",
#       "required" : "false",
#       "default" : "monitor"
#     }
#   ]
# }

usage="usage $(basename $0) -i <interface>"

# parse arguments
interface_type="monitor"
while getopts 'hi:t:' opt; do
    case ${opt} in
        h)
            echo "$usage"
            exit 0
            ;;
        i) interface="$OPTARG" ;;
        t) interface_type="$OPTARG" ;;
        ?)
            echo "$usage"
            exit 1
            ;;
    esac
done

# ensure required arguments are set
[ -z "$interface" ] && echo "$usage" && exit 1

# check if host has required applications installed
[ ! $(which ip) ] && echo "'ip' not found in users PATH" && exit 1
[ ! $(which iw) ] && echo "'iw' not found in users PATH" && exit 1

# update nic type
ip link set $interface down
iw dev $interface set type $interface_type
ip link set $interface up
