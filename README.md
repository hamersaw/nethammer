# nethammer
## OVERVIEW
A [scripter](https://github.com/hamersaw/scripter) repository for network penetration testing.

## COMMON CAPTURE FILTERS
    # wifi beacon frames
    'wlan[0] == 0x80'

    # wifi wpa handshake
    'ether proto 0x888e'

## TODO
- fill out functionality
- automate wpa handshake capture - https://github.com/r-a-w/DriveShake
- add wifi.auth.type to wifi/rouge-ap.sh
