// Minimal auto-scroll fix - phase 2
(function() {
  // Only run once everything is truly loaded
  window.addEventListener("load", function() {
    // Wait a significant time after load
    setTimeout(function() {
      try {
        console.log("Auto-scroll fix: Phase 2 initialization successful");
        
        // Just inspect DOM, don't modify anything
        const scrollableElements = [];
        document.querySelectorAll('div').forEach(div => {
          const style = window.getComputedStyle(div);
          if (style.overflowY === 'auto' || style.overflowY === 'scroll') {
            scrollableElements.push(div);
          }
        });
        
        console.log("Found scrollable elements:", scrollableElements.length);
      } catch(e) {
        console.error("Auto-scroll fix initialization error:", e);
      }
    }, 5000); // 5 second delay
  });
})();
