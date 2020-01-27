#!/bin/bash

# parse incoming arguments
declare -A args
for ARG in $@; do
    IFS='=' read -ra ARRAY <<< "$ARG"
    args["${ARRAY[0]}"]="${ARRAY[1]}"
done

# perform operation
interface="${args[wifi.interface]}"

# start changing channel of nic
while true; do
    CHANNEL=$((1 + RANDOM % 14))
    iw dev $interface set channel $CHANNEL

    sleep 1
done
