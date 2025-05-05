// Wait for document to be fully loaded before initializing
(function() {
  // Only initialize once DOM is completely loaded
  function initAutoScroll() {
    // Make sure we're in the renderer process
    if (typeof window === 'undefined') return;
    
    try {
      console.log('Auto-scroll fix: Initializing...');
      
      // Configuration
      const debug = false;
      const scrollThreshold = 100;
      
      // Find the main chat container - Delay this to ensure UI is loaded
      function findAndAttachToContainer() {
        // Common selectors for chat containers
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
        for (const selector of possibleSelectors) {
          const elements = document.querySelectorAll(selector);
          for (const el of elements) {
            if (
              el.scrollHeight > el.clientHeight && 
              el.clientHeight > 100 && 
              el.querySelector('div, p')
            ) {
              chatContainer = el;
              if (debug) console.log('Found chat container:', el);
              break;
            }
          }
          if (chatContainer) break;
        }
        
        // If still not found, try finding the tallest scrollable element
        if (!chatContainer) {
          let maxHeight = 0;
          
          document.querySelectorAll('div').forEach(div => {
            const style = window.getComputedStyle(div);
            if (
              (style.overflowY === 'auto' || style.overflowY === 'scroll') &&
              div.scrollHeight > div.clientHeight &&
              div.clientHeight > maxHeight
            ) {
              maxHeight = div.clientHeight;
              chatContainer = div;
            }
          });
          
          if (chatContainer && debug) console.log('Found container by height:', chatContainer);
        }
        
        // If we found a container, set up the auto-scroll
        if (chatContainer) {
          setupAutoScroll(chatContainer);
        } else {
          console.log('Auto-scroll fix: No chat container found yet, retrying in 1 second');
          setTimeout(findAndAttachToContainer, 1000);
        }
      }
      
      // Set up auto-scroll on the chat container
      function setupAutoScroll(chatContainer) {
        if (chatContainer._autoScrollInitialized) return;
        chatContainer._autoScrollInitialized = true;
        
        console.log('Auto-scroll fix: Setting up auto-scroll');
        
        // Variables to track scroll state
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
            if (debug) console.log('Content added, auto-scroll needed:', isNearBottom);
            
            if (isNearBottom && !isAutoScrollPaused) {
              // Use requestAnimationFrame for smoother scrolling
              requestAnimationFrame(() => {
                chatContainer.scrollTop = chatContainer.scrollHeight;
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
            
            updateIndicator();
            e.preventDefault();
          }
        });
        
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
        `;
        
        // Function to update indicator text
        function updateIndicator() {
          indicator.textContent = isAutoScrollPaused ? '📜 Auto-scroll paused' : '📜 Auto-scroll active';
        }
        
        updateIndicator();
        
        // Make indicator interactive
        indicator.title = 'Press Ctrl+Space to toggle auto-scrolling';
        indicator.addEventListener('mouseover', () => { indicator.style.opacity = '1'; });
        indicator.addEventListener('mouseout', () => { indicator.style.opacity = '0.7'; });
        indicator.addEventListener('click', () => {
          isAutoScrollPaused = !isAutoScrollPaused;
          updateIndicator();
          
          if (!isAutoScrollPaused && isNearBottom) {
            chatContainer.scrollTop = chatContainer.scrollHeight;
          }
        });
        
        // Add indicator to the document
        document.body.appendChild(indicator);
        
        // Fade indicator after 5 seconds
        setTimeout(() => {
          indicator.style.opacity = '0.3';
        }, 5000);
        
        console.log('Claude auto-scroll fix activated. Use Ctrl+Space to toggle auto-scrolling.');
      }
      
      // Start the process with a delay to ensure page is ready
      setTimeout(findAndAttachToContainer, 2000);
      
    } catch (error) {
      console.error('Auto-scroll fix: Error initializing:', error);
    }
  }
  
  // Best practice for initialization in Electron
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      // Further delay initialization to ensure app is fully loaded
      setTimeout(initAutoScroll, 1000);
    });
  } else {
    // Page already loaded, delay initialization
    setTimeout(initAutoScroll, 1000);
  }
  
  // Backup: also try to initialize after window is fully loaded
  window.addEventListener('load', () => {
    setTimeout(initAutoScroll, 2000);
  });
})();
