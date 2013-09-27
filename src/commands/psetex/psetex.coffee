psetex: (key, secs, value, cb) ->
	@set key, value, =>
		@pexpire key, secs, ->
			cb 'OK'
