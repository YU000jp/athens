module.exports = function (config) {
  var junitOutputDir = process.env.CIRCLE_TEST_REPORTS || "target/junit"

  config.set({
    browsers: ['ChromeHeadless'],
    basePath: 'target',
    files: [
      // Clojars-free date handling solution
      // This configuration works without requiring access to repo.clojars.org
      
      // 1. Load CLDR library first
      '../node_modules/cldrjs/dist/cldr.js',
      
      // 2. Browser-only date handler (no Clojure dependencies)
      '../browser-date-handler.js',
      
      // 3. Enhanced CLDR initialization with JavaScript fallbacks
      '../cldr-enhanced-init.js',
      
      // 4. Original CLDR fallbacks for backward compatibility
      '../cldr-init.js',
      '../cldr-mock.js',
      
      // 5. Test environment setup (JavaScript-only features)
      '../test-env-setup.js',
      
      // 6. Main test file
      'karma-test.js'
    ],
    frameworks: ['cljs-test'],
    plugins: [
        'karma-cljs-test',
        'karma-chrome-launcher',
        'karma-junit-reporter'
    ],
    colors: true,
    logLevel: config.LOG_INFO,
    client: {
      args: ['shadow.test.karma.init'],
      singleRun: true,
      // Enhanced configuration for Clojars-free operation
      captureConsole: true,
      clearContext: false,
      // Additional configuration for better error handling
      browserConsoleLogOptions: {
        level: "log",
        format: "%b %T: %m",
        terminal: true
      }
    },
    
    // Enhanced timeouts for multiple initialization strategies
    browserSocketTimeout: 90000,       
    browserNoActivityTimeout: 90000,   
    processKillTimeout: 120000,        
    captureTimeout: 120000,            
    
    // Enhanced browser configuration for restricted environments
    customLaunchers: {
      ChromeHeadlessNoClojars: {
        base: 'ChromeHeadless',
        flags: [
          '--no-sandbox',
          '--disable-web-security',
          '--disable-features=VizDisplayCompositor',
          '--enable-logging=stderr',
          '--log-level=0',
          // Additional flags for restricted network environments
          '--disable-background-networking',
          '--disable-default-apps',
          '--disable-extensions',
          '--disable-sync',
          '--disable-translate',
          '--disable-background-timer-throttling',
          '--disable-renderer-backgrounding',
          '--disable-backgrounding-occluded-windows',
          '--disable-background-tab-rendering',
          // Memory optimization for restricted environments
          '--max_old_space_size=4096',
          '--max-semi-space-size=128'
        ]
      }
    },

    // Default configuration
    junitReporter: {
      outputDir: junitOutputDir + '/karma',
      outputFile: undefined,
      suite: '',
      useBrowserName: true,
      nameFormatter: function(browser, result) {
        return result.fullName || result.description;
      },
      classNameFormatter: function(browser, result) {
        return browser.name + '.' + (result.suite ? result.suite.join('.') : 'unknown');
      }
    },
    
    // Enhanced error handling and reporting for debugging
    browserConsoleLogOptions: {
      level: "log",
      format: "%b %T: %m",
      terminal: true
    },
    
    // Enhanced reporting for debugging
    reporters: ['progress', 'junit'],
    
    // Configuration for restricted environments
    failOnEmptyTestSuite: false,
    failOnFailingTestSuite: true,
    
    // Allow retries for potentially unstable restricted environments
    retryLimit: 3,
    
    // Enhanced debugging options
    debug: process.env.KARMA_DEBUG === 'true',
    
    // Proxy configuration for restricted environments
    proxies: {
      // Block external CDN requests that might cause issues
      '/cdn/': '/base/test/fixtures/empty.js',
      '/external/': '/base/test/fixtures/empty.js'
    },
    
    // Custom middleware for handling restricted environment issues
    middleware: ['restricted-env'],
    plugins: [
      'karma-cljs-test',
      'karma-chrome-launcher', 
      'karma-junit-reporter',
      {
        'middleware:restricted-env': ['factory', function() {
          return function(req, res, next) {
            // Add headers for better compatibility in restricted environments
            res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
            res.setHeader('Pragma', 'no-cache');
            res.setHeader('Expires', '0');
            
            // Handle requests that might fail in restricted environments
            if (req.url.includes('clojars') || req.url.includes('external-cdn')) {
              res.status(204).end(); // No Content - graceful degradation
              return;
            }
            
            next();
          };
        }]
      }
    ]
  })
}