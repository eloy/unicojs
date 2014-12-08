module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    coffee:
      compile:
        options: { bare: true }
        files: {
          'dist/unico.js': ['src/*.coffee', 'src/directives/*.coffee']
        }



  # Load the plugin that provides the "uglify" task.
  grunt.loadNpmTasks "grunt-contrib-coffee"

  # Default task(s).
  grunt.registerTask "default", ["coffee"]
  return
