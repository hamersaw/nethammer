{
    "channel-hop.sh" : {
        "description" : "enable a NIC channel hopping loop",
        "background" : "true",
        "options" : [
            {
                "name" : "wifi.interface",
                "description" : "network interface identifier",
                "required" : "true"
            }
        ]
    },
    "nic-down.sh" : {
        "description" : "set NIC to DOWN",
        "background" : "false",
        "options" : [
            {
                "name" : "wifi.interface",
                "description" : "network interface identifier",
                "required" : "true"
            }
        ]
    },
    "nic-up.sh" : {
        "description" : "set NIC to UP",
        "background" : "false",
        "options" : [
            {
                "name" : "wifi.interface",
                "description" : "network interface identifier",
                "required" : "true"
            }
        ]
    },
    "to-managed.sh" : {
        "description" : "switch NIC to managed mode",
        "background" : "false",
        "options" : [
            {
                "name" : "wifi.interface",
                "description" : "network interface identifier",
                "required" : "true"
            }
        ]
    },
    "to-monitor.sh" : {
        "description" : "switch NIC to monitor mode",
        "background" : "false",
        "options" : [
            {
                "name" : "wifi.interface",
                "description" : "network interface identifier",
                "required" : "true"
            }
        ]
    }
}
