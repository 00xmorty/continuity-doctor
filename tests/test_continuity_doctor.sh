#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT/continuity-doctor.zsh"

zsh -n "$SCRIPT"

zsh "$SCRIPT" version | grep -q "continuity-doctor 0.1.0"
zsh "$SCRIPT" help | grep -q "read-only"
zsh "$SCRIPT" explain | grep -q "Safest manual order"
zsh "$SCRIPT" check >/tmp/continuity_doctor_check.txt
grep -q "Read-only diagnostics" /tmp/continuity_doctor_check.txt
grep -q "Manual settings paths" /tmp/continuity_doctor_check.txt

if zsh "$SCRIPT" logs --minutes nope >/tmp/continuity_doctor_bad.txt 2>&1; then
  echo "expected invalid --minutes to fail" >&2
  exit 1
fi
grep -q "must be an integer" /tmp/continuity_doctor_bad.txt

# Guardrail: v0.1 must not contain actual mutating command patterns.
# Mentions such as "no sudo" are allowed; executable mutation patterns are not.
if grep -E '(defaults[[:space:]]+write|networksetup[[:space:]]+-set|ifconfig[[:space:]]+awdl0[[:space:]]+down|blueutil[[:space:]]+-p[[:space:]]+0|^[[:space:]]*(sudo|launchctl|killall|osascript|diskutil|pkill|reboot|shutdown)([[:space:]]|$))' "$SCRIPT"; then
  echo "mutating command pattern found" >&2
  exit 1
fi

rm -f /tmp/continuity_doctor_check.txt /tmp/continuity_doctor_bad.txt

echo "ok continuity-doctor smoke"
