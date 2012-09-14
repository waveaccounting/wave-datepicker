/*global module:false*/
module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib');
  grunt.loadNpmTasks('grunt-jasmine-task');
  grunt.loadNpmTasks('grunt-volo');

  // Project configuration.
  grunt.initConfig({
    less: {
      compile: {
        options: {
          paths: ['less']
        },
        files: {
          'dist/wave-datepicker.css': 'less/build.less'
        }
      }
    },
    coffee: {
      compile: {
        options: {
          bare: true
        },
        files: {
          'dist/wave-datepicker.js': 'src/wave-datepicker.coffee',
          'spec/wave-datepicker.spec.js': 'spec/wave-datepicker.spec.coffee'
        }
      }
    },
    watch: {
        files: ['src/*', 'less/*', 'spec/*'],
        tasks: 'coffee less'
    },
    jasmine: {
      all: ['specrunner_headless.html']
    }
  });

  // Default task.
  grunt.registerTask('default', 'coffee less');
  grunt.registerTask('test', 'jasmine');
};
