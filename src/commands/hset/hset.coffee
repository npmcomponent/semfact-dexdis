hset: (key, field, value, cb) ->
	{keys, hash} = @_stores
	@_checkttl key, 'hash', (keyinfo) ->
		hkey = [key, 0, field]
		cnt = hash.count hkey
		cnt.onsuccess = ->
			keyinfo =
				type: 'hash'
			keys.put keyinfo, key
			put = hash.put value, hkey
			put.onsuccess = ->
				if cnt.result is 0
					cb 1
				else
					cb 0
