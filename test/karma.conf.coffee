# Karma configuration
# Generated on Wed Aug 14 2013 19:26:00 GMT-0400 (EDT)
module.exports = (config) ->
  config.set
    # base path, that will be used to resolve files and exclude
    basePath: ".."

    # Coffeescript preprocessor
    preprocessors:
      'test/**/*.coffee': ['coffee']
    
    cofeePreprocessor:
      options:
        sourceMap: true
      transformPath: (path) ->
        path.replace /\.js$/, '.coffee'
    
    # frameworks to use
    frameworks: ["mocha", "chai"]
    
    # list of files / patterns to load in the browser
    files: [
      "creole.min.js"
      "test/spec/**/*.coffee"
    ]
    
    # list of files to exclude
    exclude: []
    
    # test results reporter to use
    # possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ["spec"]
    
    # web server port
    port: 9876
    
    # enable / disable colors in the output (reporters and logs)
    colors: true
    
    # level of logging
    # possible values: config.LOG_DISABLE || config.LOG_ERROR ||
    #                  config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO
    
    # enable / disable watching file and executing tests whenever any file
    # changes
    autoWatch: true
    
    # Start these browsers, currently available:
    # - Chrome
    # - ChromeCanary
    # - Firefox
    # - Opera
    # - Safari (only Mac)
    # - PhantomJS
    # - IE (only Windows)
    browsers: ["PhantomJS", "Chrome", "Firefox", "Opera", "ChromeCanary"]
    
    # If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000
    
    # Continuous Integration mode
    # if true, it capture browsers, run tests and exit
    singleRun: false
