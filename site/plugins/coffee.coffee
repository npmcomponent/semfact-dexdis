CoffeeScript = require 'coffee-script'
path         = require 'path'
fs           = require 'fs'

module.exports = (env, callback) ->
	
	class CoffeePlugin extends env.ContentPlugin
	
		constructor: (@filepath, @text) ->
			config = env.config['coffee'] or {}
			@ignore = config.ignore or []
	
		getFilename: ->
			if @ignore.indexOf(@filepath.relative) isnt -1
				@filepath.relative
			else
				@filepath.relative.replace /coffee$/, 'js'
	
		getView: ->
			(env, locals, contents, templates, callback) ->
				try
					if @ignore.indexOf(@filepath.relative) isnt -1
						callback null, new Buffer @text
					else
						js = CoffeeScript.compile @text
						callback null, new Buffer js
				catch error
					callback error
	
	CoffeePlugin.fromFile = (filepath, callback) ->
		fs.readFile filepath.full, (error, buffer) ->
			if error
				callback error
			else
				callback null, new CoffeePlugin filepath, buffer.toString()
	
	env.registerContentPlugin 'coffee', '**/*.coffee', CoffeePlugin
	callback()
