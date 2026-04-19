#!/usr/bin/env bash
set -euo pipefail

# This script is executed by GnomeDesktopThumbnailFactory inside a bwrap sandbox
# with a private /tmp.

# Typical invocation:
#  /tmp/gnome-desktop-file-to-thumbnail.ARW
#  /tmp/gnome-desktop-thumbnailer.png
#  256

# Debug using:
# G_MESSAGES_DEBUG=GnomeDesktop nautilus
# Refresh issues:
# G_MESSAGES_DEBUG=all nautilus

src="${1:-}"
out="${2:-}"
size="${3:-256}"

# validate parameters
if [[ -z "$src" ]] || [[ -z "$out" ]] || [[ ! -f "$src" ]] || [[ -e "$out" ]]; then
  echo "Usage: $0 <input> <output> [size]" >&2
  exit 1
fi

# secure tmp files
umask 077

# create new tmp dir on ramdisk and clean up afterwards
tmpdir="$(mktemp -d /dev/shm/exiv2-thumbnailer.XXXXXX)"
trap 'rm -rf -- "$tmpdir"' EXIT

# extract preview image to tmp dir
exiv2 -l "$tmpdir" --extract p1 "$src"

name="$(basename "$src")"
preview="${tmpdir}/${name%.*}-preview1.jpg"
tfuzz=5

if [[ ! -f "$preview" ]]; then
  # tiff used by dng
  preview="${preview%.*}.tif"
  tfuzz=0
fi

if [[ -f "$preview" ]]; then
  # keep orientation
  val=$(exiv2 -g "Exif.Thumbnail.Orientation" -Pv "$src" || true)
  [[ -n "$val" ]] && exiv2 -M "set Exif.Image.Orientation ${val}" "$preview"
else
  echo "WARN: No embedded thumbnail found in '$src'" >&2
  # slow attempt: try to directly read source file
  preview="$src"
fi

# rotate and downscale preview image
# WARN: Removing -strip could cause thumbnail generation loop
magick "$preview" \
  -auto-orient \
  -fuzz "${tfuzz}%" -trim +repage \
  -thumbnail "${size}x${size}>" \
  -strip \
  "png:$out"
