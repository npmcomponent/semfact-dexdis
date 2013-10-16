hlen: (key, cb) ->
	{hash} = @_stores
	@_checkttl key, 'hash', (keyinfo) ->
		if keyinfo?
			range = IDBKeyRange.bound [key, 0], [key, 1], true, true
			cnt = hash.count range
			cnt.onsuccess = ->
				cb cnt.result
		else
			cb 0
