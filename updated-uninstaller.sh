#!/bin/bash

# Claude Desktop Auto-Scroll Fix Uninstaller (Improved Version)
# This script restores the original Claude Desktop app.asar file

# Exit on any error
set -e

echo "Claude Desktop Auto-Scroll Fix Uninstaller (Improved Version)"
echo "--------------------------------------------------------"

# Check if backup directory exists
BACKUP_DIR="$HOME/claude-autoscroll-fix/backup"
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Backup directory not found at $BACKUP_DIR"
    exit 1
fi

# Find the most recent backup file
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/app.asar.*.backup 2>/dev/null | head -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "Error: No backup files found in $BACKUP_DIR"
    echo "Cannot restore the original app.asar."
    exit 1
fi

# Restore the most recent backup
echo "Restoring from backup: $LATEST_BACKUP"
cp "$LATEST_BACKUP" "/Applications/Claude.app/Contents/Resources/app.asar"

echo ""
echo "✅ Auto-scroll fix successfully uninstalled!"
echo "Original app.asar file has been restored."
echo ""
echo "Please restart Claude Desktop for the changes to take effect."
echo ""
