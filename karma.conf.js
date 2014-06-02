// Karma configuration
// Generated on Sat Feb 01 2014 17:41:34 GMT+0900 (JST)

module.exports = function(config) {
  config.set({

    // base path, that will be used to resolve files and exclude
    basePath: '.tmp',


    // frameworks to use
    frameworks: ['browserify', 'mocha', 'sinon-chai'],


    // list of files / patterns to load in the browser
    files: [
      {pattern: 'bower_components/jquery/dist/jquery.js', included: true},
      {pattern: 'test/testdata/**/*.json', included: true},

      {pattern: 'test/app.js', included: true},
    ],


    // list of files to exclude
    exclude: [

    ],

    preprocessors: {
      // 'src/*.js': ['browserify'],
      // 'test/plugin/*.js': ['browserify']
    },


    // test results reporter to use
    // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['progress'],


    // web server port
    port: 9877,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera (has to be installed with `npm install karma-opera-launcher`)
    // - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
    // - PhantomJS
    // - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
    browsers: ['PhantomJS'],


    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,


    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false
  });
};
