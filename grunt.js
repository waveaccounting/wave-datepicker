/*global module:false*/
module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib');

  grunt.loadNpmTasks('grunt-volo');

  // Project configuration.
  grunt.initConfig({
    coffee: {
      compile: {
        options: {
          bare: true
        },
        files: {
          'dist/bootstrap-datepicker.js': 'src/datepicker.coffee'
        }
      }
    }
  });

  // Default task.
  grunt.registerTask('default', 'coffee');
};
