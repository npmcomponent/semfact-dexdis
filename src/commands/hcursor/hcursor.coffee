hcursor: (key, cb) ->
	{hash} = @_stores
	@_checkttl key, 'hash', (keyinfo) ->
		if keyinfo?
			range  = IDBKeyRange.bound [key, 0], [key, 1], true, true
			cursor = hash.openCursor range
			cursor.onsuccess = ->
				cb cursor.result
		else
			cb null
