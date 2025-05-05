#!/bin/bash

# Claude Desktop Auto-Scroll Fix Installer (Minimal JS Modification Approach)
# This script patches the Claude Desktop app to add auto-scrolling functionality
# by modifying an existing JavaScript file instead of the HTML structure

# Exit on any error
set -e

echo "Claude Desktop Auto-Scroll Fix Installer (Minimal JS Modification)"
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

# Look for a suitable JS file to modify
echo "Looking for suitable JavaScript file to modify..."

# First, try to find main renderer process file
RENDERER_DIR="$ATTEMPT_DIR/extracted/.vite/renderer"
MAIN_JS=""

# Look for main.js in various potential locations
POTENTIAL_MAIN_JS_FILES=(
    "$RENDERER_DIR/main_window/assets/index.js"
    "$RENDERER_DIR/main_window/assets/main.js"
    "$RENDERER_DIR/main_window/assets/app.js"
    "$RENDERER_DIR/assets/index.js"
    "$RENDERER_DIR/assets/main.js"
)

for file in "${POTENTIAL_MAIN_JS_FILES[@]}"; do
    if [ -f "$file" ]; then
        MAIN_JS="$file"
        break
    fi
done

# If no main.js found, look for the largest JS file in the assets directory
if [ -z "$MAIN_JS" ]; then
    echo "Main JavaScript file not found in expected locations."
    echo "Looking for the largest JavaScript file instead..."
    
    # Find all .js files in the extracted directory
    JS_FILES=$(find "$ATTEMPT_DIR/extracted" -name "*.js" | grep -v "node_modules")
    
    # Find the largest one that's likely to be a renderer process file
    # (skip tiny files and files in node_modules)
    LARGEST_JS=$(find "$ATTEMPT_DIR/extracted" -name "*.js" -size +50k | grep -v "node_modules" | sort -rn -k 5 | head -1)
    
    if [ -n "$LARGEST_JS" ]; then
        MAIN_JS="$LARGEST_JS"
    else
        echo "Error: Could not find a suitable JavaScript file to modify."
        exit 1
    fi
fi

echo "Found JavaScript file to modify: $MAIN_JS"

# Create the auto-scroll script content
AUTO_SCROLL_SCRIPT=$(cat "$ATTEMPT_DIR/auto-scroll.js")

# Append the auto-scroll script to the main JavaScript file
echo "Appending auto-scroll code to JavaScript file..."
echo -e "\n\n// Auto-scroll fix for Claude Desktop - Added by installer\n$AUTO_SCROLL_SCRIPT" >> "$MAIN_JS"

# Pack modified files back into app.asar
echo "Packing modified files back into app.asar..."
npx asar pack "$ATTEMPT_DIR/extracted" "$ATTEMPT_DIR/app-fixed.asar"

# Replace original app.asar with the modified one
echo "Installing modified app.asar..."
cp "$ATTEMPT_DIR/app-fixed.asar" "/Applications/Claude.app/Contents/Resources/app.asar"

echo ""
echo "✅ Auto-scroll fix successfully installed!"
echo ""
echo "Features:"
echo "- Chat window will automatically scroll to the bottom when new content appears"
echo "- Press Ctrl+Space to toggle auto-scrolling on/off"
echo "- A small indicator will appear in the bottom-right corner showing the auto-scroll status"
echo ""
echo "Note: You'll need to restart Claude Desktop for the changes to take effect."
echo "To uninstall, run the uninstall.sh script or restore from a backup in: $BASE_DIR/backup/"
echo ""