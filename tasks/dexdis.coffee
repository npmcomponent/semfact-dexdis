
fs       = require 'fs'
mustache = require 'mustache'

module.exports = (grunt) ->
	resolveDependencies = (cmds, dir) ->
		getdeps = (deps) ->
			getinfo = (cmd) ->
				require dir + cmd
			infos = {}
			for dep in deps
				info = getinfo dep
				infos[dep] = info
				for dep in info.dependencies
					infos[dep] = getinfo dep
			infos
		l = 0
		infos = getdeps cmds
		deps  = Object.keys infos
		while deps.length > l
			l = deps.length
			infos = getdeps Object.keys infos
			deps  = Object.keys infos
		infos

	readCommands = (infos, dir) ->
		cmds = []
		for m in Object.keys(infos).sort()
			info = infos[m]
			file = fs.realpathSync dir + m + '/' + info.command
			code = grunt.file.read file,
				encoding: 'utf8'
			code = code.trim().split('\n').map (x) ->
				'\t' + x
			code = code.join '\n'
			cmds.push code
		cmds
	
	grunt.registerMultiTask 'dexdistest', 'Generate dexdis test files', ->
		cwd = process.cwd()
		opts = @options
			dir: cwd + '/src/commands/'
			commands: null
			template: cwd + '/src/tests.coffee.tmpl'
		
		if opts.commands is null
			opts.commands = fs.readdirSync(opts.dir).filter (x) ->
				x[0] isnt '_'
		
		if @files.length > 0
			file = @files[0].dest
			if file?
				infos = resolveDependencies opts.commands, opts.dir
				tests = ''
				for cmd, info of infos
					if info.test?
						test = grunt.file.read opts.dir + cmd + '/' + info.test
						tests += test + '\n'
				tmpl = grunt.file.read opts.template,
					encoding: 'utf8'
				rendered = mustache.render tmpl, {tests}
				grunt.file.write file, rendered
				grunt.log.writeln 'File "' + file + '" created.'
	
	grunt.registerMultiTask 'dexdis', 'Generate dexdis source files', ->
		cwd = process.cwd()
		opts = @options
			dir: cwd + '/src/commands/'
			commands: null
			template: cwd + '/src/dexdis.coffee.tmpl'
		
		if opts.commands is null
			opts.commands = fs.readdirSync(opts.dir).filter (x) ->
				x[0] isnt '_'
		
		if @files.length > 0
			file = @files[0].dest
			if file?
				infos    = resolveDependencies opts.commands, opts.dir
				cmdsarr  = readCommands infos, opts.dir
				commands = cmdsarr.join '\n\t\n'
				tmpl = grunt.file.read opts.template,
					encoding: 'utf8'
				dexdis = mustache.render tmpl, {commands}
				grunt.file.write file, dexdis
				grunt.log.writeln 'File "' + file + '" created.'
