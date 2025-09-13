# J5 Wi-Fi Toolset (`j5wifi.sh`)

## Overview

`j5wifi.sh` is a Bash-based Wi-Fi toolkit optimized for the **J5 RT5572 USB wireless adapter**. It allows security enthusiasts, penetration testers, and hobbyists to perform common Wi-Fi operations, including network scanning, handshake capture, deauthentication attacks, rogue AP creation, MAC address modification, and background handshake cracking—all while preserving your internal Wi-Fi connection.

**Key Principles:**
- Uses only the J5 adapter (`wlan0`) for active attacks.
- Internal Wi-Fi (`wlan1`) remains untouched for uninterrupted internet access.
- Includes hints and help menus for each feature.
- Designed for authorized testing in controlled environments.

---

## Features

1. **Test packet injection** – Validate adapter and driver capabilities.  
2. **Scan Wi-Fi networks** – Discover nearby APs with live updates.  
3. **Automatic handshake capture** – Capture WPA/WPA2 handshakes efficiently.  
4. **Background handshake cracking** – Run aircrack-ng or hashcat in background.  
5. **Deauthentication attack** – Target a client or broadcast deauth responsibly.  
6. **Change MAC address** – Randomize or set custom MAC for the J5.  
7. **WPS PIN attack** – Run reaver or bully for WPS testing.  
8. **Rogue AP / Evil Twin** – Create a fake access point for testing.  
9. **Packet sniffing** – Monitor or save traffic via tcpdump.  
10. **Network mapping / client discovery** – Identify clients on a network.  
11. **Hidden SSID discovery** – Reveal hidden networks.  
12. **Channel hopping** – Scan multiple channels automatically.  
13. **Signal strength mapping** – Observe RSSI variations for a network.  
14. **Handshake verification** – Confirm handshake completeness.  
15. **WPA2-Enterprise testing** – Notes for EAP/WPA2-Enterprise tools.  
16. **Advanced handshake cracking** – Hashcat for speed and efficiency.  
17. **Log / report generation** – Save a snapshot of interfaces and configurations.  
18. **Update toolset** – Pull latest changes if installed as a Git repo.  
19. **Set regulatory domain** – Adjust country-specific wireless limits.  
20. **Restore J5 adapter** – Revert J5 to managed mode.  
21. **Install drivers** – Compile and install RT5572 drivers if missing.  
22. **Hints & Help menu** – Provides guidance for each tool.

---

## Requirements

- **Kali Linux** (minimal or full installation)  
- **J5 RT5572 USB adapter** (`wlan0`)  
- Internal Wi-Fi (`wlan1`) remains intact  
- Bash shell  
- Optional: `xterm`, `macchanger`, `aircrack-ng`, `hashcat`, `reaver`, `bully`, `airbase-ng`, `tcpdump`  

Install dependencies:
```bash
sudo apt update
sudo apt install -y aircrack-ng xterm macchanger hashcat reaver bully airbase-ng tcpdump

Adapter Compatibility Notes

The J5 Wi-Fi Toolset is specifically optimized for the J5 RT5572 USB wireless adapter, but its underlying Bash script is designed to be adaptable to other Wi-Fi adapters provided they meet certain requirements.

Requirements for Compatibility

Chipset Support

The adapter must use a chipset supported by Linux for monitor mode and packet injection.

Example supported chipsets:

Ralink/MediaTek: RT5572, RT3070, RT5370

Atheros: AR9271, AR7010

Realtek: RTL8812AU, RTL8187

Check compatibility using:

  iw list
aireplay-ng --test <interface>
Driver Support

The adapter must have a Linux driver that supports monitor mode (iw dev <iface> set type monitor) and injection (aireplay-ng --test).

For some chipsets, you may need to install drivers manually:
sudo apt install build-essential dkms linux-headers-$(uname -r)

Example: RT5572 uses rt2800usb, while RTL8812AU may require rtl8812au-dkms.

Interface Identification

The toolset defaults to the J5 adapter as wlan0.

If using a different adapter, set the variable at the top of j5wifi.sh:
J5_IF="wlan0"   # Replace with your compatible adapter
CHIPSET="rt5572"  # Replace with your adapter's chipset

Testing Before Use

Always confirm that the adapter can perform packet injection and monitor mode before running attacks:
sudo ip link set wlanX down
sudo iw dev wlanX set type monitor
sudo ip link set wlanX up
sudo aireplay-ng --test wlanX

If the adapter passes the test, the toolset functions (scanning, deauth, capture, etc.) should work seamlessly.

Notes

Some adapters may require additional firmware packages; check dmesg for errors when plugging in a new adapter.

Multi-adapter setups can be used. Only the adapter designated in J5_IF will be affected by the toolset—internal or secondary Wi-Fi remains untouched.

Long-term compatibility depends on Linux kernel updates and driver support for your specific chipset.




