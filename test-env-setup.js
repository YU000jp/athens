/**
 * Test Environment Setup for Enhanced Date/Time Handling
 * 
 * This file sets up the test environment with multiple date/time strategies
 * and provides comprehensive fallback mechanisms for Athens tests.
 */

(function() {
  'use strict';
  
  console.log('🧪 Setting up enhanced test environment for Athens date/time handling');
  
  // Environment detection
  const ENV_INFO = {
    hasLuxon: typeof luxon !== 'undefined',
    hasIntl: typeof Intl !== 'undefined' && typeof Intl.DateTimeFormat !== 'undefined',
    hasCldr: typeof Cldr !== 'undefined',
    hasCustomFallback: typeof window.AthensDateFallback !== 'undefined',
    nodeVersion: typeof process !== 'undefined' ? process.version : 'browser',
    userAgent: typeof navigator !== 'undefined' ? navigator.userAgent : 'unknown'
  };
  
  console.log('📊 Environment info:', ENV_INFO);
  
  // Global test utilities for date handling
  window.AthensTestUtils = {
    
    // Test all available date strategies
    testAllStrategies() {
      const results = {};
      const testDate = new Date('2023-10-15');
      
      // Test Luxon
      if (ENV_INFO.hasLuxon) {
        try {
          const luxonResult = luxon.DateTime.fromJSDate(testDate).toFormat('LLLL dd, yyyy');
          results.luxon = { success: true, result: luxonResult };
          console.log('✅ Luxon test passed:', luxonResult);
        } catch (e) {
          results.luxon = { success: false, error: e.message };
          console.log('❌ Luxon test failed:', e.message);
        }
      }
      
      // Test Intl
      if (ENV_INFO.hasIntl) {
        try {
          const intlResult = new Intl.DateTimeFormat('en-US', {
            month: 'long', day: 'numeric', year: 'numeric'
          }).format(testDate);
          results.intl = { success: true, result: intlResult };
          console.log('✅ Intl test passed:', intlResult);
        } catch (e) {
          results.intl = { success: false, error: e.message };
          console.log('❌ Intl test failed:', e.message);
        }
      }
      
      // Test CLDR
      if (ENV_INFO.hasCldr && typeof Cldr.load === 'function') {
        try {
          Cldr.load({ test: 'data' });
          results.cldr = { success: true, result: 'CLDR.load working' };
          console.log('✅ CLDR test passed');
        } catch (e) {
          results.cldr = { success: false, error: e.message };
          console.log('❌ CLDR test failed:', e.message);
        }
      }
      
      // Test custom fallback
      if (ENV_INFO.hasCustomFallback && window.AthensDateFallback) {
        try {
          const customResult = window.AthensDateFallback.formatDate(testDate);
          results.custom = { success: true, result: customResult };
          console.log('✅ Custom fallback test passed:', customResult);
        } catch (e) {
          results.custom = { success: false, error: e.message };
          console.log('❌ Custom fallback test failed:', e.message);
        }
      }
      
      return results;
    },
    
    // Benchmark date operations
    benchmarkDateOperations() {
      const iterations = 1000;
      const testDate = new Date();
      const results = {};
      
      // Benchmark Luxon
      if (ENV_INFO.hasLuxon) {
        const startLuxon = performance.now();
        for (let i = 0; i < iterations; i++) {
          luxon.DateTime.fromJSDate(testDate).toFormat('LLLL dd, yyyy');
        }
        results.luxon = performance.now() - startLuxon;
      }
      
      // Benchmark Intl
      if (ENV_INFO.hasIntl) {
        const startIntl = performance.now();
        const formatter = new Intl.DateTimeFormat('en-US', {
          month: 'long', day: 'numeric', year: 'numeric'
        });
        for (let i = 0; i < iterations; i++) {
          formatter.format(testDate);
        }
        results.intl = performance.now() - startIntl;
      }
      
      // Benchmark custom
      if (ENV_INFO.hasCustomFallback && window.AthensDateFallback) {
        const startCustom = performance.now();
        for (let i = 0; i < iterations; i++) {
          window.AthensDateFallback.formatDate(testDate);
        }
        results.custom = performance.now() - startCustom;
      }
      
      console.log('⚡ Performance benchmark results (ms for 1000 operations):', results);
      return results;
    },
    
    // Setup optimal date strategy based on environment
    setupOptimalStrategy() {
      const strategies = [];
      
      if (ENV_INFO.hasLuxon) {
        strategies.push({
          name: 'luxon',
          priority: 1,
          formatDate: (date) => luxon.DateTime.fromJSDate(new Date(date)).toFormat('LLLL dd, yyyy'),
          formatUID: (date) => luxon.DateTime.fromJSDate(new Date(date)).toFormat('MM-dd-yyyy')
        });
      }
      
      if (ENV_INFO.hasIntl) {
        strategies.push({
          name: 'intl',
          priority: 2,
          formatDate: (date) => new Intl.DateTimeFormat('en-US', {
            month: 'long', day: 'numeric', year: 'numeric'
          }).format(new Date(date)),
          formatUID: (date) => new Intl.DateTimeFormat('en-CA').format(new Date(date))
        });
      }
      
      if (ENV_INFO.hasCustomFallback) {
        strategies.push({
          name: 'custom',
          priority: 3,
          formatDate: window.AthensDateFallback.formatDate,
          formatUID: window.AthensDateFallback.formatUID || function(date) {
            const d = new Date(date);
            return `${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}-${d.getFullYear()}`;
          }
        });
      }
      
      // Sort by priority and set up global strategy
      strategies.sort((a, b) => a.priority - b.priority);
      
      if (strategies.length > 0) {
        window.AthensOptimalDateStrategy = strategies[0];
        console.log('🎯 Optimal date strategy selected:', strategies[0].name);
        return strategies[0];
      } else {
        console.warn('⚠️ No date strategies available, using basic Date');
        window.AthensOptimalDateStrategy = {
          name: 'basic',
          formatDate: (date) => new Date(date).toLocaleDateString(),
          formatUID: (date) => {
            const d = new Date(date);
            return `${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}-${d.getFullYear()}`;
          }
        };
        return window.AthensOptimalDateStrategy;
      }
    },
    
    // Monkey patch for js-joda compatibility
    ensureJSJodaCompatibility() {
      // If js-joda is not working properly, provide compatibility layer
      if (typeof window.JSJoda === 'undefined' && window.AthensOptimalDateStrategy) {
        window.JSJoda = {
          LocalDate: {
            now: () => ({
              format: (formatter) => window.AthensOptimalDateStrategy.formatUID(new Date())
            })
          },
          DateTimeFormatter: {
            ofPattern: (pattern) => ({
              format: (date) => {
                if (pattern.includes('MM-dd-yyyy')) {
                  return window.AthensOptimalDateStrategy.formatUID(date);
                } else {
                  return window.AthensOptimalDateStrategy.formatDate(date);
                }
              }
            })
          }
        };
        console.log('🔧 JS-Joda compatibility layer activated');
      }
    }
  };
  
  // Run initial setup
  try {
    const strategyResults = window.AthensTestUtils.testAllStrategies();
    const optimalStrategy = window.AthensTestUtils.setupOptimalStrategy();
    window.AthensTestUtils.ensureJSJodaCompatibility();
    
    console.log('✅ Test environment setup complete');
    console.log('📊 Strategy test results:', strategyResults);
    console.log('🎯 Selected optimal strategy:', optimalStrategy.name);
    
    // Optional performance benchmark
    if (ENV_INFO.hasLuxon || ENV_INFO.hasIntl) {
      setTimeout(() => {
        window.AthensTestUtils.benchmarkDateOperations();
      }, 100);
    }
    
  } catch (error) {
    console.error('❌ Test environment setup failed:', error);
    console.log('🔧 Falling back to basic Date functionality');
    
    // Emergency fallback
    window.AthensOptimalDateStrategy = {
      name: 'emergency',
      formatDate: (date) => new Date(date).toString(),
      formatUID: (date) => new Date(date).toISOString().split('T')[0]
    };
  }
  
  // Export environment info for debugging
  window.AthensEnvInfo = ENV_INFO;
  
})();