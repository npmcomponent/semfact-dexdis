expireat: (key, tstamp, cb) ->
	@_expiremap key, cb, ->
		tstamp * 1000
