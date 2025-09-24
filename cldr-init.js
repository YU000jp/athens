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
      window.Cldr.load({
        "supplemental": {
          "version": {
            "_unicodeVersion": "12.0.0",
            "_cldrVersion": "36"
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
      
      // Provide a fallback Cldr.load function if the library is not working properly
      if (typeof window.Cldr.load !== 'function') {
        window.Cldr.load = function(data) {
          console.warn('Using fallback Cldr.load implementation');
          return data;
        };
      }
    }
  } else if (typeof window !== 'undefined') {
    // If Cldr is not available, provide a minimal mock
    console.warn('Cldr not found, providing minimal mock implementation');
    window.Cldr = {
      load: function(data) {
        console.log('Mock Cldr.load called with:', data);
        return data;
      }
    };
  }
})();