bitop: (op, dest, srcs..., cb) ->
	f    = null
	init = 0
	switch op.toUpperCase()
		when 'NOT'
			f = (x,y) -> ~ y
			if srcs.length > 1
				@onerror Error errs.toomuchop
				return
		when 'AND'
			f    = (x,y) -> x & y
			init = -1
		when 'OR'
			f = (x,y) -> x | y
		when 'XOR'
			f = (x,y) -> x ^ y
	if f is null
		@onerror Error errs.notsupported
		return
	vals = []
	i = 0
	next = (v) =>
		if v isnt undefined
			vals.push v
		i++
		if i > srcs.length
			val = vals.reduce f, init
			@set dest, val, ->
				cb (''+val).length
			return
		key = srcs[i-1]
		@get key, next
	do next
