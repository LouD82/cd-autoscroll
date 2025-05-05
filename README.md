# Claude Desktop Auto-Scroll Fix

This tool fixes the auto-scrolling issue in the Claude Desktop application, where the app doesn't automatically scroll to the bottom when new content appears during conversations.

## Features

- **Automatic Scrolling:** The chat window will automatically scroll to the bottom when new content appears.
- **Toggle Control:** Press `Ctrl+Space` to toggle auto-scrolling on/off.
- **Visual Indicator:** A small indicator in the bottom-right corner shows the auto-scroll status.
- **Persistent Fix:** Works across all conversations and persists after app restarts.

## Installation

### Quick Install

1. Open Terminal (Applications → Utilities → Terminal)
2. Run the installer script:

```bash
cd ~/claude-autoscroll-fix
./install-autoscroll-fix.sh
```

3. Restart Claude Desktop for the changes to take effect.

### Manual Installation

If you prefer to install the fix manually:

1. Backup the original app.asar file:
   ```bash
   cp /Applications/Claude.app/Contents/Resources/app.asar ~/claude-autoscroll-fix/backup/app.asar.backup
   ```

2. Extract the app.asar file:
   ```bash
   cd ~/claude-autoscroll-fix
   npx asar extract /Applications/Claude.app/Contents/Resources/app.asar ./extracted
   ```

3. Create the auto-scroll directory and script:
   ```bash
   mkdir -p ./extracted/auto-scroll
   # Copy the auto-scroll.js file to ./extracted/auto-scroll/
   ```

4. Modify the main window HTML file:
   ```bash
   # Add a script reference to the HTML file's head section
   # <script src="../../auto-scroll/auto-scroll.js"></script>
   ```

5. Repack the asar file:
   ```bash
   npx asar pack ./extracted app.asar
   ```

6. Replace the original asar file:
   ```bash
   cp app.asar /Applications/Claude.app/Contents/Resources/app.asar
   ```

7. Restart Claude Desktop.

## How to Use

- The auto-scroll feature is enabled by default after installation.
- Press `Ctrl+Space` to toggle auto-scrolling on/off at any time.
- A small indicator will appear in the bottom-right corner showing the current status.
- The indicator will fade after 5 seconds to be less intrusive.

## After Claude Desktop Updates

When Claude Desktop updates, you'll need to reapply the fix:

1. Run the installer script again:
   ```bash
   cd ~/claude-autoscroll-fix
   ./install-autoscroll-fix.sh
   ```

## Uninstallation

To remove the auto-scroll fix:

1. Restore the original app.asar file:
   ```bash
   cp ~/claude-autoscroll-fix/backup/app.asar.backup /Applications/Claude.app/Contents/Resources/app.asar
   ```

2. Restart Claude Desktop.

## How It Works

The fix injects a JavaScript file into the main window of the Claude Desktop application. This script:

1. Identifies the scrollable chat container
2. Uses a MutationObserver to detect when new content is added
3. Automatically scrolls to the bottom when appropriate
4. Provides keyboard shortcuts for controlling the behavior

## Troubleshooting

If the fix doesn't work after installation:

1. Make sure you've restarted Claude Desktop completely.
2. Check that the installer completed without errors.
3. If Claude Desktop updates, you'll need to reapply the fix.

## Credits

This fix was developed to address the auto-scrolling issue in Claude Desktop that forces users to manually scroll down to see new content during conversations.
