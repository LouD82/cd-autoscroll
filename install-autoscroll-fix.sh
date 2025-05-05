#!/bin/bash

# Claude Desktop Auto-Scroll Fix Installer
# This script automatically patches the Claude Desktop app to add auto-scrolling functionality

# Exit on any error
set -e

echo "Claude Desktop Auto-Scroll Fix Installer"
echo "---------------------------------------"

# Check if Claude Desktop is installed
if [ ! -d "/Applications/Claude.app" ]; then
    echo "Error: Claude Desktop app not found in /Applications folder."
    echo "Please make sure Claude Desktop is installed before running this script."
    exit 1
fi

# Create required directories
BASE_DIR="$HOME/claude-autoscroll-fix"
mkdir -p "$BASE_DIR/backup"
mkdir -p "$BASE_DIR/extracted"
mkdir -p "$BASE_DIR/extracted/auto-scroll"

# Create auto-scroll.js file
echo "Creating auto-scroll script..."
cat > "$BASE_DIR/extracted/auto-scroll/auto-scroll.js" << 'EOL'
// Auto-scroll fix for Claude desktop app
(function() {
  // Configuration
  const debug = false;  // Set to true to see debug messages in console
  const scrollThreshold = 100;  // Distance from bottom to consider "at bottom" (in pixels)
  
  // Find the main chat container
  const findChatContainer = () => {
    // Common selectors for chat containers in Electron apps
    const possibleSelectors = [
      '.message-list-container', 
      '.conversation-container', 
      '.chat-messages',
      'main', 
      '[role="main"]',
      // More generic fallbacks
      'div[style*="overflow"][style*="scroll"]',
      'div[style*="overflow: auto"]',
      'div[style*="overflow-y: auto"]'
    ];
    
    for (const selector of possibleSelectors) {
      const elements = document.querySelectorAll(selector);
      for (const el of elements) {
        // Check if this element is a scrollable container with content
        if (
          el.scrollHeight > el.clientHeight && 
          el.clientHeight > 100 && // Reasonable minimum height
          el.querySelector('div, p') // Contains child elements
        ) {
          if (debug) console.log('Found chat container:', el);
          return el;
        }
      }
    }
    
    // Last resort: find the tallest scrollable element
    let tallestElement = null;
    let maxHeight = 0;
    
    document.querySelectorAll('div').forEach(div => {
      const style = window.getComputedStyle(div);
      if (
        (style.overflowY === 'auto' || style.overflowY === 'scroll') &&
        div.scrollHeight > div.clientHeight &&
        div.clientHeight > maxHeight
      ) {
        maxHeight = div.clientHeight;
        tallestElement = div;
      }
    });
    
    if (tallestElement && debug) console.log('Found container by height:', tallestElement);
    return tallestElement;
  };
  
  const initAutoScroll = () => {
    const chatContainer = findChatContainer();
    if (!chatContainer) {
      console.error('Could not find chat container. Scroll fix not applied.');
      // Try again in 500ms
      setTimeout(initAutoScroll, 500);
      return;
    }
    
    // Store state about scroll position
    let isNearBottom = true;
    let isAutoScrollPaused = false;
    let lastScrollHeight = chatContainer.scrollHeight;
    
    // Check if user is near bottom
    const checkIfNearBottom = () => {
      const scrollPosition = chatContainer.scrollHeight - chatContainer.scrollTop - chatContainer.clientHeight;
      return scrollPosition < scrollThreshold;
    };
    
    // Update auto-scroll state based on user scrolling
    chatContainer.addEventListener('scroll', () => {
      isNearBottom = checkIfNearBottom();
      if (debug) console.log('Scroll detected, near bottom:', isNearBottom);
    });
    
    // Create and add a mutation observer to catch content changes
    const observer = new MutationObserver((mutations) => {
      // Only process if content has actually been added
      if (chatContainer.scrollHeight > lastScrollHeight) {
        if (debug) console.log('Content added, auto-scroll needed:', isNearBottom, 'height change:', chatContainer.scrollHeight - lastScrollHeight);
        
        if (isNearBottom && !isAutoScrollPaused) {
          // Use requestAnimationFrame for smoother scrolling
          requestAnimationFrame(() => {
            chatContainer.scrollTop = chatContainer.scrollHeight;
            if (debug) console.log('Scrolled to bottom');
          });
        }
        
        lastScrollHeight = chatContainer.scrollHeight;
      }
    });
    
    // Start observing with a configuration that watches for content changes
    observer.observe(chatContainer, {
      childList: true,
      subtree: true,
      characterData: true
    });
    
    // Add a key listener to pause/resume auto-scrolling (Ctrl+Space)
    document.addEventListener('keydown', (e) => {
      if (e.ctrlKey && e.code === 'Space') {
        isAutoScrollPaused = !isAutoScrollPaused;
        console.log(`Auto-scrolling is now ${isAutoScrollPaused ? 'paused' : 'enabled'}`);
        
        // If unpausing and near bottom, scroll to bottom immediately
        if (!isAutoScrollPaused && isNearBottom) {
          chatContainer.scrollTop = chatContainer.scrollHeight;
        }
        
        e.preventDefault();
      }
    });
    
    // Provide a small visual indicator that the script is active
    console.log('Claude auto-scroll fix activated. Use Ctrl+Space to toggle auto-scrolling.');
    
    // Create a small floating indicator in the corner
    const indicator = document.createElement('div');
    indicator.style.cssText = `
      position: fixed;
      bottom: 10px;
      right: 10px;
      background: rgba(0, 0, 0, 0.7);
      color: white;
      padding: 5px 10px;
      border-radius: 5px;
      font-size: 12px;
      z-index: 9999;
      opacity: 0.7;
      transition: opacity 0.3s;
    `;
    indicator.textContent = '📜 Auto-scroll active';
    indicator.title = 'Press Ctrl+Space to toggle auto-scrolling';
    
    // Make it less noticeable after a moment
    indicator.addEventListener('mouseover', () => {
      indicator.style.opacity = '1';
    });
    indicator.addEventListener('mouseout', () => {
      indicator.style.opacity = '0.7';
    });
    
    // Add click to toggle functionality
    indicator.addEventListener('click', () => {
      isAutoScrollPaused = !isAutoScrollPaused;
      indicator.textContent = isAutoScrollPaused ? '📜 Auto-scroll paused' : '📜 Auto-scroll active';
      
      // If unpausing and near bottom, scroll to bottom immediately
      if (!isAutoScrollPaused && isNearBottom) {
        chatContainer.scrollTop = chatContainer.scrollHeight;
      }
    });
    
    // Remove after 5 seconds to not be intrusive
    document.body.appendChild(indicator);
    setTimeout(() => {
      indicator.style.opacity = '0.3';
    }, 5000);
  };

  // Initialize when DOM is loaded
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAutoScroll);
  } else {
    initAutoScroll();
  }

  // Also try to initialize periodically in case the DOM changes or loads asynchronously
  setInterval(() => {
    const chatContainer = findChatContainer();
    if (chatContainer && !chatContainer._autoScrollInitialized) {
      chatContainer._autoScrollInitialized = true;
      initAutoScroll();
    }
  }, 2000);
})();
EOL

# Backup original app.asar file
echo "Creating backup of original app.asar file..."
cp "/Applications/Claude.app/Contents/Resources/app.asar" "$BASE_DIR/backup/app.asar.$(date +%Y%m%d%H%M%S).backup"

# Extract app.asar
echo "Extracting app.asar file..."
npx asar extract "/Applications/Claude.app/Contents/Resources/app.asar" "$BASE_DIR/extracted"

# Inject auto-scroll script into main_window/index.html
echo "Injecting auto-scroll script..."
MAIN_WINDOW_INDEX="$BASE_DIR/extracted/.vite/renderer/main_window/index.html"

# Check if the file exists
if [ ! -f "$MAIN_WINDOW_INDEX" ]; then
    echo "Error: Could not find main window HTML file at $MAIN_WINDOW_INDEX"
    echo "The structure of the Claude Desktop app may have changed."
    exit 1
fi

# Add script reference to the HTML file
sed -i '' 's/<head>/<head>\n    <script src="..\/..\/auto-scroll\/auto-scroll.js"><\/script>/' "$MAIN_WINDOW_INDEX"

# Pack modified files back into app.asar
echo "Packing modified files back into app.asar..."
npx asar pack "$BASE_DIR/extracted" "$BASE_DIR/app.asar"

# Replace original app.asar with the modified one
echo "Installing modified app.asar..."
cp "$BASE_DIR/app.asar" "/Applications/Claude.app/Contents/Resources/app.asar"

echo ""
echo "✅ Auto-scroll fix successfully installed!"
echo ""
echo "Features:"
echo "- Chat window will automatically scroll to the bottom when new content appears"
echo "- Press Ctrl+Space to toggle auto-scrolling on/off"
echo "- A small indicator will appear in the bottom-right corner showing the auto-scroll status"
echo ""
echo "Note: You'll need to restart Claude Desktop for the changes to take effect."
echo "To uninstall, restore from the backup file in: $BASE_DIR/backup/"
echo ""
