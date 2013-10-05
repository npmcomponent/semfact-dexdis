
request = require 'superagent'

timeout = (t, f) ->
	setTimeout f, t

module.exports = (grunt) ->
	
	grunt.registerTask 'sauce', 'Run tests on saucelabs and save coverage', ->
		done = @async()
		cwd = process.cwd()
		opts = @options
			url:       'http://localhost:9000/'
			username:  process.env['SAUCE_USERNAME']
			accesskey: process.env['SAUCE_ACCESS_KEY']
			platforms: [["Linux", "googlechrome", ""]]
			framework: 'mocha'
			interval:  5000
			require:   null
			coverage:  cwd + '/coverage.json'
			tunnel:    null
			data:
				tags:   ['grunt']
				public: true
				build:  'grunt-' + Math.floor Date.now() / 1000
		
		err = false
		if opts.username is undefined
			grunt.log.error 'No username given!'
			grunt.log.error 'Please provide an username using the SAUCE_USERNAME environment variable or use the grunt task configuration'
			err = true
		if opts.accesskey is undefined
			grunt.log.error 'No accesskey given!'
			grunt.log.error 'Please provide an accesskey using the SAUCE_ACCESS_KEY environment variable or use the grunt task configuration'
			err = true
		if err
			done false
		
		sauceurl  = 'https://saucelabs.com/rest/v1/' + opts.username
		testurl   = sauceurl + '/js-tests'
		statusurl = testurl + '/status'
		updateurl = sauceurl + '/jobs'
		
		if opts.require?
			grunt.task.requires opts.require
		
		# handle http response and check for errors
		handle = (cb) ->
			(err, res) ->
				if err?
					throw res.error
				if res.error isnt false
					throw res.error
				cb res
		
		# handle results from Sauce Labs
		results = (res) ->
			passed  = true
			written = false
			jstests = res['js tests']
			posts = []
			for test in jstests
				do (test) ->
					if test.result?.failures > 0
						passed = false
					if test.result?.coverage? and not written
						grunt.file.write opts.coverage, JSON.stringify test.result.coverage
						written = true
					posts.push (cb) ->
						grunt.verbose.writeln 'Posting build data back to Sauce Labs for ' + test.id
						jobid = test.url.split('/jobs/')[1] # FIXME: bad parsing
						post = request.put updateurl + '/' + jobid
						post.auth opts.username, opts.accesskey
						post.send opts.data
						post.send {passed}
						post.end (err, res) ->
							cb err, res
			grunt.util.async.parallel posts, (err) ->
				if err?
					throw err
				if not passed
					grunt.log.error 'Tests failed!'
					done false
					return
				else
					grunt.log.writeln 'Tests passed!'
					do done
					return
		
		grunt.log.writeln 'Running ' + opts.url + ' on Sauce Labs...'
		grunt.verbose.writeln 'Sending post request to Sauce Labs...'
		
		jsunitrequest =
			platforms: opts.platforms
			framework: opts.framework
			url:       opts.url
		
		if opts.tunnel?
			jsunitrequest['tunnel-identifier'] = opts.tunnel
		
		post = request.post testurl
		post.auth opts.username, opts.accesskey
		post.send jsunitrequest
		post.end handle (res) ->
			grunt.log.writeln 'Waiting for finish...'
			tests = res.body
			check = ->
				grunt.verbose.writeln 'Checking for completion of tests...'
				post = request.post statusurl
				post.auth opts.username, opts.accesskey
				post.send tests
				post.end handle (res) ->
					if res.body.completed is true
						results res.body
					else
						timeout opts.interval, check
			check()
		return






