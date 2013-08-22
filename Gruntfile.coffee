"use strict"
module.exports = (grunt) ->
  # Load grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

  # Project configuration.
  grunt.initConfig
    # Metadata.
    pkg: grunt.file.readJSON("package.json")

    # Node.js testing with Mocha + Chai
    mochaTest:
      test:
        options:
          reporter: 'spec'
          require: [
            'coffee-script'
            './test/node.globals.js'
          ]
        src: ['test/spec/**/*.coffee']

    # Browser testing with Karma + Mocha + Chai
    karma:
      chrome:
        configFile: 'test/karma.conf.coffee'
        singleRun: true
        browsers: ['Chrome']
      canary:
        configFile: 'test/karma.conf.coffee'
        singleRun: true
        browsers: ['ChromeCanary']
      firefox:
        configFile: 'test/karma.conf.coffee'
        singleRun: true
        browsers: ['Firefox']
      phantom:
        configFile: 'test/karma.conf.coffee'
        singleRun: true
        browsers: ['PhantomJS']
      opera:
        configFile: 'test/karma.conf.coffee'
        singleRun: true
        browsers: ['Opera']

    # YUIDoc generation
    yuidoc:
      name: '<%= pkg.name %>'
      description: '<%= pkg.description %>'
      version: '<%= pkg.version %>'
      url: '<%= pkg.homepage %>'
      options:
        paths: './src/'
        themedir: 'doc/css/'
        outdir: 'doc/'
        syntaxtype: 'coffee'
        extension: '.coffee'

    # Linting
    coffeelint:
      lib: ['src/*.coffee']
      test: ['test/**/*.coffee']
      options:
        'no_trailing_whitespace':
          level: 'error'

    # Coffee-compilation
    coffee:
      node:
        options:
          join: true
          bare: true
        files: [
          expand: true
          cwd: 'build/node'
          src: [ '**/*.coffee' ]
          dest: 'build/node/'
          ext: '.js'
        ]
      browser:
        options:
          join: true
          bare: true
        files:
          'build/browser/index.js': [
            'build/browser/heading.coffee'
            'build/browser/list.coffee'
            'build/browser/table.coffee'
            'build/browser/text.coffee'
            'build/browser/inline.coffee'
            'build/browser/ruler.coffee'
            'build/browser/parser.coffee'
          ]

    # Copy
    copy:
      node:
        files: [
          cwd: 'src'
          src: '**/*.coffee'
          dest: 'build/node/'
          filter: 'isFile'
          expand: true
        ]
      node_install:
        files: [
          cwd: 'build/node'
          src: '**/*.js'
          dest: 'lib/'
          expand: true
        ]
      browser:
        files: [
          cwd: 'src'
          src: '**/*.coffee'
          dest: 'build/browser/'
          filter: 'isFile'
          expand: true
        ]
      browser_install:
        files: [
          src: 'build/browser/index.js'
          dest: 'creole.js'
          expand: false
        ]

    # Preprocessor
    preprocess:
      options:
        context:
          VERSION: '<%= pkg.version %>'
      node:
        options:
          context:
            BUILD_TYPE: 'node'
          inline: true
        src: ['build/node/*.coffee']
      browser:
        options:
          context:
            BUILD_TYPE: 'browser'
          inline: true
        src: ['build/browser/*.coffee']

  # Default task.
  grunt.registerTask "default", ['coffeelint']

  # Builders
  grunt.registerTask "build:node", () ->
    grunt.task.run [
      'coffeelint'
      'copy:node'
      'preprocess:node'
      'coffee:node'
      'copy:node_install'
      'mochaTest:test'
      'yuidoc'
    ]
  grunt.registerTask "build:browser", () ->
    grunt.task.run [
      'coffeelint'
      'copy:browser'
      'preprocess:browser'
      'coffee:browser'
      'copy:browser_install'
      'karma:phantom'
      'yuidoc'
    ]