// Minimal auto-scroll fix - phase 3
(function() {
  // Only run once everything is truly loaded
  window.addEventListener("load", function() {
    // Wait a significant time after load
    setTimeout(function() {
      try {
        console.log("Auto-scroll fix: Phase 3 initialization successful");
        
        // Try to identify the chat container
        let chatContainer = null;
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
        
        if (chatContainer) {
          console.log("Auto-scroll fix: Found potential chat container");
          console.log("Container details - height:", chatContainer.clientHeight, "scrollHeight:", chatContainer.scrollHeight);
        } else {
          console.log("Auto-scroll fix: No chat container found");
        }
      } catch(e) {
        console.error("Auto-scroll fix initialization error:", e);
      }
    }, 5000); // 5 second delay
  });
})();
