#!/bin/bash

# parse incoming arguments
declare -A args
for ARG in $@; do
    IFS='=' read -ra ARRAY <<< "$ARG"
    args["${ARRAY[0]}"]="${ARRAY[1]}"
done

# perform operation
interface="${args[wifi.interface]}"

iw dev $interface set type monitor
