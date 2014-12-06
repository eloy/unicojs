// Karma configuration
// Generated on Wed Dec 03 2014 21:37:32 GMT+0100 (CET)

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine', 'requirejs'],

    // list of files / patterns to load in the browser
    // files: [
    //   'test/main.js',
    //   'src/**/*.coffee',,
    //   'test/**/*.coffee',
    //   {pattern: 'node_modules/jsdom/lib/*.js', included: false},
    // ],

    files: [
      'src/**/*.coffee',
      { pattern: 'test/**/*_spec.coffee', included: false },
      { pattern: 'test/support/*.coffee', included: true },
      { pattern: 'test/lib/*polyfill.js', included: true },
      { pattern: 'test/lib/*.js', included: false, served: true },
      'test/main.js'
    ],


    // list of files to exclude
    exclude: [
      'src/unico_app.js.coffee',
      'test/unit/unico_context.coffee'
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      '**/*.coffee': ['coffee']
    },


    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: false,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['PhantomJS'],


    client: { captureConsole: true} ,

    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: true

  });
};
