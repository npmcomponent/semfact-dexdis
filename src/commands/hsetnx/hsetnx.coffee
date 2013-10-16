hsetnx: (key, field, value, cb) ->
	{hash} = @_stores
	@hexists key, field, (ex) =>
		if ex is 0
			@_hset key, field, value, cb
		else
			cb 0
	return
