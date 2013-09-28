append: (key, val, cb) ->
	l = 0
	cbmap = ->
		cb l
	@_map key, cbmap, (x) ->
		ret = x + val
		l = ret.length
		ret
