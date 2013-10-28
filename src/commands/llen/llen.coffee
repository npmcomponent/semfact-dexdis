llen: (key, cb) ->
	@_checkttl key, 'list', (keyinfo) ->
		if keyinfo is undefined
			cb 0
		else
			cb keyinfo.len
		return
	return
