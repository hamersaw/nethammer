#!/bin/bash

# parse incoming arguments
declare -A args
for ARG in $@; do
    IFS='=' read -ra ARRAY <<< "$ARG"
    args["${ARRAY[0]}"]="${ARRAY[1]}"
done

# retrieve argument values
interface="${args[wifi.interface]}"

ip link set $interface down
iw dev $interface set monitor control
ip link set $interface up
