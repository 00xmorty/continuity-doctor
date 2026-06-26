# Release notes

## v0.1.0

Initial read-only diagnostic MVP for Universal Control / AirPlay-to-Mac / Display sharing discovery failures.

- Checks macOS, Mac model, Wi-Fi, Bluetooth, AWDL, Handoff hint, and firewall state
- Shows relevant manual Settings paths
- Prints recent Universal Control / AirPlay / Handoff / AWDL log hints with a privacy warning
- Provides safest manual recovery order
- No sudo, no Bluetooth/Wi-Fi/Handoff/AWDL toggles, no service restarts, no preference edits, no cleanup
