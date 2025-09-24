module.exports = function (config) {
  var junitOutputDir = process.env.CIRCLE_TEST_REPORTS || "target/junit"

  config.set({
    browsers: ['ChromeHeadless'],
    basePath: 'target',
    files: [
      // Load CLDR dependencies in correct order before test files
      '../node_modules/cldrjs/dist/cldr.js',
      // Initialize CLDR with minimal required data  
      '../cldr-init.js',
      // Provide fallback mock if CLDR loading fails
      '../cldr-mock.js',
      // Main test file
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

    // the default configuration
    junitReporter: {
      outputDir: junitOutputDir + '/karma', // results will be saved as outputDir/browserName.xml
      outputFile: undefined, // if included, results will be saved as outputDir/browserName/outputFile
      suite: '' // suite will become the package name attribute in xml testsuite element
    }
  })
}
