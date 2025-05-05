# Claude Desktop Auto-Scroll Fix (Improved Version)

This tool fixes the auto-scrolling issue in the Claude Desktop application, where the app doesn't automatically scroll to the bottom when new content appears during conversations.

## Features

- **Automatic Scrolling:** The chat window will automatically scroll to the bottom when new content appears.
- **Toggle Control:** Press `Ctrl+Space` to toggle auto-scrolling on/off.
- **Visual Indicator:** A small indicator in the bottom-right corner shows the auto-scroll status.
- **Persistent Fix:** Works across all conversations and persists after app restarts.
- **Crash-Free:** Uses a more robust approach to prevent application crashes.

## Installation

### Quick Install

1. Open Terminal (Applications → Utilities → Terminal)
2. Run the installer script:

```bash
cd ~/claude-autoscroll-fix
./updated-installer.sh
```

3. Restart Claude Desktop for the changes to take effect.

## How It Works

The improved auto-scroll fix works by:

1. Extracting the Claude Desktop app.asar file
2. Adding a script to the main window HTML file that loads AFTER the application is fully initialized
3. Using multiple initialization strategies to ensure the script runs at the right time
4. Including comprehensive error handling to prevent crashes
5. Creating a visual indicator for auto-scroll status
6. Repacking the modified ASAR file and installing it

The script is designed to be highly resilient, with multiple fallback mechanisms:

- It waits for the DOM to be fully loaded
- It delays initialization to ensure the application UI is ready
- It retries finding the chat container if not immediately available
- It includes error handling around all critical operations

## Usage Instructions

- The auto-scroll feature is enabled by default after installation
- Use `Ctrl+Space` to toggle auto-scrolling on/off at any time
- A small indicator in the bottom-right corner shows the current status:
  - "📜 Auto-scroll active" - Automatically scrolls to show new messages
  - "📜 Auto-scroll paused" - No automatic scrolling, manual scrolling required
- You can also click the indicator to toggle the auto-scroll state

## After Claude Desktop Updates

When Claude Desktop updates, you'll need to reapply the fix:

```bash
cd ~/claude-autoscroll-fix
./updated-installer.sh
```

## Uninstallation

If you want to remove the auto-scroll fix:

```bash
cd ~/claude-autoscroll-fix
./updated-uninstaller.sh
```

Then restart Claude Desktop.

## Troubleshooting

If you encounter any issues:

1. Check the Console for error messages (View > Developer > Toggle Developer Tools)
2. Make sure Claude Desktop is fully restarted after installation
3. Try uninstalling and reinstalling the fix
4. If problems persist, restore from the backup:
   ```bash
   cd ~/claude-autoscroll-fix/backup
   cp app.asar.[timestamp].backup /Applications/Claude.app/Contents/Resources/app.asar
   ```

## Files and Directories

- `~/claude-autoscroll-fix/updated-installer.sh` - The improved installer script
- `~/claude-autoscroll-fix/updated-uninstaller.sh` - The improved uninstaller script
- `~/claude-autoscroll-fix/backup/` - Backup files of the original app.asar
- `~/claude-autoscroll-fix/extracted-fixed/` - Extracted app files with modifications
- `~/claude-autoscroll-fix/app-fixed.asar` - Modified app archive

## Technical Notes

This implementation uses a delayed script injection approach which:

1. Waits for the window's load event to complete
2. Creates a script element with our auto-scroll code
3. Attaches the script element to the document body
4. Uses multiple initialization checks for maximum reliability

The script itself uses multiple approaches to find the chat container:

1. First tries common CSS selectors for chat containers
2. Falls back to finding the tallest scrollable element
3. Retries periodically if no suitable container is found

This implementation is much more robust against crashes and should work reliably across application restarts and updates.
