pexpire: (key, milliseconds, cb) ->
	@_expiremap key, cb, ->
		Date.now() + milliseconds
