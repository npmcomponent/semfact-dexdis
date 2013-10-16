_hset: (key, field, value, cb) ->
	{keys, hash} = @_stores
	hkey = [key, 0, field]
	cnt = hash.count hkey
	cnt.onsuccess = ->
		nex = cnt.result is 0
		if nex
			keyinfo =
				type: 'hash'
			keys.put keyinfo, key
		put = hash.put value, hkey
		put.onsuccess = ->
			if nex
				cb 1
			else
				cb 0
	return
