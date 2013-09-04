module.exports = (grunt) ->
  'use strict'

  grunt.initConfig
    coffee:
      debug:
        files: [
          expand: true
          cwd: 'js'
          src: ['**/*.coffee', '!**/_*.coffee']
          dest: 'build/js'
          ext: '.js'
        ]

    stylus:
      debug:
        files: [
          expand: true
          cwd: 'css'
          src: ['**/*.styl', '!**/_*.styl']
          dest: 'build/css'
          ext: '.css'
        ]

    jade:
      debug:
        files: [
          expand: true
          src: ['*.jade', '!_*.jade']
          dest: 'build'
          ext: '.html'
        ]

    watch:
      coffee:
        files: ['js/**/*.coffee']
        tasks: ['coffee']

      stylus:
        files: ['css/**/*.styl']
        tasks: ['stylus']

      jade:
        files: ['*.jade']
        tasks: ['jade']

    compress:
      debug:
        options:
          archive: 'archive.zip'
        files: [
          expand: true
          cwd: 'build'
          src: ['**']
          dest: 'archive'
        ]

    clean:
      dev: ['build/*']

    connect:
      debug:
        options:
          port: 9999
          host: '127.0.0.1'
          base: 'build'

    copy:
      debug:
        files: [ {
          expand: true
          src: ['js/**/*.js']
          dest: 'build'
        }, {
          expand: true
          src: ['css/**/*.css']
          dest: 'build'
        }, {
          expand: true
          src: ['img/**/*']
          dest: 'build'
        }
        ]

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-compress'

  grunt.registerTask 'debug', ['copy:debug', 'coffee:debug', 'stylus:debug', 'jade:debug']
  grunt.registerTask 'dev', ['debug', 'connect:debug', 'watch']
  grunt.registerTask 'default', ['dev']
