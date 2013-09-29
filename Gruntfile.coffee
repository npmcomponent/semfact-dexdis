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
	
	config.dexdistest =
		default:
			dest: 'lib/tests.coffee'
	
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
	
	config.connect =
		examples:
			options:
				port:      3000
				base:      'examples'
				keepalive: true
		tests:
			options:
				port: 9000
				base: 'tests'
	
	config.watch =
		tests:
			files: ['src/**/*.coffee', 'src/**/*.coffee.tmpl']
			tasks: ['default']
			options:
				livereload: true
	
	config.concurrent =
		test: 
			tasks: ['connect:tests:keepalive', 'watch:tests']
			options:
				logConcurrentOutput: true
	
	grunt.registerTask 'default', ['dexdis', 'dexdistest', 'coffee', 'uglify']
	
	grunt.registerTask 'dev', ['default', 'concurrent:test']
	
	require('load-grunt-tasks') grunt
	grunt.loadTasks 'tasks'
	grunt.initConfig config
