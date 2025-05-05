#!/bin/bash

# Claude Desktop Auto-Scroll Fix Installer (Minimal Version - Phase 3)
# This script automatically patches the Claude Desktop app with a minimal auto-scrolling fix

# Exit on any error
set -e

echo "Claude Desktop Auto-Scroll Fix Installer (Minimal Version - Phase 3)"
echo "--------------------------------------------------------"

# Check if Claude Desktop is installed
if [ ! -d "/Applications/Claude.app" ]; then
    echo "Error: Claude Desktop app not found in /Applications folder."
    echo "Please make sure Claude Desktop is installed before running this script."
    exit 1
fi

# Create required directories
BASE_DIR="$HOME/Dropbox/FCPS/Dev/claude-autoscroll-fix"
mkdir -p "$BASE_DIR/backup"
mkdir -p "$BASE_DIR/attempt-3-minimal-fix/extracted"

# Backup original app.asar file
echo "Creating backup of original app.asar file..."
cp "/Applications/Claude.app/Contents/Resources/app.asar" "$BASE_DIR/backup/app.asar.$(date +%Y%m%d%H%M%S).backup"

# Extract app.asar
echo "Extracting app.asar file..."
npx asar extract "/Applications/Claude.app/Contents/Resources/app.asar" "$BASE_DIR/attempt-3-minimal-fix/extracted"

# Copy minimal autoscroll file to the extracted directory
echo "Copying phase 3 auto-scroll script..."
cp "$BASE_DIR/attempt-3-minimal-fix/minimal-autoscroll-phase3.js" "$BASE_DIR/attempt-3-minimal-fix/extracted/minimal-autoscroll.js"

# Find the main window HTML file
MAIN_WINDOW_INDEX="$BASE_DIR/attempt-3-minimal-fix/extracted/.vite/renderer/main_window/index.html"

# Check if the file exists
if [ ! -f "$MAIN_WINDOW_INDEX" ]; then
    echo "Error: Could not find main window HTML file at $MAIN_WINDOW_INDEX"
    echo "The structure of the Claude Desktop app may have changed."
    exit 1
fi

# Add a reference to this minimal script in the HTML
echo "Adding script reference to HTML..."
sed -i '' 's#</head>#<script src="../../../minimal-autoscroll.js" defer></script></head>#' "$MAIN_WINDOW_INDEX"

# Pack modified files back into app.asar
echo "Packing modified files back into app.asar..."
npx asar pack "$BASE_DIR/attempt-3-minimal-fix/extracted" "$BASE_DIR/attempt-3-minimal-fix/app-minimal.asar"

# Replace original app.asar with the modified one
echo "Installing modified app.asar..."
cp "$BASE_DIR/attempt-3-minimal-fix/app-minimal.asar" "/Applications/Claude.app/Contents/Resources/app.asar"

echo ""
echo "✅ Minimal auto-scroll fix (Phase 3) successfully installed!"
echo ""
echo "This version identifies potential chat containers but doesn't add observers or modify the DOM."
echo "To check if it works:"
echo "1. Restart Claude Desktop"
echo "2. Open the developer console (View > Developer > Toggle Developer Tools)"
echo "3. Look for messages about finding a potential chat container"
echo ""
echo "If this works without crashing, we can proceed to implementing full functionality."
echo "To restore from backup, run the uninstaller script."
echo ""
