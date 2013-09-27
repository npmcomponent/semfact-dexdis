getbit: (key, offset, cb) ->
	@_getstr key, (val) ->
		if offset > 31
			cb 0
		else
			cb (val >>> offset) & 1
