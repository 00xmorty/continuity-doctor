# Continuity Doctor

A tiny read-only macOS CLI for diagnosing Universal Control / AirPlay-to-Mac / Display sharing discovery failures — the “my two Macs stop seeing each other until I open Displays or toggle Bluetooth” problem.

It is a diagnostic helper, not an auto-fixer. It does not toggle Bluetooth, Wi-Fi, Handoff, AWDL, services, or preferences.

## Safety

- Read-only by default and by design
- No `sudo`
- No preference writes
- No service restarts
- No Bluetooth/Wi-Fi/Handoff/AWDL toggles
- No file deletion or cleanup
- Log output may contain device names; review before sharing publicly

## Why

Universal Control, AirPlay Receiver, Screen Sharing, and Display discovery depend on several macOS subsystems: Bluetooth proximity, Wi-Fi/AWDL peer discovery, Handoff, sharing settings, firewall/VPN state, and Apple-private Continuity session state.

When discovery stalls, opening System Settings → Displays can force macOS to re-enumerate targets. This tool collects read-only clues and orders the safest manual recovery steps.

## Usage

```sh
zsh continuity-doctor.zsh check
zsh continuity-doctor.zsh logs --minutes 10
zsh continuity-doctor.zsh explain
```

## Public positioning

“Universal Control disappeared? Diagnose stale Continuity/AWDL state without toggling anything.”

## Manual next steps

1. Wake/unlock both Macs; keep them close and on the same Apple Account.
2. Open Displays and use Add Display / Link Keyboard and Mouse.
3. Verify Wi-Fi, Bluetooth, Handoff, AirPlay Receiver, and Screen Sharing settings.
4. Pause VPN / hotspot / Internet Sharing / strict firewall modes temporarily.
5. If comfortable, manually toggle Bluetooth or Wi-Fi from System Settings.
6. Restart both Macs.
7. Advanced service/preferences resets are documentation-only for v0.1; this tool never performs them.

## License

MIT
