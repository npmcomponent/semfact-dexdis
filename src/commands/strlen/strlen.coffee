strlen: (key, cb) ->
	@_getstr key, (val) ->
		cb val.length
