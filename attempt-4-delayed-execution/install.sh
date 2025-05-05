#!/bin/bash

# Claude Desktop Auto-Scroll Fix Installer (Delayed Execution Approach)
# This script patches the Claude Desktop app with an extremely minimal
# auto-scrolling solution that delays execution until the app is fully loaded

# Exit on any error
set -e

echo "Claude Desktop Auto-Scroll Fix Installer (Delayed Execution Approach)"
echo "----------------------------------------------------------------"

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

# Look for index.js in main browser window code
echo "Looking for main renderer process JavaScript file..."

# This file should be one of the last to execute, so it's a good place for our code
RENDERER_INDEX="$ATTEMPT_DIR/extracted/.vite/renderer/main_window/index.js"

if [ ! -f "$RENDERER_INDEX" ]; then
    echo "Main renderer index.js not found at expected location."
    echo "Looking for alternative main entry point..."
    
    # Try to find other main entry points
    POTENTIAL_FILES=(
        "$ATTEMPT_DIR/extracted/.vite/renderer/main_window/main.js"
        "$ATTEMPT_DIR/extracted/.vite/renderer/main_window/assets/index.js"
        "$ATTEMPT_DIR/extracted/.vite/renderer/main_window/assets/main.js"
    )
    
    for file in "${POTENTIAL_FILES[@]}"; do
        if [ -f "$file" ]; then
            RENDERER_INDEX="$file"
            break
        fi
    done
    
    # If still not found, look for any JS file in the main_window directory
    if [ ! -f "$RENDERER_INDEX" ]; then
        echo "Searching for any JavaScript file in main_window directory..."
        LAST_JS=$(find "$ATTEMPT_DIR/extracted/.vite/renderer/main_window" -name "*.js" | sort | tail -1)
        
        if [ -n "$LAST_JS" ]; then
            RENDERER_INDEX="$LAST_JS"
        else
            echo "Error: Could not find a suitable JavaScript file to modify."
            exit 1
        fi
    fi
fi

echo "Found JavaScript file to modify: $RENDERER_INDEX"

# Get the auto-scroll code
AUTO_SCROLL_CODE=$(cat "$ATTEMPT_DIR/delayed-auto-scroll.js")

# Append our code to the end of the file
echo "Appending auto-scroll code..."
echo -e "\n\n// Auto-scroll fix (Delayed Execution Approach)\n$AUTO_SCROLL_CODE" >> "$RENDERER_INDEX"

# Pack the modified files back into app.asar
echo "Packing modified files back into app.asar..."
npx asar pack "$ATTEMPT_DIR/extracted" "$ATTEMPT_DIR/app-fixed.asar"

# Replace the original app.asar file
echo "Installing modified app.asar..."
cp "$ATTEMPT_DIR/app-fixed.asar" "/Applications/Claude.app/Contents/Resources/app.asar"

echo ""
echo "✅ Auto-scroll fix successfully installed!"
echo ""
echo "This is an extremely minimal implementation that:"
echo "- Waits 10 seconds after the app loads before activating"
echo "- Only implements basic auto-scrolling functionality"
echo "- Does not include any toggle controls or visual indicators"
echo "- Uses minimal code to avoid crashes"
echo ""
echo "Please restart Claude Desktop for the changes to take effect."
echo "To uninstall, run the uninstall.sh script or restore from a backup in: $BASE_DIR/backup/"
echo ""