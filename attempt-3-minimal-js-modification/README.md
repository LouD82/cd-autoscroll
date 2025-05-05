# Claude Desktop Auto-Scroll Fix (Minimal JS Modification)

This implementation takes a more conservative approach to fixing the auto-scrolling issue in Claude Desktop, using minimal JavaScript modifications to avoid application crashes.

## Key Differences from Previous Attempts

This implementation:

1. **Modifies JS instead of HTML**: Instead of injecting scripts into HTML files, this approach appends code to an existing JavaScript file
2. **Minimizes Application Interference**: Uses a less invasive approach to avoid disrupting Electron's initialization process
3. **Implements Defensive Coding**: Uses extensive error handling to prevent crashes
4. **Delayed Initialization**: Ensures that auto-scroll code runs only after the application is fully initialized
5. **Graceful Failure**: If anything goes wrong, the code fails gracefully without crashing the application

## Features

- **Automatic Scrolling**: Chat window automatically scrolls to show new messages
- **Toggle Control**: Press `Ctrl+Space` to toggle auto-scrolling on/off
- **Visual Indicator**: Shows current auto-scroll status in the bottom-right corner
- **Crash-Free Operation**: Designed to work without causing application crashes

## Installation

### Quick Install

1. Open Terminal
2. Run the installer script:

```bash
cd ~/Dropbox/FCPS/Dev/claude-autoscroll-fix
cd attempt-3-minimal-js-modification
./install.sh
```

3. Restart Claude Desktop for the changes to take effect

## How It Works

This implementation:

1. Extracts the Claude Desktop app.asar file
2. Identifies a key application JavaScript file that loads after the UI is established
3. Appends our auto-scroll code to that file with comprehensive error handling
4. Repacks the modified asar file and installs it

The auto-scroll code is completely self-contained and uses multiple initialization strategies to ensure it runs at the right time without interfering with the application's normal operation.

## Uninstallation

To remove the auto-scroll fix:

```bash
cd ~/Dropbox/FCPS/Dev/claude-autoscroll-fix
cd attempt-3-minimal-js-modification
./uninstall.sh
```

Then restart Claude Desktop.

## Technical Notes

This implementation takes advantage of Electron's module system by adding our code to an existing JavaScript file that's loaded after the application UI is established. This approach is much less likely to cause crashes because:

1. It doesn't modify the HTML structure or interfere with initial page loading
2. It works within the app's existing JavaScript environment
3. It initializes only after the application is fully loaded
4. It includes comprehensive error handling to prevent crashes

All code is contained within an immediately-invoked function expression (IIFE) with multiple defensive layers to ensure it can't crash the main application.