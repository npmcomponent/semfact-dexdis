hset: (key, field, value, cb) ->
	{keys, hash} = @_stores
	@_checkttl key, 'hash', (keyinfo) ->
		hkey = [key, 1, field]
		cnt = hash.count hkey
		cnt.onsuccess = ->
			put = hash.put value, [key, 1, field]
			put.onsuccess = ->
				if cnt.result is 0
					cb 1
				else
					cb 0
