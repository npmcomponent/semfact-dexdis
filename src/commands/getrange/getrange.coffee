getrange: (key, start, end, cb) ->
	@_getstr key, (val) ->
		cb val.substring start, end
