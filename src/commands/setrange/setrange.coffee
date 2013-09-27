setrange: (key, offset, value, cb) ->
	@_getstr key, (val) =>
		l      = value.length
		left   = val.substring 0, offset
		right  = val.substr offset + l
		newval = left + value + right
		@set key, newval, ->
			cb newval.length
