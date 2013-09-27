incrby: (key, inc, cb) ->
	@_map key, cb, (x) ->
		x + inc
