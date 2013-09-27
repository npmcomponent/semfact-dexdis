type: (key, cb) ->
	@_checkttl key, (keyinfo) ->
		if keyinfo?
			cb keyinfo.type
		else
			cb 'none'
