
fs = require 'fs'

module.exports = (env, cb) ->
	
	class CommandPlugin extends env.ContentPlugin
		
		constructor: (@command, @dir) ->
			@template = 'command.jade'
		
		getFilename: ->
			'commands/' + @command + '/index.html'
		
		getView: -> (env, locals, contents, templates, cb) ->
			template = templates[@template]
			if template is undefined
				cb Error 'Could not find template ' + @template
				return
			ctx =
				info: require @dir + '/' + @command
			cb null, new Buffer template.fn ctx
	
	class OverviewPlugin extends env.ContentPlugin
		
		constructor: (@commands) ->
		
		getFilename: ->
			'commands/index.html'
		
		getView: -> (env, locals, contents, templates, cb) ->
			template = templates['commands.jade']
			if template is undefined
				cb Error 'Could not find template commands.jade'
				return
			ctx =
				commands = @commands
			cb null, new Buffer template.fn ctx
	
	generator = (contents, cb) ->
		configDirectory = env.config.commands?.dir
		dir = process.cwd() + '/../src/commands'
		commands = fs.readdirSync(dir).filter (x) ->
			x[0] isnt '_'
		tree =
			'commands/index.html': new OverviewPlugin commands
		for cmd in commands
			tree['commands/' + cmd] = new CommandPlugin cmd, dir
		cb null, tree
	
	env.registerGenerator 'pages', generator
	
	do cb

