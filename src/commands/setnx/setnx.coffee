setnx: (key, value, cb) ->
	@_checkttl key, (keyinfo) =>
		if keyinfo?
			cb 0
		else
			@set key, value, ->
				cb 1
	return
