#!/usr/bin/env bash
set -euo pipefail

settings_file="${ACTIVITYWATCH_CATEGORY_SETTINGS:-$HOME/.config/activitywatch/category-settings.json}"
server_url="${ACTIVITYWATCH_SERVER_URL:-http://127.0.0.1:5600}"

if [[ ! -f "$settings_file" ]]; then
  echo "ActivityWatch category settings file not found: $settings_file" >&2
  exit 1
fi

python3 -m json.tool "$settings_file" >/dev/null

curl --fail --silent --show-error \
  --request POST \
  --header 'Content-Type: application/json' \
  --data-binary "@$settings_file" \
  "$server_url/api/0/settings/classes" >/dev/null

echo "Imported ActivityWatch category settings from $settings_file"
