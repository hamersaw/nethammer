#!/bin/bash

# load scripter shell library
source $scripterlibsh

# retrieve argument values
interface=$(get_or_fail "wifi.interface" $@)
[ -z "$interface" ] && echo "option 'wifi.interface' not set" && exit 1

# update nic type to managed
ip link set $interface down
iw dev $interface set type managed
ip link set $interface up
