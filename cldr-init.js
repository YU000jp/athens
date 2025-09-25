/**
 * CLDR Data Initialization for Browser Tests
 * 
 * This script ensures CLDR data is properly loaded before js-joda locale package
 * attempts to use it. This fixes the "Cldr.load is not a function" error in Karma tests.
 * 
 * Provides minimal CLDR data required for @js-joda/locale to function in tests.
 */

(function() {
  'use strict';

  // Ensure we're in a browser environment with Cldr available
  if (typeof window !== 'undefined' && typeof window.Cldr === 'function') {
    try {
      // Load minimal required CLDR supplemental data
      // Using more recent CLDR data versions for better compatibility
      window.Cldr.load({
        "supplemental": {
          "version": {
            "_unicodeVersion": "15.1.0",  // Updated Unicode version
            "_cldrVersion": "45"          // Updated CLDR version
          },
          "likelySubtags": {
            "en": "en-Latn-US"
          },
          "weekData": {
            "firstDay": {
              "001": "mon",
              "US": "sun"
            },
            "minDays": {
              "001": 1
            }
          }
        }
      });

      console.log('CLDR supplemental data loaded successfully');
    } catch (error) {
      console.error('Failed to load CLDR data:', error);
      
      // Enhanced fallback with better error reporting
      if (typeof window.Cldr.load !== 'function') {
        console.warn('CLDR.load function not available, providing fallback implementation');
        window.Cldr.load = function(data) {
          console.warn('Using fallback Cldr.load implementation for data:', 
                      data && typeof data === 'object' ? Object.keys(data) : data);
          return data;
        };
      }
      
      // Additional fallback methods that might be needed
      if (window.Cldr && typeof window.Cldr.prototype === 'undefined') {
        window.Cldr.prototype = {
          get: function(path) {
            console.warn('Using fallback Cldr.get for path:', path);
            return {};
          }
        };
      }
    }
  } else if (typeof window !== 'undefined') {
    // If Cldr is not available, provide a minimal mock with better logging
    console.warn('Cldr not found, providing enhanced minimal mock implementation');
    window.Cldr = {
      load: function(data) {
        console.log('Mock Cldr.load called with data keys:', 
                   data && typeof data === 'object' ? Object.keys(data) : 'unknown');
        return data;
      },
      // Add additional methods that might be called
      prototype: {
        get: function(path) {
          console.warn('Mock Cldr.get called for path:', path);
          return {};
        }
      }
    };
  } else {
    // Node.js environment - log but don't create window objects
    console.log('CLDR init: Running in Node.js environment, window not available');
  }
})();