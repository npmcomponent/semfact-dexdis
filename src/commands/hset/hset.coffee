hset: (key, field, value, cb) ->
	@_checkttl key, 'hash', (keyinfo) =>
		@_hset key, field, value, cb
	return

