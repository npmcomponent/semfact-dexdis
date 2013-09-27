setbit: (key, offset, value, cb) ->
	@_getstr key, (val) =>
		value  &= 1
		mask    = 1 << offset
		newval  = (val & ~mask) | (value << offset)
		@set key, newval, ->
			if (val & mask) isnt 0
				cb 1
			else
				cb 0
