hexists: (key, field, cb) ->
	{hash} = @_stores
	@_checkttl key, 'hash', (keyinfo) ->
		if keyinfo?
			cnt = hash.count [key, 0, field]
			cnt.onsuccess = ->
				cb cnt.result
		else
			cb 0
