#!/bin/python3
import os, sys
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
            print('"%s" %s' % (ssid, addr), flush=True)

if __name__ == "__main__":
    # parse arguments
    args = {}
    for arg in sys.argv[1:]:
        array = arg.split('=')
        args[array[0]] = array[1]

    # execute scapy sniffer
    interface = args['wifi.interface']
    sniff(iface=interface, prn=process_packet)
