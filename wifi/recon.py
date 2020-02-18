#!/bin/python3
#
# {
#   "description" : "identify wifi APs and clients on NIC",
#   "options" : [
#     {
#       "name" : "wifi.interface",
#       "description" : "network interface identifier",
#       "flag" : "i",
#       "required" : "true"
#     }
#   ]
# }

import argparse, os, sys
from scapy.all import *

bssids = []
def process_packet(pkt):
    if pkt.haslayer(Dot11Beacon):
        addr = pkt.getlayer(Dot11).addr2

        # check if address has already been processed
        if addr not in bssids:
            bssids.append(addr)

            # print ssid
            ssid = pkt.getlayer(Dot11Elt).info.decode('utf-8')
            if ssid == '' or pkt.getlayer(Dot11Elt).ID != 0:
                print('"" %s' % (addr), flush=True)
            else:
                print('"%s" %s' % (ssid, addr), flush=True)

if __name__ == "__main__":
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--interface', required=True,
        help='network interface identifier')
    args = parser.parse_args()

    # execute scapy sniffer
    sniff(iface=args.i, prn=process_packet)
