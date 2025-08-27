#!/usr/bin/env bash

# === CONFIG ===
# Those dirs get created by dotbot automatically
declare -A SYNC_DIRS=(
    ["/home/vdawg/Documents/obsidian"]="/obsidian"
    ["/home/vdawg/Documents/sync"]="/documents"
    ["/home/vdawg/Documents/obsidian"]="/obsidian"
    ["/home/vdawg/Music"]="/music"
    ["/home/vdawg/Pictures/memes"]="/memes"
    ["/home/vdawg/z_bearbeiten"]="/z_bearbeiten"
)

# === SCRIPT ===

# Prompt for credentials
read -p "Enter MEGA username (email): " MEGA_USER
read -s -p "Enter MEGA password: " MEGA_PASS
echo ""

# Logout just in case
# mega-logout >/dev/null 2>&1

# Login
mega-login "$MEGA_USER" "$MEGA_PASS"
if [ $? -ne 0 ]; then
    echo "❌ Login failed! Check credentials."
    exit 1
fi
echo "✅ Logged in successfully."

# Setup syncs
for LOCAL_DIR in "${!SYNC_DIRS[@]}"; do
    REMOTE_DIR="${SYNC_DIRS[$LOCAL_DIR]}"

    echo "🔄 Setting up sync: $LOCAL_DIR → $REMOTE_DIR"
    mega-sync "$LOCAL_DIR" "$REMOTE_DIR"
    if [ $? -eq 0 ]; then
        echo "✨ Sync added successfully for $LOCAL_DIR"
    else
        echo "⚠️ Failed to add sync for $LOCAL_DIR."
    fi
done

echo "🎉 All syncs configured! Run 'mega-sync' to view them."
