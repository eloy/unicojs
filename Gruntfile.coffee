module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    coffee:
      compile:
        options: { bare: true }
        files: {
          'dist/.unico_base_tmp.js': ['src/*.coffee', 'src/directives/*.coffee', 'src/components/*.coffee', 'src/router/*.coffee']
        }

    file_append:
      default_options:
        files: [{ prepend: 'React = require("react");\nReactDOM = require("react-dom");\n', input: 'dist/.unico_base_tmp.js',output: 'dist/unico_core.js'}]


    concat:
      options:
        separator: '\n;\n'
      dist:
        src: [ 'lib/*.js', 'dist/.unico_base_tmp.js']
        dest: 'dist/unico.js'

    uglify:
      dist:
        files:
          'dist/unico.min.js': ['dist/unico.js']



  # Load plugins
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-file-append');

  # Default task(s).
  grunt.registerTask "build", ['coffee', 'file_append', 'concat', 'uglify']
  grunt.registerTask "default", 'build'
  return
