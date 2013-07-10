livereloadSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet
folderMount = (connect, point) -> connect.static(require('path').resolve(point))

project =
  host: 'localhost'
  port: 9001

module.exports = (grunt) ->
  # Load all grunt tasks
  require('matchdep').filterAll('grunt-*').forEach(grunt.loadNpmTasks)
  
  # Project configuration.
  grunt.initConfig
    # Runs a test server
    connect:
      server:
        options:
          port: project.port
          middleware: (connect, options) -> [livereloadSnippet, folderMount(connect, '.')]

    less:
      compile:
        options:
          paths: ["less"]

        files:
          "dist/wave-datepicker.css": "less/build.less"
          
    mocha:
      test:
        options:
          urls: ["http://localhost:#{project.port}/test/"]
          reporter: 'Spec'
          run: true

    coffee:
      dist:
        files: [
          expand: true
          cwd: 'src'
          src: '{,*/}*.coffee'
          dest: 'dist'
          ext: '.js'
        ]

      test:
        files: [
          expand: true
          cwd: 'test/spec'
          src: '*.coffee'
          dest: 'test/spec'
          ext: '.js'
        ]

    watch:
      coffee:
        files: ['src/{,*/}*.coffee']
        tasks: ['coffee:dist']
      coffeeTest:
        files: ['test/spec/{,*/}*.coffee']
        tasks: ['coffee:test']
      stylesheets:
        files: ['less/{,*/}*.less']
        tasks: ['less']
      livereload:
        files: [
          '{,*/}*.html'
          'src/{,*/}*.js'
          'less/{,*/}*.css'
        ]
        tasks: ['livereload']

    min:
      dist:
        src: ["dist/wave-datepicker.js"]
        dest: "dist/wave-datepicker.min.js"

  grunt.registerTask 'default', [
      'coffee'
      'less'
      'livereload-start'
      'connect:server'
      'watch'
    ]
  grunt.registerTask 'release', [
      'coffee'
      'less'
    ]
  grunt.registerTask "test", [
    'coffee'
    'connect:server'
    'mocha'
  ]
