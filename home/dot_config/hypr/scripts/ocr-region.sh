#!/usr/bin/env bash
set -Eeuo pipefail

lang="${1:-ces+deu+eng}"
region=""
picker_pid=""

need() {
	command -v "$1" >/dev/null 2>&1 || {
		printf 'missing dependency: %s\n' "$1" >&2
		exit 127
	}
}

cleanup() {
	[[ -n "${picker_pid:-}" ]] && kill "$picker_pid" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

for dep in grim slurp magick tesseract wl-copy; do
	need "$dep"
done

if command -v hyprpicker >/dev/null 2>&1; then
	hyprpicker -r -z >/dev/null 2>&1 &
	picker_pid=$!
	sleep 0.1
fi

region="$(slurp -b '#00000080' -c '#888888ff' -w 1)" || exit 0
[[ -n "$region" ]] || exit 0
cleanup
picker_pid=""

grim -g "$region" - \
	| magick - -colorspace Gray -normalize -contrast-stretch 2% -sharpen 0x1.0 -resize 200% png:- \
	| tesseract - stdout -l "$lang" --psm 6 \
	| wl-copy

if command -v notify-send >/dev/null 2>&1; then
	preview="$(wl-paste | head -c 500)"
	notify-send "OCR copied" "$preview"
fi
