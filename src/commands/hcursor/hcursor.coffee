hcursor: (key, args..., cb) ->
	l = args.length
	if l isnt 0 and l isnt 2 and l isnt 4
		@onerror new Error errs.wrongargs
		return
	if l > 1
		lopen = false
		uopen = false
		lower = args[0]
		upper = args[1]
	if l is 4
		lopen = args[2]
		uopen = args[3]
	{hash} = @_stores
	@_checkttl key, 'hash', (keyinfo) ->
		if keyinfo?
			if l is 0
				range = IDBKeyRange.bound [key, 0], [key, 1], true, true
			else
				range = IDBKeyRange.bound [key, 0, lower], [key, 0, upper], lopen, uopen
			cursor = hash.openCursor range
			cursor.onsuccess = ->
				if cursor.result is undefined
					cb null
				else
					cb cursor.result
		else
			cb null
		return
	return
