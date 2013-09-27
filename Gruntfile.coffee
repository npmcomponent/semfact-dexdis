module.exports = (grunt) ->
	
	config =
		# Read project metadata from `package.json`.
		pkg: grunt.file.readJSON 'package.json'
	
	config.dexdis =
		default:
			dest: 'lib/dexdis.coffee'
		minimal:
			options:
				commands: ['get', 'set', 'del', 'expire', 'ttl']
			dest: 'lib/dexdis-minimal.coffee'
	
	config.coffee =
		compile:
			expand: true
			src:  ['lib/**/*.coffee']
			ext:  '.js'
	
	config.uglify =
		uglify:
			options:
				mangle:
					except: ['Dexdis', 'DexdisTransaction']
			expand: true
			src:  ['lib/**/*.js', '!lib/**/*.min.js']
			ext:  '.min.js'
	
	config.clean = [
		'lib'
	]
	
	grunt.registerTask 'default', ['dexdis', 'coffee', 'uglify']
	
	require('load-grunt-tasks') grunt
	grunt.loadTasks 'tasks'
	grunt.initConfig config
