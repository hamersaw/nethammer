{
    "nic/channel-hop.sh" : {
        "description" : "enable a NIC channel hopping loop",
        "options" : [
            {
                "name" : "wifi.interface",
                "description" : "network interface identifier",
                "required" : "true"
            }
        ]
    },
    "nic/to-managed.sh" : {
        "description" : "switch NIC to managed mode",
        "options" : [
            {
                "name" : "wifi.interface",
                "description" : "network interface identifier",
                "required" : "true"
            }
        ]
    },
    "nic/to-monitor.sh" : {
        "description" : "switch NIC to monitor mode",
        "options" : [
            {
                "name" : "wifi.interface",
                "description" : "network interface identifier",
                "required" : "true"
            }
        ]
    },
    "wifi/recon-ap.py" : {
        "description" : "identify wifi APs and clients on NIC",
        "options" : [
            {
                "name" : "wifi.interface",
                "description" : "network interface identifier",
                "required" : "true"
            }
        ]
    }
}
