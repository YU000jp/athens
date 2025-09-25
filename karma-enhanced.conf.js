module.exports = function (config) {
  var junitOutputDir = process.env.CIRCLE_TEST_REPORTS || "target/junit"

  config.set({
    browsers: ['ChromeHeadless'],
    basePath: 'target',
    files: [
      // Load date/time libraries in optimal order for maximum compatibility
      
      // 1. Load native CLDR library first (if available)
      '../node_modules/cldrjs/dist/cldr.js',
      
      // 2. Load Luxon as primary alternative (modern, no CLDR dependency)
      '../node_modules/luxon/build/global/luxon.min.js',
      
      // 3. Enhanced CLDR initialization with multiple fallback strategies
      '../cldr-enhanced-init.js',
      
      // 4. Original CLDR init for backward compatibility
      '../cldr-init.js',
      
      // 5. CLDR mock as ultimate fallback
      '../cldr-mock.js',
      
      // 6. Test environment setup
      {
        pattern: '../test-env-setup.js',
        included: true,
        served: true,
        watched: false
      },
      
      // 7. Main test file
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
      // Enhanced client configuration for better error reporting
      captureConsole: true,
      clearContext: false,
      runInParent: false,
      useIframe: true
    },
    
    // Enhanced timeouts for multiple initialization strategies
    browserSocketTimeout: 90000,       // Increased for multiple fallback attempts
    browserNoActivityTimeout: 90000,   // Allow time for fallback initialization
    processKillTimeout: 120000,        // Prevent hanging processes
    captureTimeout: 120000,            // Allow time for complex setup
    
    // Enhanced browser configuration
    customLaunchers: {
      ChromeHeadlessEnhanced: {
        base: 'ChromeHeadless',
        flags: [
          '--no-sandbox',
          '--disable-web-security',
          '--disable-features=VizDisplayCompositor',
          '--enable-logging=stderr',
          '--log-level=0',
          // Enhanced memory and performance settings
          '--max_old_space_size=8192',
          '--max-semi-space-size=256'
        ]
      }
    },

    // the default configuration
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
    
    // Enhanced error handling and reporting
    browserConsoleLogOptions: {
      level: "log",
      format: "%b %T: %m",
      terminal: true
    },
    
    // Preprocessors for better debugging
    preprocessors: {
      'karma-test.js': ['sourcemap']
    },
    
    // Enhanced reporting for debugging
    reporters: ['progress', 'junit'],
    
    // Fail fast on critical errors but allow fallback strategies to work
    failOnEmptyTestSuite: false,
    failOnFailingTestSuite: true,
    
    // Allow retries for flaky date-related tests
    retryLimit: 2,
    
    // Enhanced debugging options
    debug: process.env.KARMA_DEBUG === 'true',
    
    // Custom middleware for serving additional files
    middleware: ['custom'],
    plugins: [
      'karma-cljs-test',
      'karma-chrome-launcher', 
      'karma-junit-reporter',
      {
        'middleware:custom': ['factory', function() {
          return function(req, res, next) {
            // Add custom headers for better date/time library loading
            res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');
            res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
            next();
          };
        }]
      }
    ]
  })
}