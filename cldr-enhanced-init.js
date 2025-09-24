/**
 * Enhanced CLDR Fix with Advanced Fallback Strategies
 * 
 * This enhanced version provides multiple layers of fallback protection
 * and automatic detection of the best available date/time solution.
 */

(function() {
  'use strict';
  
  // Enhanced configuration
  const CLDR_CONFIG = {
    enableDetailedLogging: true,
    fallbackStrategies: ['cldr', 'luxon', 'intl', 'custom'],
    performanceMonitoring: true,
    autoFallbackDetection: true
  };
  
  // Performance monitoring
  const perfMonitor = {
    start: Date.now(),
    events: [],
    log(event, data) {
      if (CLDR_CONFIG.performanceMonitoring) {
        this.events.push({
          timestamp: Date.now() - this.start,
          event,
          data
        });
        console.log(`📊 CLDR Performance: ${event}`, data);
      }
    }
  };
  
  perfMonitor.log('init-start', { strategies: CLDR_CONFIG.fallbackStrategies });
  
  // Strategy 1: Enhanced CLDR with better error handling
  function initializeCLDRStrategy() {
    perfMonitor.log('cldr-strategy-start');
    
    if (typeof window !== 'undefined' && typeof window.Cldr === 'function') {
      try {
        // Load enhanced CLDR data with more complete locale information
        window.Cldr.load({
          "supplemental": {
            "version": {
              "_unicodeVersion": "15.1.0",
              "_cldrVersion": "45"
            },
            "likelySubtags": {
              "en": "en-Latn-US",
              "ja": "ja-Jpan-JP",
              "es": "es-Latn-ES",
              "fr": "fr-Latn-FR",
              "de": "de-Latn-DE"
            },
            "weekData": {
              "firstDay": {
                "001": "mon",
                "US": "sun",
                "JP": "sun",
                "GB": "mon"
              },
              "minDays": {
                "001": 1,
                "US": 1,
                "JP": 1,
                "GB": 4
              }
            },
            "timeData": {
              "001": {
                "_preferred": "H"
              },
              "US": {
                "_preferred": "h"
              }
            }
          }
        });
        
        perfMonitor.log('cldr-data-loaded', { success: true });
        console.log('✅ Enhanced CLDR data loaded successfully with extended locale support');
        return true;
        
      } catch (error) {
        perfMonitor.log('cldr-error', { error: error.message });
        console.error('❌ Enhanced CLDR loading failed:', error);
        return false;
      }
    }
    
    perfMonitor.log('cldr-strategy-end', { available: false });
    return false;
  }
  
  // Strategy 2: Luxon fallback (uses library already in package.json)
  function initializeLuxonFallback() {
    perfMonitor.log('luxon-strategy-start');
    
    try {
      // Check if Luxon is available (it's already in package.json)
      if (typeof window !== 'undefined' && typeof require !== 'undefined') {
        const luxon = require('luxon');
        if (luxon && luxon.DateTime) {
          window.AthensDateFallback = {
            type: 'luxon',
            formatDate: (date, format) => {
              try {
                const dt = luxon.DateTime.fromJSDate(new Date(date));
                return dt.toFormat(format.replace(/LLLL/g, 'LLLL').replace(/dd/g, 'dd').replace(/yyyy/g, 'yyyy'));
              } catch (e) {
                perfMonitor.log('luxon-format-error', { error: e.message });
                return date.toString();
              }
            },
            now: () => luxon.DateTime.now(),
            isAvailable: true
          };
          
          perfMonitor.log('luxon-strategy-success');
          console.log('✅ Luxon fallback initialized successfully');
          return true;
        }
      }
    } catch (error) {
      perfMonitor.log('luxon-error', { error: error.message });
      console.warn('⚠️ Luxon fallback initialization failed:', error.message);
    }
    
    perfMonitor.log('luxon-strategy-end', { available: false });
    return false;
  }
  
  // Strategy 3: Native Intl API fallback
  function initializeIntlFallback() {
    perfMonitor.log('intl-strategy-start');
    
    if (typeof window !== 'undefined' && typeof Intl !== 'undefined' && Intl.DateTimeFormat) {
      try {
        // Test basic Intl functionality
        const testFormat = new Intl.DateTimeFormat('en-US', {
          month: 'long',
          day: 'numeric', 
          year: 'numeric'
        });
        
        const testDate = new Date();
        const formatted = testFormat.format(testDate);
        
        window.AthensDateFallback = {
          type: 'intl',
          formatDate: (date, locale = 'en-US') => {
            try {
              return new Intl.DateTimeFormat(locale, {
                month: 'long',
                day: 'numeric',
                year: 'numeric'
              }).format(new Date(date));
            } catch (e) {
              perfMonitor.log('intl-format-error', { error: e.message });
              return new Date(date).toLocaleDateString();
            }
          },
          formatTime: (date, locale = 'en-US') => {
            try {
              return new Intl.DateTimeFormat(locale, {
                hour: 'numeric',
                minute: '2-digit'
              }).format(new Date(date));
            } catch (e) {
              return new Date(date).toLocaleTimeString();
            }
          },
          now: () => new Date(),
          isAvailable: true
        };
        
        perfMonitor.log('intl-strategy-success', { testResult: formatted });
        console.log('✅ Native Intl API fallback initialized successfully');
        return true;
        
      } catch (error) {
        perfMonitor.log('intl-error', { error: error.message });
        console.warn('⚠️ Native Intl fallback failed:', error.message);
      }
    }
    
    perfMonitor.log('intl-strategy-end', { available: false });
    return false;
  }
  
  // Strategy 4: Custom minimal implementation
  function initializeCustomFallback() {
    perfMonitor.log('custom-strategy-start');
    
    if (typeof window !== 'undefined') {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      
      window.AthensDateFallback = {
        type: 'custom',
        formatDate: (date) => {
          try {
            const d = new Date(date);
            return `${months[d.getMonth()]} ${d.getDate()}, ${d.getFullYear()}`;
          } catch (e) {
            perfMonitor.log('custom-format-error', { error: e.message });
            return 'Invalid Date';
          }
        },
        formatUID: (date) => {
          try {
            const d = new Date(date);
            return `${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}-${d.getFullYear()}`;
          } catch (e) {
            return null;
          }
        },
        now: () => new Date(),
        isAvailable: true
      };
      
      perfMonitor.log('custom-strategy-success');
      console.log('✅ Custom fallback implementation initialized');
      return true;
    }
    
    perfMonitor.log('custom-strategy-end', { available: false });
    return false;
  }
  
  // Main initialization with strategy priority
  function initializeEnhancedCLDRFix() {
    perfMonitor.log('main-init-start');
    
    const strategies = [
      { name: 'CLDR', init: initializeCLDRStrategy },
      { name: 'Luxon', init: initializeLuxonFallback },
      { name: 'Intl', init: initializeIntlFallback },
      { name: 'Custom', init: initializeCustomFallback }
    ];
    
    let successfulStrategies = 0;
    const results = {};
    
    for (const strategy of strategies) {
      try {
        const success = strategy.init();
        results[strategy.name] = success;
        if (success) successfulStrategies++;
        
        perfMonitor.log('strategy-result', { 
          strategy: strategy.name, 
          success,
          totalSuccessful: successfulStrategies 
        });
        
      } catch (error) {
        results[strategy.name] = false;
        perfMonitor.log('strategy-error', { 
          strategy: strategy.name, 
          error: error.message 
        });
        console.error(`❌ Strategy ${strategy.name} failed:`, error);
      }
    }
    
    // Ensure we have at least one working strategy
    if (successfulStrategies === 0) {
      console.error('🚨 CRITICAL: No date/time strategies available!');
      // Last resort: basic Date functionality
      if (typeof window !== 'undefined') {
        window.AthensDateFallback = {
          type: 'minimal',
          formatDate: (date) => new Date(date).toString(),
          now: () => new Date(),
          isAvailable: true
        };
        console.log('🔧 Minimal Date fallback activated as last resort');
      }
    }
    
    // Create CLDR mock with enhanced functionality if needed
    if (!results.CLDR && typeof window !== 'undefined') {
      window.Cldr = window.Cldr || {};
      window.Cldr.load = window.Cldr.load || function(data) {
        perfMonitor.log('cldr-mock-used', { dataKeys: data ? Object.keys(data) : [] });
        console.log('🔧 Enhanced CLDR mock used - data keys:', 
                   data && typeof data === 'object' ? Object.keys(data) : 'none');
        return data;
      };
    }
    
    perfMonitor.log('main-init-complete', { 
      results, 
      successfulStrategies,
      totalTime: Date.now() - perfMonitor.start 
    });
    
    console.log('🎯 Enhanced CLDR initialization complete:', {
      successfulStrategies,
      results,
      fallbackAvailable: !!window.AthensDateFallback
    });
  }
  
  // Initialize immediately
  initializeEnhancedCLDRFix();
  
  // Export performance data for debugging
  if (typeof window !== 'undefined') {
    window.AthensPerformanceMonitor = perfMonitor;
  }
  
})();