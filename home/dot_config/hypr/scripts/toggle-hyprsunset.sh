#!/usr/bin/env bash
set -euo pipefail

if pgrep -x hyprsunset >/dev/null; then
	pkill -x hyprsunset
	command -v notify-send >/dev/null && notify-send "Hyprsunset" "Disabled"
else
	hyprsunset >/dev/null 2>&1 &
	disown
	command -v notify-send >/dev/null && notify-send "Hyprsunset" "Enabled"
fi
