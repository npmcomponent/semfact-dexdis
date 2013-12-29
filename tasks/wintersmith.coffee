path        = require 'path'
wintersmith = require 'wintersmith'

module.exports = (grunt) ->
	grunt.registerMultiTask 'wintersmith', 'Run a wintersmith build', ->
		done = @async()
		opts = @options
			action: 'build'
			config: './config.json'
		env = wintersmith opts.config
		cb = (err) ->
			if err?
				grunt.log.error err
				done false
			else
				do done
			return
		switch opts.action
			when 'build'
				env.build cb
			when 'preview'
				env.preview cb
			else
				grunt.log.error 'Unknown action. Use build or preview'
				done false
	return

