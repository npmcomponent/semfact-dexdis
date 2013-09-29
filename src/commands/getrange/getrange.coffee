getrange: (key, start, end, cb) ->
	@_getstr key, (val) ->
		len = val.length
		if start < 0
			start = len + start
		if end < 0
			end = len + end + 1
		cb val.substring start, end
