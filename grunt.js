/*global module:false*/
module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib');

  grunt.loadNpmTasks('grunt-volo');

  // Project configuration.
  grunt.initConfig({
    less: {
      compile: {
        options: {
          paths: ['assets/css']
        },
        files: {
          'dist/wave-datepicker.css': 'assets/less/wave-datepicker.less'
        }
      }
    },
    coffee: {
      compile: {
        options: {
          bare: true
        },
        files: {
          'dist/wave-datepicker.js': 'src/wave-datepicker.coffee'
        }
      }
    },
    watch: {
      files: {
        files: 'src/wave-datepicker.coffee',
        tasks: 'coffee'
      }
    }
  });

  // Default task.
  grunt.registerTask('default', 'coffee less');
};
