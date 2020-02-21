#!/bin/bash
#
# {
#   "description" : "use tshark to capture traffic from an interface",
#   "options" : [
#     {
#       "name" : "net.capture.filter",
#       "description" : "tshark capture filter",
#       "flag" : "f",
#       "required" : "false"
#     },
#     {
#       "name" : "net.interface",
#       "description" : "network interface identifier",
#       "flag" : "i",
#       "required" : "true"
#     },
#     {
#       "name" : "net.capture.file",
#       "description" : "pcap output file",
#       "flag" : "w",
#       "required" : "false"
#     }
#   ]
# }

usage="usage $(basename $0) -i <interface>"

# parse arguments
filename="$(pwd)/$(date +%Y%m%d%H%M%S).pcap"
while getopts 'f:hi:' opt; do
    case ${opt} in
        f) filter="$OPTARG" ;;
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
args="-i $interface -w $filename"
if [ ! -z "$filter" ]; then
    args+=" -f '$filter'"
fi

touch $filename
tshark $args
