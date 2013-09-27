pexpireat: (key, tstamp, cb) ->
	@_expiremap key, cb, ->
		tstamp
