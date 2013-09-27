exists: (key, cb) ->
	@_checkttl key, (keyinfo) ->
		if keyinfo?
			cb 1
		else
			cb 0
