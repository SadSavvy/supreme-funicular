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
