
fs = require 'fs'

module.exports = (env, cb) ->
	
	class TemplatePlugin extends env.ContentPlugin
		
		constructor: (opts) ->
			@file     = opts.filename
			@template = opts.template
			@context  = opts.context
		
		getFilename: ->
			@file
		
		getView: -> (env, locals, contents, templates, cb) ->
			template = templates[@template]
			if template is undefined
				cb Error 'Could not find template ' + @template
				return
			ctx =
				env: env
				contents: contents
				util: require 'util'
			env.utils.extend ctx, @context
			cb null, new Buffer template.fn ctx
	
	generator = (contents, cb) ->
		configDirectory = env.config.commands?.dir
		dir = process.cwd() + '/../src/commands'
		cmds = fs.readdirSync(dir).filter (x) ->
			x[0] isnt '_'
		commands = {}
		for cmd in cmds
			commands[cmd] = require dir + '/' + cmd
		tree =
			'commands/index.html': new TemplatePlugin
				filename: 'commands/index.html'
				template: 'commands.jade'
				context:  {commands}
		for cmd in cmds
			tree['commands/' + cmd + '/'] = new TemplatePlugin
				filename: 'commands/' + cmd + '/index.html'
				template: 'command.jade'
				context:
					command: commands[cmd]
		cb null, tree
	
	env.registerGenerator 'pages', generator
	
	do cb

