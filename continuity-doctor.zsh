#!/usr/bin/env zsh
# continuity-doctor — read-only macOS Continuity / Universal Control diagnostics
# v0.1.1
set -u

SCRIPT_NAME="continuity-doctor"
VERSION="0.1.1"
LOG_MINUTES=10

usage() {
  cat <<'USAGE'
continuity-doctor — diagnose Universal Control / AirPlay / Display sharing discovery safely

Usage:
  zsh continuity-doctor.zsh check
  zsh continuity-doctor.zsh logs [--minutes N]
  zsh continuity-doctor.zsh explain
  zsh continuity-doctor.zsh help

Safety:
  - read-only
  - no sudo
  - does not toggle Bluetooth, Wi-Fi, Handoff, AWDL, or services
  - does not edit preferences or delete files
  - prints clues and manual next steps only
USAGE
}

header() {
  echo "$SCRIPT_NAME $VERSION"
  echo "Read-only diagnostics. No toggles. No sudo. No preference edits."
  echo
}

status_line() {
  local level="$1" label="$2" detail="$3"
  printf '%-6s  %-28s  %s\n' "$level" "$label" "$detail"
}

cmd_exists() { command -v "$1" >/dev/null 2>&1 }

macos_info() {
  local product build
  product=$(sw_vers -productVersion 2>/dev/null || echo unknown)
  build=$(sw_vers -buildVersion 2>/dev/null || echo unknown)
  status_line GREEN "macOS" "$product ($build)"
}

hardware_info() {
  local model
  model=$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Model Name|Model Identifier/ {print $2; exit}')
  [[ -n "${model:-}" ]] || model="unknown"
  status_line INFO "Mac model" "$model"
}

wifi_info() {
  local ports iface power
  ports=$(networksetup -listallhardwareports 2>/dev/null || true)
  iface=$(printf '%s\n' "$ports" | awk '/Hardware Port: Wi-Fi|Hardware Port: AirPort/{getline; sub("Device: ",""); print; exit}')
  if [[ -z "${iface:-}" ]]; then
    status_line YELLOW "Wi-Fi" "interface not found"
    return 0
  fi
  power=$(networksetup -getairportpower "$iface" 2>/dev/null || true)
  if [[ "$power" == *": On"* ]]; then
    status_line GREEN "Wi-Fi" "$iface is on"
  elif [[ "$power" == *": Off"* ]]; then
    status_line RED "Wi-Fi" "$iface is off; Continuity features need Wi-Fi"
  else
    status_line YELLOW "Wi-Fi" "could not read power state for $iface"
  fi
}

bluetooth_info() {
  local bt
  # macOS reports this as `Bluetooth Power: On` on some versions and
  # `State: On` under `Bluetooth Controller` on newer/other builds.
  bt=$(system_profiler SPBluetoothDataType 2>/dev/null | awk -F': ' '
    /Bluetooth Power/ {print $2; exit}
    /^[[:space:]]*State:/ {print $2; exit}
  ')
  case "$bt" in
    On) status_line GREEN "Bluetooth" "on" ;;
    Off) status_line RED "Bluetooth" "off; Universal Control needs Bluetooth" ;;
    *) status_line YELLOW "Bluetooth" "state unknown; verify manually in System Settings" ;;
  esac
}

awdl_info() {
  local awdl
  awdl=$(ifconfig awdl0 2>/dev/null || true)
  if [[ -n "$awdl" ]]; then
    if printf '%s\n' "$awdl" | grep -q "status: active"; then
      status_line GREEN "AWDL" "awdl0 present/active"
    else
      status_line YELLOW "AWDL" "awdl0 present but not active"
    fi
  else
    status_line YELLOW "AWDL" "awdl0 not readable/present"
  fi
}

handoff_info() {
  local val
  val=$(defaults read ~/Library/Preferences/ByHost/com.apple.coreservices.useractivityd ActivityAdvertisingAllowed 2>/dev/null || true)
  case "$val" in
    1) status_line GREEN "Handoff advertising" "allowed" ;;
    0) status_line YELLOW "Handoff advertising" "appears disabled" ;;
    *) status_line INFO "Handoff advertising" "preference not readable; verify in System Settings" ;;
  esac
}

firewall_info() {
  local state
  state=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null || true)
  if [[ "$state" == *"disabled"* ]]; then
    status_line GREEN "Firewall" "global firewall disabled"
  elif [[ "$state" == *"enabled"* ]]; then
    status_line YELLOW "Firewall" "enabled; check Block all incoming / sharing rules"
  else
    status_line INFO "Firewall" "state unknown"
  fi
}

settings_paths() {
  echo
  echo "Manual settings paths to verify:"
  echo "- System Settings → Displays → Advanced → Link to Mac or iPad"
  echo "- System Settings → General → AirDrop & Handoff → Handoff"
  echo "- System Settings → General → Sharing → AirPlay Receiver / Screen Sharing"
  echo "- Control Center → Screen Mirroring / Display → Link Keyboard and Mouse"
}

check_cmd() {
  header
  macos_info
  hardware_info
  wifi_info
  bluetooth_info
  awdl_info
  handoff_info
  firewall_info
  settings_paths
  echo
  echo "Likely interpretation: if Wi-Fi/Bluetooth/AWDL look fine but devices vanish until Displays opens, suspect stale Continuity discovery/session state. This tool does not reset it."
}

logs_cmd() {
  local minutes="$LOG_MINUTES"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --minutes) minutes="${2:-}"; shift 2 ;;
      -h|--help) usage; return 0 ;;
      *) echo "error: unknown option: $1" >&2; return 2 ;;
    esac
  done
  if ! [[ "$minutes" == <-> ]]; then
    echo "error: --minutes must be an integer" >&2
    return 2
  fi
  header
  echo "Recent Universal Control / Continuity log hints, last ${minutes}m:"
  echo "Warning: logs may contain device names. Review before sharing publicly."
  echo
  log show --style compact --last "${minutes}m" --predicate 'subsystem CONTAINS "universalcontrol" OR eventMessage CONTAINS[c] "Universal Control" OR eventMessage CONTAINS[c] "AirPlay" OR eventMessage CONTAINS[c] "Handoff" OR eventMessage CONTAINS[c] "AWDL"' 2>/dev/null | tail -n 80 || true
}

explain_cmd() {
  header
  cat <<'TEXT'
What usually breaks:
1. Bluetooth proximity/discovery gets stale.
2. Wi-Fi/AWDL peer discovery is present but not actively refreshing.
3. Handoff or Display/AirPlay Receiver settings drift.
4. VPN, firewall, hotspot, Internet Sharing, or sleep/lock state blocks discovery.
5. Opening Displays forces macOS to re-enumerate nearby targets.

Safest manual order:
1. Wake/unlock both Macs; keep them close and on the same Apple Account.
2. Open Displays and use Add Display / Link Keyboard and Mouse.
3. Verify Wi-Fi, Bluetooth, Handoff, AirPlay Receiver, and Screen Sharing settings.
4. Pause VPN / hotspot / Internet Sharing / strict firewall modes temporarily.
5. If comfortable, manually toggle Bluetooth or Wi-Fi from System Settings.
6. Restart both Macs.
7. Advanced service/preferences resets are documentation-only for v0.1; this tool never performs them.
TEXT
}

main() {
  local cmd="${1:-help}"
  shift || true
  case "$cmd" in
    check) check_cmd "$@" ;;
    logs) logs_cmd "$@" ;;
    explain) explain_cmd "$@" ;;
    help|-h|--help) usage ;;
    version|--version) echo "$SCRIPT_NAME $VERSION" ;;
    *) echo "error: unknown command: $cmd" >&2; usage >&2; return 2 ;;
  esac
}

main "$@"
