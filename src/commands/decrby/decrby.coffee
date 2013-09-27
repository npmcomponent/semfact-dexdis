decrby: (key, dec, cb) ->
	@incrby key, -dec, cb
