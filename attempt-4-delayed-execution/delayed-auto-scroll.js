// Ultra-minimal auto-scroll fix for Claude Desktop
// This script is designed to be as non-invasive as possible

// Wrap everything in an immediately-invoked function expression
// to avoid polluting the global namespace
(function() {
  // Skip execution if not in a browser environment
  if (typeof window !== 'object' || typeof document !== 'object') return;
  
  // Store safe references to console methods
  var log = function(msg) { try { console.log('[Auto-Scroll] ' + msg); } catch(e) {} };
  var error = function(msg, err) { try { console.error('[Auto-Scroll] ' + msg, err); } catch(e) {} };
  
  // Store initialization flag on window to prevent multiple initializations
  if (window.__claude_autoscroll_pending) return;
  window.__claude_autoscroll_pending = true;
  
  // Super-delayed initialization - wait 10 seconds after page load
  // This ensures the app is completely initialized before we do anything
  log('Scheduling delayed initialization...');
  setTimeout(function() {
    try {
      // Only proceed if not already initialized
      if (window.__claude_autoscroll_initialized) return;
      
      log('Delayed initialization started');
      initAutoScroll();
    } catch(err) {
      error('Error during delayed initialization:', err);
    }
  }, 10000); // 10 seconds delay
  
  // Main initialization function
  function initAutoScroll() {
    try {
      // Set flag to prevent multiple initializations
      window.__claude_autoscroll_initialized = true;
      
      // Find the chat container using minimal approach
      var chatContainer = findChatContainer();
      if (!chatContainer) {
        log('No chat container found yet, scheduling retry');
        
        // Try again in 5 seconds
        setTimeout(function() {
          if (!window.__claude_autoscroll_container_found) {
            try {
              var container = findChatContainer();
              if (container) setupAutoScroll(container);
            } catch(err) {
              error('Error in retry:', err);
            }
          }
        }, 5000);
        return;
      }
      
      setupAutoScroll(chatContainer);
    } catch(err) {
      error('Error in initialization:', err);
    }
  }
  
  // Find the chat container using multiple methods
  function findChatContainer() {
    try {
      // Start with conservative approach - only look for obvious chat containers
      var container = null;
      
      // Method 1: Try to find a tall scrollable element
      var tallestElement = null;
      var maxHeight = 300; // Minimum height to consider
      
      var allDivs = document.querySelectorAll('div');
      for (var i = 0; i < allDivs.length; i++) {
        try {
          var div = allDivs[i];
          var style = window.getComputedStyle(div);
          
          // Only check elements that are visible and scrollable
          if (style.display !== 'none' && 
              style.visibility !== 'hidden' && 
              (style.overflowY === 'auto' || style.overflowY === 'scroll') &&
              div.clientHeight > maxHeight &&
              div.scrollHeight > div.clientHeight) {
            
            maxHeight = div.clientHeight;
            tallestElement = div;
          }
        } catch(e) {
          // Ignore errors for individual elements
        }
      }
      
      if (tallestElement) {
        log('Found chat container (tallest scrollable element)');
        container = tallestElement;
      }
      
      return container;
    } catch(err) {
      error('Error finding chat container:', err);
      return null;
    }
  }
  
  // Set up the auto-scroll functionality
  function setupAutoScroll(container) {
    try {
      // Mark as found to prevent further searches
      window.__claude_autoscroll_container_found = true;
      
      log('Setting up auto-scroll');
      
      // Basic state tracking
      var isNearBottom = true;
      var lastScrollHeight = container.scrollHeight;
      
      // Check if user is near bottom
      function checkIfNearBottom() {
        try {
          var threshold = 100;
          var scrollPosition = container.scrollHeight - container.scrollTop - container.clientHeight;
          return scrollPosition < threshold;
        } catch(err) {
          return true; // Default to true on error
        }
      }
      
      // Update state when user scrolls manually
      try {
        container.addEventListener('scroll', function() {
          try {
            isNearBottom = checkIfNearBottom();
          } catch(e) {
            // Ignore errors in scroll handler
          }
        });
      } catch(err) {
        error('Could not add scroll listener:', err);
      }
      
      // Observe for content changes
      try {
        var observer = new MutationObserver(function(mutations) {
          try {
            // Only scroll if content has been added
            if (container.scrollHeight > lastScrollHeight) {
              if (isNearBottom) {
                // Use requestAnimationFrame for smoother scrolling
                requestAnimationFrame(function() {
                  try {
                    container.scrollTop = container.scrollHeight;
                  } catch(e) {
                    // Ignore errors in scroll action
                  }
                });
              }
              
              lastScrollHeight = container.scrollHeight;
            }
          } catch(e) {
            // Ignore errors in mutation handler
          }
        });
        
        // Start observing changes
        observer.observe(container, {
          childList: true,
          subtree: true,
          characterData: true
        });
        
        log('Auto-scroll successfully activated');
      } catch(err) {
        error('Could not create observer:', err);
      }
    } catch(err) {
      error('Error setting up auto-scroll:', err);
    }
  }
})();