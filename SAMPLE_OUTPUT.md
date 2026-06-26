# SAMPLE OUTPUT — Continuity Doctor

```text
continuity-doctor 0.1.0
Read-only diagnostics. No toggles. No sudo. No preference edits.

GREEN   macOS                         26.5 (25Fxx)
INFO    Mac model                     Mac mini
GREEN   Wi-Fi                         en0 is on
GREEN   Bluetooth                     on
YELLOW  AWDL                          awdl0 present but not active
INFO    Handoff advertising           preference not readable; verify in System Settings
YELLOW  Firewall                      enabled; check Block all incoming / sharing rules

Manual settings paths to verify:
- System Settings → Displays → Advanced → Link to Mac or iPad
- System Settings → General → AirDrop & Handoff → Handoff
- System Settings → General → Sharing → AirPlay Receiver / Screen Sharing
- Control Center → Screen Mirroring / Display → Link Keyboard and Mouse

Likely interpretation: if Wi-Fi/Bluetooth/AWDL look fine but devices vanish until Displays opens, suspect stale Continuity discovery/session state. This tool does not reset it.
```
