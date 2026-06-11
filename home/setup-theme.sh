#!/usr/bin/env bash
set -o pipefail

git clone git@github.com:vinceliuice/Colloid-icon-theme.git /tmp/icon-theme
cd /tmp/icon-theme &&  ./install.sh --bold --scheme gruvbox

git clone https://github.com/vdawg-git/Colloid-gtk-theme /tmp/gtk-theme
git switch transparency
cd /tmp/gtk-theme && ./install.sh --theme orange --libadwaita --tweaks gruvbox rimless black --color dark


