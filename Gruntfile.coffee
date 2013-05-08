livereloadSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet
folderMount = (connect, point) -> connect.static(require('path').resolve(point))

module.exports = (grunt) ->
  # Load all grunt tasks
  require('matchdep').filterAll('grunt-*').forEach(grunt.loadNpmTasks)
  
  # Project configuration.
  grunt.initConfig
    # Runs a test server
    connect:
      server:
        options:
          port: 9001
          middleware: (connect, options) -> [livereloadSnippet, folderMount(connect, '.')]

    less:
      compile:
        options:
          paths: ["less"]

        files:
          "dist/wave-datepicker.css": "less/build.less"
          
    mocha:
      test:
        src: ['test/index.html']
        options:
          reporter: 'Nyan'
          run: true

    exec:
      nyan_start:
        cmd: './bin/nyan.sh start'
      nyan_stop:
        cmd: './bin/nyan.sh stop'

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

  grunt.renameTask 'regarde', 'watch'

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
    'exec:nyan_start'
    'mocha'
    'exec:nyan_stop'
  ]
