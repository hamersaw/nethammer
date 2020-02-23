#!/bin/bash
#
# {
#   "description" : "enable a NIC channel hopping loop",
#   "options" : [
#     {
#       "name" : "wifi.channel.hop-duration",
#       "description" : "sleep duration (in seconds) between hops",
#       "flag" : "d",
#       "required" : "false",
#       "default" : 5
#     },
#     {
#       "name" : "net.interface",
#       "description" : "network interface identifier",
#       "flag" : "i",
#       "required" : "true"
#     }
#   ]
# }

usage="usage $(basename $0) [-d <duration>] -i <interface>"

# parse arguments
duration=5
while getopts 'd:hi:' opt; do
    case ${opt} in
        d) duration="$OPTARG" ;;
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

# check if host has required applications installed
[ ! $(which iw) ] && echo "'iw' not found in users PATH" && exit 1

# start changing channel of nic
while true; do
    CHANNEL=$((1 + RANDOM % 14))
    iw dev $interface set channel $CHANNEL

    sleep $duration
done
