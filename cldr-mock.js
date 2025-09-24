/**
 * Alternative CLDR Mock for Browser Tests
 * 
 * This provides a mock implementation for CLDR functionality that's sufficient
 * for js-joda locale to work in test environments without needing full CLDR data.
 */

(function() {
  'use strict';
  
  // Only run in browser test environment
  if (typeof window === 'undefined') return;
  
  console.log('Initializing CLDR mock for tests...');
  
  // Provide a minimal Cldr mock if it doesn't exist or is incomplete
  if (!window.Cldr || typeof window.Cldr.load !== 'function') {
    
    // Mock CLDR implementation
    window.Cldr = function(locale) {
      this.locale = locale || 'en';
      return this;
    };
    
    // Mock static methods
    window.Cldr.load = function(data) {
      console.log('CLDR mock: loading data', Object.keys(data));
      // Store data in a simple format
      if (!window.Cldr._data) {
        window.Cldr._data = {};
      }
      Object.assign(window.Cldr._data, data);
      return window.Cldr;
    };
    
    // Mock instance methods that js-joda locale might need
    window.Cldr.prototype.get = function(path) {
      console.log('CLDR mock: get', path);
      
      // Return some default values for common paths
      if (path.includes('weekData')) {
        return {
          firstDay: { '001': 'mon', 'US': 'sun' },
          minDays: { '001': 1 }
        };
      }
      
      if (path.includes('likelySubtags')) {
        return { 'en': 'en-Latn-US' };
      }
      
      // Return empty object for other paths
      return {};
    };
    
    // Additional methods that might be needed
    window.Cldr.prototype.main = function(path) {
      return this.get(['main', this.locale].concat(path));
    };
    
    window.Cldr.prototype.supplemental = function(path) {
      return this.get(['supplemental'].concat(path));
    };
    
    console.log('✅ CLDR mock implementation provided');
  }
  
  // Try to initialize with minimal data
  try {
    window.Cldr.load({
      supplemental: {
        weekData: {
          firstDay: { '001': 'mon', 'US': 'sun' },
          minDays: { '001': 1 }
        },
        likelySubtags: {
          'en': 'en-Latn-US'
        }
      }
    });
    console.log('✅ CLDR mock data loaded successfully');
  } catch (error) {
    console.warn('CLDR mock initialization error:', error);
  }
  
})();