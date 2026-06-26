# Release notes

## v0.1.1

Patch release from first real-world M1/Mac mini test.

- Fix Bluetooth state parsing for macOS builds that report `State: On` instead of `Bluetooth Power: On` in `system_profiler SPBluetoothDataType`
- Keeps the tool read-only: no sudo, no toggles, no service restarts, no preference edits

## v0.1.0

Initial read-only diagnostic MVP for Universal Control / AirPlay-to-Mac / Display sharing discovery failures.

- Checks macOS, Mac model, Wi-Fi, Bluetooth, AWDL, Handoff hint, and firewall state
- Shows relevant manual Settings paths
- Prints recent Universal Control / AirPlay / Handoff / AWDL log hints with a privacy warning
- Provides safest manual recovery order
- No sudo, no Bluetooth/Wi-Fi/Handoff/AWDL toggles, no service restarts, no preference edits, no cleanup
