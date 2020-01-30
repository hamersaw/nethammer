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
    },
    "wifi/rouge-ap.sh" : {
        "description" : "start a rouge AP with the specified attributes",
        "options" : [
            {
                "name" : "wifi.interface",
                "description" : "network interface identifier",
                "required" : "true"
            },
            {
                "name" : "wifi.channel",
                "description" : "channel for AP",
                "required" : "true"
            },
            {
                "name" : "wifi.ssid",
                "description" : "SSID for AP",
                "required" : "true"
            }
        ]
    }
}
