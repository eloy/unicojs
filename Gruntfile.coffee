module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    coffee:
      compile:
        options: { bare: true }
        files: {
          'dist/unico.core.js': ['src/*.coffee', 'src/directives/*.coffee', 'src/router/*.coffee']
        }

    concat:
      options:
        separator: '\n;\n'
      dist:
        src: [ 'lib/*.js', 'dist/unico.core.js']
        dest: 'dist/unico.js'

    uglify:
      dist:
        files:
          'dist/unico.min.js': ['dist/unico.js']



  # Load plugins
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  # Default task(s).
  grunt.registerTask "build", ['coffee', 'concat', 'uglify']
  grunt.registerTask "default", 'build'
  return
