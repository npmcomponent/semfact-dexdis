expire: (key, seconds, cb) ->
	@_expiremap key, cb, ->
		Date.now() + seconds * 1000
