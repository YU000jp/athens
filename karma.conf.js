module.exports = function (config) {
  var junitOutputDir = process.env.CIRCLE_TEST_REPORTS || "target/junit"

  config.set({
    browsers: ['ChromeHeadless'],
    basePath: 'target',
    files: [
      // Enhanced loading strategy with multiple fallback options
      
      // 1. Load CLDR dependencies in correct order before test files
      '../node_modules/cldrjs/dist/cldr.js',
      
      // 2. Load Luxon as modern alternative (already in package.json)
      '../node_modules/luxon/build/global/luxon.min.js',
      
      // 3. Enhanced CLDR initialization with multiple strategies
      '../cldr-enhanced-init.js',
      
      // 4. Original CLDR initialization for backward compatibility
      '../cldr-init.js',
      
      // 5. CLDR mock fallback
      '../cldr-mock.js',
      
      // 6. Test environment setup with strategy selection
      '../test-env-setup.js',
      
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
      singleRun: true
    },
    
    // Enhanced timeouts for CLDR loading
    browserSocketTimeout: 60000,
    browserNoActivityTimeout: 60000,

    // the default configuration
    junitReporter: {
      outputDir: junitOutputDir + '/karma', // results will be saved as outputDir/browserName.xml
      outputFile: undefined, // if included, results will be saved as outputDir/browserName/outputFile
      suite: '' // suite will become the package name attribute in xml testsuite element
    }
  })
}
