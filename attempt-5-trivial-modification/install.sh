#!/bin/bash

# Claude Desktop Trivial Modification Test
# This script makes the most minimal possible change to the app.asar file
# to test if any modification at all causes the app to crash

# Exit on any error
set -e

echo "Claude Desktop Trivial Modification Test"
echo "----------------------------------------"

# Check if Claude Desktop is installed
if [ ! -d "/Applications/Claude.app" ]; then
    echo "Error: Claude Desktop app not found in /Applications folder."
    echo "Please make sure Claude Desktop is installed before running this script."
    exit 1
fi

# Create required directories
BASE_DIR="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"
ATTEMPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$BASE_DIR/backup"
mkdir -p "$ATTEMPT_DIR/extracted"

# Backup original app.asar file if no backup exists yet
if [ ! -f "$BASE_DIR/backup/app.asar.original.backup" ]; then
    echo "Creating backup of original app.asar file..."
    cp "/Applications/Claude.app/Contents/Resources/app.asar" "$BASE_DIR/backup/app.asar.original.backup"
fi

# Also create a timestamped backup
echo "Creating timestamped backup of current app.asar file..."
cp "/Applications/Claude.app/Contents/Resources/app.asar" "$BASE_DIR/backup/app.asar.$(date +%Y%m%d%H%M%S).backup"

# Extract app.asar
echo "Extracting app.asar file..."
npx asar extract "/Applications/Claude.app/Contents/Resources/app.asar" "$ATTEMPT_DIR/extracted"

# Find the first JavaScript file to make a trivial modification
echo "Looking for JavaScript file to modify..."
FIRST_JS=$(find "$ATTEMPT_DIR/extracted" -name "*.js" | head -1)

if [ -z "$FIRST_JS" ]; then
    echo "Error: Could not find any JavaScript files."
    exit 1
fi

echo "Found JavaScript file to modify: $FIRST_JS"

# Make a trivial modification - add a single-line comment
echo "Making trivial modification..."
echo "// This is a trivial comment added to test ASAR modification" >> "$FIRST_JS"

# Pack the modified files back into app.asar
echo "Packing modified files back into app.asar..."
npx asar pack "$ATTEMPT_DIR/extracted" "$ATTEMPT_DIR/app-fixed.asar"

# Replace the original app.asar file
echo "Installing modified app.asar..."
cp "$ATTEMPT_DIR/app-fixed.asar" "/Applications/Claude.app/Contents/Resources/app.asar"

echo ""
echo "✅ Trivial modification has been applied!"
echo ""
echo "This modification makes the smallest possible change to the app.asar file:"
echo "- Added a single comment line to a JavaScript file"
echo "- No functional changes made"
echo "- No auto-scroll functionality added"
echo ""
echo "Please restart Claude Desktop to see if it launches without crashing."
echo "If it still crashes, this would indicate that any modification to the app.asar file"
echo "causes the app to crash, possibly due to integrity checks."
echo ""
echo "To uninstall, run the uninstall.sh script or restore from a backup in: $BASE_DIR/backup/"
echo ""