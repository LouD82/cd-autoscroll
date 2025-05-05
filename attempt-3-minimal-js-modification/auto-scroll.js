// Claude Desktop Auto-Scroll Fix - Minimal JS Modification Approach
// This code is appended to an existing JS file in the Claude Desktop application

// Use an IIFE with multiple error boundaries to prevent app crashes
(function() {
  // Skip initialization if window is undefined (not in renderer process)
  if (typeof window === 'undefined') return;

  // Store a reference to console methods before doing anything else
  const safeConsole = {
    log: window.console?.log?.bind(window.console) || function() {},
    error: window.console?.error?.bind(window.console) || function() {},
    warn: window.console?.warn?.bind(window.console) || function() {}
  };

  // Main initialization function wrapped in try/catch
  function initAutoScrollFix() {
    try {
      safeConsole.log('[Auto-Scroll Fix] Starting initialization');
      
      // Configuration
      const config = {
        debug: false,
        scrollThreshold: 100,  // Distance from bottom to consider "near bottom" (px)
        indicatorTimeout: 5000, // Time until indicator fades (ms)
        retryInterval: 1000,    // Interval for retrying container detection (ms)
        initialDelay: 2500      // Initial delay before starting container detection (ms)
      };
      
      // Early exit if auto-scroll is already initialized
      if (window.__claude_auto_scroll_initialized) {
        safeConsole.log('[Auto-Scroll Fix] Already initialized, skipping');
        return;
      }
      
      // Mark as initialized to prevent multiple initializations
      window.__claude_auto_scroll_initialized = true;
      
      // Debug logging helper
      const debug = (message, ...args) => {
        if (config.debug) {
          safeConsole.log(`[Auto-Scroll Fix Debug] ${message}`, ...args);
        }
      };
      
      // Initialize after a delay to ensure app is fully loaded
      setTimeout(() => {
        try {
          // Find and attach to the chat container
          findChatContainer();
        } catch (err) {
          safeConsole.error('[Auto-Scroll Fix] Error during delayed initialization:', err);
        }
      }, config.initialDelay);
      
      // Function to find the chat container
      function findChatContainer() {
        debug('Looking for chat container');
        
        // List of selectors to try, from most specific to most general
        const possibleSelectors = [
          '.message-list-container', 
          '.conversation-container', 
          '.chat-messages',
          'main', 
          '[role="main"]',
          'div[style*="overflow"][style*="scroll"]',
          'div[style*="overflow: auto"]',
          'div[style*="overflow-y: auto"]'
        ];
        
        let chatContainer = null;
        
        // Try each selector
        try {
          // First try specific selectors
          for (const selector of possibleSelectors) {
            const elements = document.querySelectorAll(selector);
            for (const el of elements) {
              if (
                el.scrollHeight > el.clientHeight && 
                el.clientHeight > 100 && 
                el.querySelector('div, p')
              ) {
                chatContainer = el;
                debug('Found chat container using selector:', selector);
                break;
              }
            }
            if (chatContainer) break;
          }
          
          // If still not found, try finding the tallest scrollable element
          if (!chatContainer) {
            let maxHeight = 0;
            
            document.querySelectorAll('div').forEach(div => {
              try {
                const style = window.getComputedStyle(div);
                if (
                  (style.overflowY === 'auto' || style.overflowY === 'scroll') &&
                  div.scrollHeight > div.clientHeight &&
                  div.clientHeight > maxHeight
                ) {
                  maxHeight = div.clientHeight;
                  chatContainer = div;
                }
              } catch (err) {
                debug('Error checking div style:', err);
              }
            });
            
            if (chatContainer) {
              debug('Found container by height, height:', maxHeight);
            }
          }
          
          // If we found a container, set up the auto-scroll
          if (chatContainer) {
            setupAutoScroll(chatContainer);
          } else {
            safeConsole.log('[Auto-Scroll Fix] No chat container found yet, retrying in 1 second');
            setTimeout(findChatContainer, config.retryInterval);
          }
        } catch (err) {
          safeConsole.error('[Auto-Scroll Fix] Error finding chat container:', err);
          // Retry after a delay
          setTimeout(findChatContainer, config.retryInterval);
        }
      }
      
      // Set up auto-scroll on the chat container
      function setupAutoScroll(chatContainer) {
        try {
          // Prevent multiple initialization on the same container
          if (chatContainer._autoScrollInitialized) {
            debug('Container already initialized, skipping');
            return;
          }
          
          // Mark this container as initialized
          chatContainer._autoScrollInitialized = true;
          
          safeConsole.log('[Auto-Scroll Fix] Setting up auto-scroll on container:', 
                          chatContainer.className || chatContainer.id || 'unnamed element');
          
          // Variables to track scroll state
          let isNearBottom = true;
          let isAutoScrollPaused = false;
          let lastScrollHeight = chatContainer.scrollHeight;
          
          // Check if user is near bottom
          const checkIfNearBottom = () => {
            try {
              const scrollPosition = chatContainer.scrollHeight - chatContainer.scrollTop - chatContainer.clientHeight;
              return scrollPosition < config.scrollThreshold;
            } catch (err) {
              debug('Error checking if near bottom:', err);
              return true; // Default to true in case of error
            }
          };
          
          // Update auto-scroll state based on user scrolling
          try {
            chatContainer.addEventListener('scroll', () => {
              try {
                isNearBottom = checkIfNearBottom();
                debug('Scroll detected, near bottom:', isNearBottom);
              } catch (err) {
                debug('Error in scroll event handler:', err);
              }
            });
          } catch (err) {
            safeConsole.warn('[Auto-Scroll Fix] Could not add scroll listener:', err);
          }
          
          // Create and add a mutation observer to catch content changes
          try {
            const observer = new MutationObserver((mutations) => {
              try {
                // Only process if content has actually been added
                if (chatContainer.scrollHeight > lastScrollHeight) {
                  debug('Content added, auto-scroll needed:', isNearBottom);
                  
                  if (isNearBottom && !isAutoScrollPaused) {
                    // Use requestAnimationFrame for smoother scrolling
                    requestAnimationFrame(() => {
                      try {
                        chatContainer.scrollTop = chatContainer.scrollHeight;
                      } catch (err) {
                        debug('Error scrolling in requestAnimationFrame:', err);
                      }
                    });
                  }
                  
                  lastScrollHeight = chatContainer.scrollHeight;
                }
              } catch (err) {
                debug('Error in MutationObserver callback:', err);
              }
            });
            
            // Start observing with a configuration that watches for content changes
            observer.observe(chatContainer, {
              childList: true,
              subtree: true,
              characterData: true
            });
          } catch (err) {
            safeConsole.warn('[Auto-Scroll Fix] Could not create MutationObserver:', err);
          }
          
          // Create a stateful indicator component
          function createScrollIndicator() {
            try {
              // Create visual indicator
              const indicator = document.createElement('div');
              indicator.id = 'claude-auto-scroll-indicator';
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
                pointer-events: auto;
                cursor: pointer;
              `;
              
              // Function to update indicator text
              function updateIndicator() {
                try {
                  indicator.textContent = isAutoScrollPaused ? '📜 Auto-scroll paused' : '📜 Auto-scroll active';
                } catch (err) {
                  debug('Error updating indicator text:', err);
                }
              }
              
              updateIndicator();
              
              // Make indicator interactive
              indicator.title = 'Press Ctrl+Space to toggle auto-scrolling';
              
              try {
                indicator.addEventListener('mouseover', () => { 
                  indicator.style.opacity = '1'; 
                });
                
                indicator.addEventListener('mouseout', () => { 
                  indicator.style.opacity = '0.7'; 
                });
                
                indicator.addEventListener('click', () => {
                  isAutoScrollPaused = !isAutoScrollPaused;
                  updateIndicator();
                  
                  if (!isAutoScrollPaused && isNearBottom) {
                    chatContainer.scrollTop = chatContainer.scrollHeight;
                  }
                });
              } catch (err) {
                safeConsole.warn('[Auto-Scroll Fix] Error setting up indicator events:', err);
              }
              
              // Add indicator to the document safely
              try {
                document.body.appendChild(indicator);
                
                // Fade indicator after timeout
                setTimeout(() => {
                  try {
                    indicator.style.opacity = '0.3';
                  } catch (err) {
                    debug('Error fading indicator:', err);
                  }
                }, config.indicatorTimeout);
              } catch (err) {
                safeConsole.warn('[Auto-Scroll Fix] Error adding indicator to document:', err);
              }
              
              return {
                element: indicator,
                update: updateIndicator
              };
            } catch (err) {
              safeConsole.error('[Auto-Scroll Fix] Error creating indicator:', err);
              return {
                update: () => {} // Empty function as fallback
              };
            }
          }
          
          // Create the indicator
          const indicator = createScrollIndicator();
          
          // Add a key listener to pause/resume auto-scrolling (Ctrl+Space)
          try {
            document.addEventListener('keydown', (e) => {
              try {
                if (e.ctrlKey && e.code === 'Space') {
                  isAutoScrollPaused = !isAutoScrollPaused;
                  safeConsole.log(`[Auto-Scroll Fix] Auto-scrolling is now ${isAutoScrollPaused ? 'paused' : 'enabled'}`);
                  
                  // If unpausing and near bottom, scroll to bottom immediately
                  if (!isAutoScrollPaused && isNearBottom) {
                    chatContainer.scrollTop = chatContainer.scrollHeight;
                  }
                  
                  indicator.update();
                  e.preventDefault();
                }
              } catch (err) {
                debug('Error in keydown event handler:', err);
              }
            });
          } catch (err) {
            safeConsole.warn('[Auto-Scroll Fix] Could not add keydown listener:', err);
          }
          
          safeConsole.log('[Auto-Scroll Fix] Auto-scroll activated. Use Ctrl+Space to toggle auto-scrolling.');
        } catch (err) {
          safeConsole.error('[Auto-Scroll Fix] Error setting up auto-scroll:', err);
        }
      }
    } catch (err) {
      safeConsole.error('[Auto-Scroll Fix] Critical error during initialization:', err);
    }
  }
  
  // Safe initialization with multiple fallback strategies
  try {
    // Strategy 1: Initialize on DOMContentLoaded
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => {
        try {
          setTimeout(initAutoScrollFix, 1000);
        } catch (err) {
          safeConsole.error('[Auto-Scroll Fix] Error in DOMContentLoaded handler:', err);
        }
      });
    } else {
      // Strategy 2: Document already loaded, delay initialization
      setTimeout(initAutoScrollFix, 1000);
    }
    
    // Strategy 3: Also try to initialize after window is fully loaded
    window.addEventListener('load', () => {
      try {
        setTimeout(initAutoScrollFix, 2000);
      } catch (err) {
        safeConsole.error('[Auto-Scroll Fix] Error in load event handler:', err);
      }
    });
    
    // Strategy 4: Final fallback - try again after a longer delay
    setTimeout(() => {
      try {
        if (!window.__claude_auto_scroll_initialized) {
          initAutoScrollFix();
        }
      } catch (err) {
        safeConsole.error('[Auto-Scroll Fix] Error in fallback initialization:', err);
      }
    }, 5000);
  } catch (err) {
    // Last-ditch error logging
    if (window.console && window.console.error) {
      window.console.error('[Auto-Scroll Fix] Fatal initialization error:', err);
    }
  }
})();