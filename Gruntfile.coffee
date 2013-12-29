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
				sourceMap:  true
			expand: true
			src:  ['lib/**/*.coffee']
			ext:  '.js'
	
	config.coffeeCoverage =
		compile:
			options:
				bare: true
				path: 'relative'
			src:  'lib/dexdis.coffee'
			dest: 'lib/dexdis.coverage.js'
	
	config.uglify =
		uglify:
			options:
				sourceMap:        'lib/dexdis.min.js.map'
				sourceMapIn:      'lib/dexdis.js.map'
				sourceMappingURL: 'dexdis.min.js.map'
				sourceMapPrefix:  5
				mangle:
					except: ['Dexdis', 'DexdisTransaction']
			src:  'lib/dexdis.js'
			dest: 'lib/dexdis.min.js'
	
	config.clean = [
		'lib',
		'site/build',
		'.grunt'
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
			platforms: [['Windows 8', 'internet explorer', '10'],
			            ['Windows 8', 'firefox',           ''],
			            ['Linux',     'googlechrome',      ''],
			            ['OS X 10.6', 'iphone',            '5.0'],
			            ['OS X 10.8', 'safari',            '6']]
			require:   'connect:tests'
			coverage:  'lib/coverage.json'
			data:
				public: true
				build:  process.env['TRAVIS_BUILD_NUMBER']
				tags:   ['travis']
			tunnel:     process.env['TRAVIS_BUILD_NUMBER']
	
	if process.env['TRAVIS_PULL_REQUEST']
		config.sauce.options.data.tags.push 'pullrequest'
	
	config.lcov =
		default:
			src:  'lib/coverage.json'
			dest: 'lib/coverage.lcov'
	
	config.wintersmith =
		pages:
			options:
				config: 'site/config-pages.json'
	
	config['gh-pages'] =
		options:
			base: 'site/build'
		src: ['**']
	
	grunt.registerTask 'compile', ['dexdis', 'dexdistest', 'coffee',
	                               'coffeeCoverage', 'umd', 'uglify']
	grunt.registerTask 'default', ['compile']
	grunt.registerTask 'test', ['compile', 'connect:tests', 'sauce', 'lcov']
	grunt.registerTask 'dev', ['default', 'concurrent:test']
	grunt.registerTask 'site', ['clean', 'compile', 'wintersmith']
	grunt.registerTask 'pages', ['site', 'gh-pages', 'clean']
	
	require('load-grunt-tasks') grunt
	grunt.loadTasks 'tasks'
	grunt.initConfig config
