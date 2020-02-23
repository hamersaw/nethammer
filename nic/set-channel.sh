#!/bin/bash
#
# {
#   "description" : "set network interface channel",
#   "options" : [
#     {
#       "name" : "net.interface.channel",
#       "description" : "netowrk interface channel",
#       "flag" : "c",
#       "required" : "true"
#     },
#     {
#       "name" : "net.interface",
#       "description" : "network interface identifier",
#       "flag" : "i",
#       "required" : "true"
#     }
#   ]
# }

usage="usage $(basename $0) -c <channel> -i <interface>"

# parse arguments
while getopts 'c:hi:' opt; do
    case ${opt} in
        c) channel="$OPTARG" ;;
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
[ -z "$channel" ] && echo "$usage" && exit 1
[ -z "$interface" ] && echo "$usage" && exit 1

# check if host has required applications installed
[ ! $(which ip) ] && echo "'ip' not found in users PATH" && exit 1
[ ! $(which iw) ] && echo "'iw' not found in users PATH" && exit 1

# update nic channel
iw dev $interface set channel $CHANNEL
