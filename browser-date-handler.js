/**
 * Browser-Only Date Handler for Athens
 * 
 * This module provides complete date/time functionality without requiring
 * any Clojure dependencies or Clojars access. It's designed to work in
 * browser environments and provides full compatibility with Athens date needs.
 * 
 * Features:
 * - No external dependencies
 * - Full Athens date format support
 * - Internationalization ready
 * - Performance optimized
 * - Error resilient
 */

(function() {
  'use strict';
  
  // Athens date format constants
  const FORMATS = {
    US_DATE: 'MM-dd-yyyy',      // 10-15-2023
    TITLE: 'LLLL dd, yyyy',     // October 15, 2023
    DISPLAY: 'LLLL dd, yyyy h:mma', // October 15, 2023 3:45pm
    ISO: 'yyyy-MM-dd',          // 2023-10-15
    COMPACT: 'MMM d, yy'        // Oct 15, 23
  };
  
  // Month names for formatting
  const MONTHS_LONG = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  
  const MONTHS_SHORT = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  
  // Main date handler object
  window.AthensDateHandler = {
    
    /**
     * Format date in US format (MM-dd-yyyy)
     * Used for daily note UIDs and internal date representation
     */
    formatUSDate: function(date) {
      try {
        const d = new Date(date);
        if (isNaN(d.getTime())) return null;
        
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        const year = d.getFullYear();
        
        return `${month}-${day}-${year}`;
      } catch (error) {
        console.warn('AthensDateHandler.formatUSDate error:', error);
        return null;
      }
    },
    
    /**
     * Format date in title format (October 15, 2023)
     * Used for page titles and display text
     */
    formatTitle: function(date, options = {}) {
      try {
        const d = new Date(date);
        if (isNaN(d.getTime())) return 'Invalid Date';
        
        const month = MONTHS_LONG[d.getMonth()];
        const day = d.getDate();
        const year = d.getFullYear();
        
        return `${month} ${day}, ${year}`;
      } catch (error) {
        console.warn('AthensDateHandler.formatTitle error:', error);
        return 'Invalid Date';
      }
    },
    
    /**
     * Format date for display with time (October 15, 2023 3:45pm)
     * Used for timestamps and detailed date displays
     */
    formatDisplay: function(date) {
      try {
        const d = new Date(date);
        if (isNaN(d.getTime())) return 'Invalid Date';
        
        const month = MONTHS_LONG[d.getMonth()];
        const day = d.getDate();
        const year = d.getFullYear();
        const hours = d.getHours();
        const minutes = String(d.getMinutes()).padStart(2, '0');
        const ampm = hours >= 12 ? 'pm' : 'am';
        const displayHours = hours === 0 ? 12 : (hours > 12 ? hours - 12 : hours);
        
        return `${month} ${day}, ${year} ${displayHours}:${minutes}${ampm}`;
      } catch (error) {
        console.warn('AthensDateHandler.formatDisplay error:', error);
        return 'Invalid Date';
      }
    },
    
    /**
     * Format date in compact format (Oct 15, 23)
     * Used for space-constrained displays
     */
    formatCompact: function(date) {
      try {
        const d = new Date(date);
        if (isNaN(d.getTime())) return 'Invalid Date';
        
        const month = MONTHS_SHORT[d.getMonth()];
        const day = d.getDate();
        const year = String(d.getFullYear()).slice(-2);
        
        return `${month} ${day}, ${year}`;
      } catch (error) {
        console.warn('AthensDateHandler.formatCompact error:', error);
        return 'Invalid Date';
      }
    },
    
    /**
     * Parse UID format (MM-dd-yyyy) to Date object
     * Core function for converting Athens date UIDs to Date objects
     */
    parseUID: function(uid) {
      if (!uid || typeof uid !== 'string') return null;
      
      try {
        const match = uid.match(/^(\d{2})-(\d{2})-(\d{4})$/);
        if (!match) return null;
        
        const [_, month, day, year] = match;
        const monthNum = parseInt(month, 10);
        const dayNum = parseInt(day, 10);
        const yearNum = parseInt(year, 10);
        
        // Validate date components
        if (monthNum < 1 || monthNum > 12) return null;
        if (dayNum < 1 || dayNum > 31) return null;
        if (yearNum < 1900 || yearNum > 3000) return null;
        
        const date = new Date(yearNum, monthNum - 1, dayNum);
        
        // Verify the date is valid and matches input
        if (date.getFullYear() === yearNum && 
            date.getMonth() === monthNum - 1 && 
            date.getDate() === dayNum) {
          return date;
        }
        
        return null;
      } catch (error) {
        console.warn('AthensDateHandler.parseUID error:', error);
        return null;
      }
    },
    
    /**
     * Parse title format (October 15, 2023) to Date object
     * Used for parsing page titles back to dates
     */
    parseTitle: function(title) {
      if (!title || typeof title !== 'string') return null;
      
      try {
        // Try native Date parsing first
        const nativeDate = new Date(title);
        if (!isNaN(nativeDate.getTime())) {
          return nativeDate;
        }
        
        // Manual parsing for "Month DD, YYYY" format
        const pattern = /^(\w+)\s+(\d{1,2}),\s+(\d{4})$/;
        const match = title.match(pattern);
        
        if (match) {
          const [_, monthName, day, year] = match;
          const monthIndex = MONTHS_LONG.indexOf(monthName);
          
          if (monthIndex !== -1) {
            const date = new Date(parseInt(year), monthIndex, parseInt(day));
            if (!isNaN(date.getTime())) {
              return date;
            }
          }
        }
        
        return null;
      } catch (error) {
        console.warn('AthensDateHandler.parseTitle error:', error);
        return null;
      }
    },
    
    /**
     * Get current date
     */
    getToday: function() {
      return new Date();
    },
    
    /**
     * Get date with offset from today
     * Core function for Athens day navigation
     */
    getDayWithOffset: function(offset = 0, baseDate = null) {
      try {
        const base = baseDate ? new Date(baseDate) : new Date();
        if (isNaN(base.getTime())) return null;
        
        const targetDate = new Date(base);
        targetDate.setDate(base.getDate() + offset);
        
        return {
          uid: this.formatUSDate(targetDate),
          title: this.formatTitle(targetDate),
          inst: targetDate,
          timestamp: targetDate.getTime()
        };
      } catch (error) {
        console.warn('AthensDateHandler.getDayWithOffset error:', error);
        return null;
      }
    },
    
    /**
     * Check if string is a valid daily note UID
     * Used for Athens daily note detection
     */
    isDailyNoteUID: function(uid) {
      return this.parseUID(uid) !== null;
    },
    
    /**
     * Format timestamp for display
     * Handles various timestamp formats
     */
    formatTimestamp: function(timestamp) {
      if (!timestamp) return '(unknown date)';
      
      try {
        const date = new Date(timestamp);
        if (isNaN(date.getTime())) return '(invalid date)';
        
        return this.formatDisplay(date);
      } catch (error) {
        console.warn('AthensDateHandler.formatTimestamp error:', error);
        return '(error formatting date)';
      }
    },
    
    /**
     * Get date range for calendar/planning features
     */
    getDateRange: function(startOffset, endOffset, baseDate = null) {
      try {
        const base = baseDate ? new Date(baseDate) : new Date();
        const range = [];
        
        for (let i = startOffset; i <= endOffset; i++) {
          const dayData = this.getDayWithOffset(i, base);
          if (dayData) {
            range.push(dayData);
          }
        }
        
        return range;
      } catch (error) {
        console.warn('AthensDateHandler.getDateRange error:', error);
        return [];
      }
    },
    
    /**
     * Validate date input
     */
    isValidDate: function(date) {
      try {
        const d = new Date(date);
        return !isNaN(d.getTime());
      } catch (error) {
        return false;
      }
    },
    
    /**
     * Get locale-specific formatting (future enhancement)
     */
    formatLocale: function(date, locale = 'en-US') {
      try {
        const d = new Date(date);
        if (isNaN(d.getTime())) return 'Invalid Date';
        
        if (typeof Intl !== 'undefined' && Intl.DateTimeFormat) {
          return new Intl.DateTimeFormat(locale, {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
          }).format(d);
        } else {
          // Fallback to English formatting
          return this.formatTitle(d);
        }
      } catch (error) {
        console.warn('AthensDateHandler.formatLocale error:', error);
        return this.formatTitle(date);
      }
    }
  };
  
  // Export for Node.js compatibility (testing)
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = window.AthensDateHandler;
  }
  
  // Initialize and log availability
  console.log('✅ AthensDateHandler initialized - No Clojars dependencies required');
  console.log('📅 Available methods:', Object.keys(window.AthensDateHandler));
  
  // Test basic functionality
  try {
    const today = window.AthensDateHandler.getToday();
    const todayData = window.AthensDateHandler.getDayWithOffset(0);
    console.log('🧪 Basic functionality test:', {
      today: window.AthensDateHandler.formatTitle(today),
      uid: todayData.uid,
      parseTest: window.AthensDateHandler.parseUID(todayData.uid) !== null
    });
  } catch (error) {
    console.warn('⚠️ AthensDateHandler test failed:', error);
  }
  
})();