# Claude Desktop Auto-Scroll Fix Project

This project aims to fix the auto-scrolling issue in Claude Desktop where the app fails to automatically scroll to the bottom when new content appears during conversations.

## Project Organization

The project is organized into three distinct attempts at solving the auto-scroll issue:

1. **attempt-1-original**: The first implementation that caused Claude Desktop to crash on startup
   - Uses direct script injection in the HTML head
   - Implements basic auto-scroll functionality with toggle controls

2. **attempt-2-improved**: An improved version that also caused crashes
   - Uses a delayed script injection approach
   - Includes multiple fallback mechanisms for finding the chat container
   - Has comprehensive error handling

3. **attempt-3-minimal-fix**: A new incremental approach to avoid crashes
   - Starts with minimal functionality (just logging)
   - Gradually adds features to identify what causes crashes
   - Uses external script files instead of inline JavaScript
   - Implements strict timing controls and defensive coding practices

## Development Status

We're currently testing the minimal-fix approach to identify what causes Claude Desktop to crash and develop a solution that works reliably without crashing the application.

## Usage

Each attempt folder contains its own installer scripts and documentation. Please refer to the README.md file in each attempt folder for specific instructions.

For the latest approach, see the documentation in the `attempt-3-minimal-fix` folder.
