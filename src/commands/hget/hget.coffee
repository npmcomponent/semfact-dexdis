hget: (key, field, cb) ->
	{hash} = @_stores
	@_checkttl key, 'hash', (keyinfo) =>
		@_hget key, field, cb
		return
	return
