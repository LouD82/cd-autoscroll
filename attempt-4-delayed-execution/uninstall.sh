#!/bin/bash

# Claude Desktop Auto-Scroll Fix Uninstaller
# This script restores the original Claude Desktop app.asar file

# Exit on any error
set -e

echo "Claude Desktop Auto-Scroll Fix Uninstaller (Delayed Execution Approach)"
echo "----------------------------------------------------------------"

# Get the base directory for all attempts
BASE_DIR="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"

# Check if backup directory exists
BACKUP_DIR="$BASE_DIR/backup"
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Backup directory not found at $BACKUP_DIR"
    exit 1
fi

# Try to find the original backup file first
ORIGINAL_BACKUP="$BACKUP_DIR/app.asar.original.backup"

if [ -f "$ORIGINAL_BACKUP" ]; then
    echo "Restoring from original backup: $ORIGINAL_BACKUP"
    cp "$ORIGINAL_BACKUP" "/Applications/Claude.app/Contents/Resources/app.asar"
else
    # If no original backup exists, find the most recent backup
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/app.asar.*.backup 2>/dev/null | head -1)

    if [ -z "$LATEST_BACKUP" ]; then
        echo "Error: No backup files found in $BACKUP_DIR"
        echo "Cannot restore the original app.asar."
        exit 1
    fi

    echo "Restoring from most recent backup: $LATEST_BACKUP"
    cp "$LATEST_BACKUP" "/Applications/Claude.app/Contents/Resources/app.asar"
fi

echo ""
echo "✅ Auto-scroll fix successfully uninstalled!"
echo "Original app.asar file has been restored."
echo ""
echo "Please restart Claude Desktop for the changes to take effect."
echo ""