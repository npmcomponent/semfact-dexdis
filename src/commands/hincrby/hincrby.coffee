hincrby: (key, field, inc, cb) ->
	@hget key, field, (x) =>
		if x?
			y = x + inc
		else
			y = inc
		@_hset key, field, y, ->
			cb y
		return
	return
