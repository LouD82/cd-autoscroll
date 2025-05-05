# Claude Desktop Auto-Scroll Fix (Minimal Approach)

This is an incremental approach to fixing the auto-scrolling issue in Claude Desktop while avoiding application crashes.

## Background

Previous attempts to implement an auto-scroll fix resulted in Claude Desktop crashing on startup. Analysis of the crash reports suggests that our JavaScript is being executed too early or is interfering with the application's initialization process.

## Strategy

This implementation takes a much more conservative, incremental approach:

1. **Phase 1**: Minimal script that only logs a message without any DOM manipulation
2. **Phase 2**: Adds basic DOM inspection without modifying anything
3. **Phase 3**: Attempts to identify the chat container but still no observers or DOM modifications
4. **Full Implementation**: Only after confirming the above phases work, we'll implement the full auto-scroll functionality

## Installation

Each phase has its own installer script. Start with Phase 1 and only proceed to the next phase if the previous one works without crashing.

### Phase 1 (Basic Logging)

```bash
cd ~/Dropbox/FCPS/Dev/claude-autoscroll-fix/attempt-3-minimal-fix
./minimal-installer-phase1.sh
```

### Phase 2 (DOM Inspection)

```bash
cd ~/Dropbox/FCPS/Dev/claude-autoscroll-fix/attempt-3-minimal-fix
./minimal-installer-phase2.sh
```

### Phase 3 (Container Identification)

```bash
cd ~/Dropbox/FCPS/Dev/claude-autoscroll-fix/attempt-3-minimal-fix
./minimal-installer-phase3.sh
```

## Uninstallation

To restore the original app.asar file:

```bash
cd ~/Dropbox/FCPS/Dev/claude-autoscroll-fix/attempt-3-minimal-fix
./minimal-uninstaller.sh
```

## Testing

After installing each phase:

1. Restart Claude Desktop completely
2. Open the developer console (View > Developer > Toggle Developer Tools)
3. Look for the expected log messages
4. Check that the application works normally without crashing

## Key Differences from Previous Attempts

1. **Delayed Initialization**: Uses multiple delay techniques to ensure the app is fully loaded
2. **External Script**: Uses a separate JS file instead of inline JavaScript to avoid CSP issues
3. **Incremental Approach**: Adds functionality step by step to identify problematic code
4. **Defensive Coding**: Uses try/catch blocks and extensive error handling
5. **No Initial DOM Modification**: Early phases don't modify the DOM or add observers

## Next Steps

Once we identify which components can run safely, we'll implement a full auto-scroll fix that includes:

1. Auto-scrolling functionality
2. Toggle control (Ctrl+Space)
3. Visual indicator
4. Persistence across app restarts
