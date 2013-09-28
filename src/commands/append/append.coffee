append: (key, val, cb) ->
	l = 0
	cbmap = ->
		cb l
	@_map key, cbmap, (x) ->
		if x?
			ret = x + val
		else
			ret = val
		l = ret.length
		ret
