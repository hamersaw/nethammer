#!/bin/bash

# load scripter shell library
source $scripterlibsh

# retrieve argument values
interface=$(get_or_fail "wifi.interface" $@)
[ -z "$interface" ] && echo "option 'wifi.interface' not set" && exit 1

# start changing channel of nic
while true; do
    CHANNEL=$((1 + RANDOM % 14))
    iw dev $interface set channel $CHANNEL

    sleep 1
done
