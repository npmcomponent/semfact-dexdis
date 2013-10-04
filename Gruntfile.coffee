module.exports = (grunt) ->
	
	config =
		# Read project metadata from `package.json`.
		pkg: grunt.file.readJSON 'package.json'
	
	config.dexdis =
		default:
			dest: 'lib/dexdis.coffee'
	
	config.dexdistest =
		default:
			dest: 'lib/tests.coffee'
	
	config.coffee =
		compile:
			options:
				bare: true
			expand: true
			src:  ['lib/**/*.coffee']
			ext:  '.js'
	
	config.coffeeCoverage =
		compile:
			options:
				bare: true
			src:  'lib/dexdis.coffee'
			dest: 'lib/dexdis.coverage.js'
	
	config.uglify =
		uglify:
			options:
				mangle:
					except: ['Dexdis', 'DexdisTransaction']
			expand: true
			src:  ['lib/dexdis.js']
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
	
	config.umd =
		default:
			src:            'lib/dexdis.js'
			objectToExport: 'Dexdis'
			amdModuleId:    'dexdis'
			globalAlias:    'Dexdis'
		coverage:
			src:            'lib/dexdis.coverage.js'
			objectToExport: 'Dexdis'
			amdModuleId:    'dexdis'
			globalAlias:    'Dexdis'
	
	config.sauce =
		options:
			url:       'http://localhost:9000/coverage.html'
			platforms: [["Windows 8", "internet explorer", ""],
			            ["Windows 8", "firefox", ""],
			            ["Linux", "googlechrome", ""]]
			require:   'connect:tests'
			coverage:  'lib/coverage.json'
	
	config.lcov =
		default:
			src:  'lib/coverage.json'
			dest: 'lib/coverage.lcov'
	
	grunt.registerTask 'compile', ['dexdis', 'dexdistest', 'coffee',
	                               'coffeeCoverage', 'umd', 'uglify']
	grunt.registerTask 'default', ['compile']
	grunt.registerTask 'test', ['compile', 'connect:tests', 'sauce', 'lcov']
	grunt.registerTask 'dev', ['default', 'concurrent:test']
	
	require('load-grunt-tasks') grunt
	grunt.loadTasks 'tasks'
	grunt.initConfig config
